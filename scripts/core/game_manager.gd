extends Node
## GameManager - مدیریت وضعیت کلی بازی
## جان، مهمات، امتیاز، و وضعیت بازی را مدیریت می‌کند.

# ============================================================
# سیگنال‌ها
# ============================================================
signal health_changed(new_health: int, max_health: int)
signal ammo_changed(current: int, max_ammo: int)
signal score_changed(new_score: int)
signal game_over(won: bool)
signal game_paused(is_paused: bool)
signal player_damaged(amount: int)
signal player_healed(amount: int)
signal enemy_killed(enemy_type: String)

# ============================================================
# وضعیت بازی
# ============================================================
enum GameState { BOOT, MAIN_MENU, PLAYING, PAUSED, CUTSCENE, GAME_OVER }

var current_state: GameState = GameState.BOOT
var player_health: int = 100
var max_health: int = 100
var ammo: int = 30
var max_ammo: int = 30
var reserve_ammo: int = 120
var score: int = 0
var kills: int = 0
var mission_objectives: Array[String] = []
var is_game_active: bool = false

# ============================================================
# توابع اولیه
# ============================================================
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and current_state == GameState.PLAYING:
		toggle_pause()

# ============================================================
# مدیریت وضعیت
# ============================================================
func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	
	match new_state:
		GameState.PLAYING:
			is_game_active = true
			get_tree().paused = false
		GameState.PAUSED:
			get_tree().paused = true
		GameState.GAME_OVER:
			is_game_active = false
			get_tree().paused = false

func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		change_state(GameState.PAUSED)
		game_paused.emit(true)
	elif current_state == GameState.PAUSED:
		change_state(GameState.PLAYING)
		game_paused.emit(false)

# ============================================================
# ریست کردن بازی
# ============================================================
func reset() -> void:
	player_health = max_health
	ammo = max_ammo
	reserve_ammo = 120
	score = 0
	kills = 0
	mission_objectives.clear()
	is_game_active = true
	change_state(GameState.PLAYING)
	
	health_changed.emit(player_health, max_health)
	ammo_changed.emit(ammo, max_ammo)
	score_changed.emit(score)

# ============================================================
# سیستم جان
# ============================================================
func damage_player(amount: int) -> void:
	if not is_game_active:
		return
	player_health = max(0, player_health - amount)
	health_changed.emit(player_health, max_health)
	player_damaged.emit(amount)
	
	if player_health <= 0:
		_on_player_death()

func heal_player(amount: int) -> void:
	player_health = min(max_health, player_health + amount)
	health_changed.emit(player_health, max_health)
	player_healed.emit(amount)

func _on_player_death() -> void:
	is_game_active = false
	change_state(GameState.GAME_OVER)
	game_over.emit(false)

# ============================================================
# سیستم مهمات
# ============================================================
func use_ammo() -> bool:
	if ammo > 0:
		ammo -= 1
		ammo_changed.emit(ammo, max_ammo)
		return true
	return false

func reload() -> bool:
	if reserve_ammo <= 0:
		return false
	var needed: int = max_ammo - ammo
	var to_load: int = min(needed, reserve_ammo)
	ammo += to_load
	reserve_ammo -= to_load
	ammo_changed.emit(ammo, max_ammo)
	return true

func add_ammo(amount: int) -> void:
	reserve_ammo += amount
	ammo_changed.emit(ammo, max_ammo)

# ============================================================
# سیستم امتیاز
# ============================================================
func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func register_kill(enemy_type: String) -> void:
	kills += 1
	add_score(10)
	enemy_killed.emit(enemy_type)

# ============================================================
# سیستم مأموریت
# ============================================================
func add_objective(text: String) -> void:
	mission_objectives.append(text)

func complete_objective(index: int) -> void:
	if index >= 0 and index < mission_objectives.size():
		mission_objectives.remove_at(index)

func win_game() -> void:
	is_game_active = false
	change_state(GameState.GAME_OVER)
	game_over.emit(true)
