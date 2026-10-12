extends Node3D
## Main - صحنه اصلی بازی
## مدیریت موج دشمنان، دیالوگ، اهداف و شرایط پیروزی/شکست.

# ============================================================
# سیگنال‌ها
# ============================================================
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)

# ============================================================
# منابع
# ============================================================
@export_group("Scenes")
@export var enemy_scene: PackedScene
@export var touch_controls_scene: PackedScene

@export_group("Wave Settings")
@export var enemies_per_wave: int = 5
@export var wave_interval: float = 30.0
@export var spawn_radius: float = 25.0
@export var max_waves: int = 3
@export var time_between_spawns: float = 1.5

# ============================================================
# گره‌ها
# ============================================================
@onready var spawn_timer: Timer = $SpawnTimer
@onready var player: CharacterBody3D = $Player
@onready var touch_controls: CanvasLayer = $TouchControls

# ============================================================
# وضعیت
# ============================================================
var current_wave: int = 0
var enemies_alive: int = 0
var enemies_spawned_this_wave: int = 0
var is_game_running: bool = false
var is_intro_finished: bool = false

# ============================================================
# توابع اولیه
# ============================================================
func _ready() -> void:
	# ریست کردن سیستم‌ها
	if GameManager:
		GameManager.reset()
		GameManager.game_over.connect(_on_game_over)
	
	if MissionManager:
		MissionManager.mission_completed.connect(_on_mission_completed)
		MissionManager.mission_failed.connect(_on_mission_failed)
	
	# راه‌اندازی تایمر
	spawn_timer.wait_time = wave_interval
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_start_next_wave)
	
	# شروع داستان
	call_deferred("_start_intro_dialogue")

# ============================================================
# شروع داستان
# ============================================================
func _start_intro_dialogue() -> void:
	if not DialogueSystem or not DialogueData:
		_start_first_wave()
		return
	
	# نمایش رابط دیالوگ
	if UIManager:
		UIManager.show_dialogue_ui()
	
	# شروع دیالوگ افتتاحیه
	var intro: Array = DialogueData.get_chapter_1_intro()
	DialogueSystem.dialogue_finished.connect(_on_intro_finished, CONNECT_ONE_SHOT)
	DialogueSystem.start_dialogue("intro", intro)

func _on_intro_finished(_id: String) -> void:
	is_intro_finished = true
	print("[Main] دیالوگ افتتاحیه تمام شد. شروع بازی...")
	_start_first_wave()

# ============================================================
# موج‌های دشمن
# ============================================================
func _start_first_wave() -> void:
	is_game_running = true
	current_wave = 0
	_show_combat_dialogue()
	await get_tree().create_timer(2.0).timeout
	_start_next_wave()

func _start_next_wave() -> void:
	if not is_game_running:
		return
	
	current_wave += 1
	
	if current_wave > max_waves:
		_win_game()
		return
	
	print("[Main] شروع موج ", current_wave)
	wave_started.emit(current_wave)
	
	# نمایش اعلان
	if UIManager:
		UIManager.show_notification("موج " + str(current_wave) + " از " + str(max_waves))
	
	enemies_spawned_this_wave = 0
	_spawn_wave_enemies()

func _spawn_wave_enemies() -> void:
	if enemies_spawned_this_wave >= enemies_per_wave:
		return
	
	if enemies_spawned_this_wave >= max_waves and current_wave > 1:
		# دشمنان ویژه در موج‌های بالاتر
		pass
	
	_spawn_enemy()
	enemies_spawned_this_wave += 1
	
	if enemies_spawned_this_wave < enemies_per_wave:
		await get_tree().create_timer(time_between_spawns).timeout
		_spawn_wave_enemies()

func _spawn_enemy() -> void:
	if not enemy_scene:
		push_warning("[Main] enemy_scene تنظیم نشده!")
		return
	
	var enemy: CharacterBody3D = enemy_scene.instantiate() as CharacterBody3D
	if not enemy:
		return
	
	# موقعیت تصادفی در اطراف بازیکن
	var angle: float = randf() * TAU
	var radius: float = spawn_radius + randf_range(-3.0, 3.0)
	var spawn_pos: Vector3 = Vector3(cos(angle) * radius, 2.0, sin(angle) * radius)
	enemy.global_position = spawn_pos
	
	# اتصال سیگنال مرگ
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)
	
	add_child(enemy)
	enemies_alive += 1

func _on_enemy_died() -> void:
	enemies_alive -= 1
	
	# آپدیت هدف
	if MissionManager:
		MissionManager.update_objective_progress("eliminate_raiders")
	
	# بررسی پایان موج
	if enemies_alive <= 0 and enemies_spawned_this_wave >= enemies_per_wave:
		_wave_complete()

func _wave_complete() -> void:
	print("[Main] موج ", current_wave, " تمام شد")
	wave_completed.emit(current_wave)
	
	if UIManager:
		UIManager.show_notification("موج " + str(current_wave) + " تمام شد!")
	
	if current_wave >= max_waves:
		_win_game()
	else:
		spawn_timer.start()

# ============================================================
# دیالوگ‌های مبارزه
# ============================================================
func _show_combat_dialogue() -> void:
	if not DialogueSystem or not DialogueData:
		return
	var combat: Array = DialogueData.get_combat_start()
	DialogueSystem.start_dialogue("combat_start", combat)

# ============================================================
# پیروزی و شکست
# ============================================================
func _win_game() -> void:
	if not is_game_running:
		return
	is_game_running = false
	spawn_timer.stop()
	
	print("[Main] پیروزی!")
	
	# دیالوگ پیروزی
	if DialogueSystem and DialogueData:
		var victory: Array = DialogueData.get_victory()
		DialogueSystem.dialogue_finished.connect(_on_victory_dialogue_end, CONNECT_ONE_SHOT)
		DialogueSystem.start_dialogue("victory", victory)
	else:
		_on_victory_dialogue_end("")

func _on_victory_dialogue_end(_id: String) -> void:
	if GameManager:
		GameManager.win_game()
	if UIManager:
		UIManager.show_game_over(true)

func _on_game_over(won: bool) -> void:
	if not is_game_running:
		return
	is_game_running = false
	spawn_timer.stop()
	
	print("[Main] بازی تمام شد: ", "پیروزی" if won else "شکست")
	
	if not won:
		if DialogueSystem and DialogueData:
			var defeat: Array = DialogueData.get_defeat()
			DialogueSystem.start_dialogue("defeat", defeat)
	
	if UIManager:
		UIManager.show_game_over(won)

func _on_mission_completed(_id: String, _success: bool) -> void:
	pass

func _on_mission_failed(reason: String) -> void:
	print("[Main] مأموریت شکست خورد: ", reason)
	_win_game()

# ============================================================
# توابع کمکی
# ============================================================
func get_current_wave() -> int:
	return current_wave

func get_enemies_alive() -> int:
	return enemies_alive

func is_game_active() -> bool:
	return is_game_running

func pause_game() -> void:
	if GameManager:
		GameManager.toggle_pause()

func restart_game() -> void:
	if SceneTransition:
		SceneTransition.reload_current_scene()

func quit_game() -> void:
	get_tree().quit()
