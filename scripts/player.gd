extends CharacterBody3D
## Player - کنترلر شخصیت اصلی Naftkesh
## حرکت، دوربین، شلیک، خشاب‌گذاری، و تعاملات بازیکن.

# ============================================================
# سیگنال‌ها
# ============================================================
signal fired()
signal reloaded()
signal aimed(is_aiming: bool)
signal sprinted(is_sprinting: bool)
signal damaged(amount: int)
signal died()
signal interacted(target: Node)

# ============================================================
# پارامترهای حرکت
# ============================================================
@export_group("Movement")
@export var walk_speed: float = 4.0
@export var run_speed: float = 7.0
@export var crouch_speed: float = 2.0
@export var aim_speed: float = 2.5
@export var acceleration: float = 10.0
@export var deceleration: float = 15.0
@export var jump_velocity: float = 7.0

# ============================================================
# پارامترهای دوربین
# ============================================================
@export_group("Camera")
@export var mouse_sensitivity: float = 0.005
@export var touch_sensitivity: float = 0.008
@export var min_pitch: float = -1.2
@export var max_pitch: float = 1.2
@export var camera_distance: float = 3.0
@export var aim_camera_distance: float = 1.8

# ============================================================
# پارامترهای سلاح
# ============================================================
@export_group("Weapon")
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.15
@export var damage: int = 15
@export var bullet_speed: float = 60.0
@export var max_health: int = 100

# ============================================================
# گره‌های صحنه
# ============================================================
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var muzzle: Marker3D = $CameraPivot/Camera3D/Muzzle
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# ============================================================
# وضعیت داخلی
# ============================================================
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 24.0)
var move_input: Vector2 = Vector2.ZERO
var can_fire: bool = true
var is_aiming: bool = false
var is_sprinting: bool = false
var is_crouching: bool = false
var health: int = 100
var is_dead: bool = false

# ============================================================
# توابع اولیه
# ============================================================
func _ready() -> void:
	add_to_group("player")
	health = max_health
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# اتصال به رویدادهای GameManager
	if GameManager:
		GameManager.game_over.connect(_on_game_over)
	
	print("[Player] بازیکن آماده شد. جان: ", health)

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# ============================================================
# فیزیک و حرکت
# ============================================================
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# جاذبه
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# پرش
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	# جهت حرکت
	var basis_dir: Vector3 = (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
	
	# سرعت فعلی
	var current_speed: float = _get_current_speed()
	
	if basis_dir.length() > 0.01:
		velocity.x = lerpf(velocity.x, basis_dir.x * current_speed, acceleration * delta)
		velocity.z = lerpf(velocity.z, basis_dir.z * current_speed, acceleration * delta)
	else:
		velocity.x = lerpf(velocity.x, 0.0, deceleration * delta)
		velocity.z = lerpf(velocity.z, 0.0, deceleration * delta)
	
	move_and_slide()
	
	# بررسی سقوط از نقشه
	if global_position.y < -50.0:
		take_damage(999)

func _get_current_speed() -> float:
	if is_aiming:
		return aim_speed
	if is_crouching:
		return crouch_speed
	if is_sprinting:
		return run_speed
	return walk_speed

# ============================================================
# ورودی‌ها
# ============================================================
func _input(event: InputEvent) -> void:
	# چرخش دوربین با ماوس (فقط برای تست)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		add_look_input(event.relative * 0.5)
	
	# دکمه‌های اکشن
	if event.is_action_pressed("fire"):
		try_fire()
	if event.is_action_pressed("reload"):
		reload()
	if event.is_action_pressed("aim"):
		set_aiming(true)
	elif event.is_action_released("aim"):
		set_aiming(false)
	if event.is_action_pressed("interact"):
		_try_interact()

# ============================================================
# توابع کنترل لمسی (از TouchControls فراخوانی می‌شوند)
# ============================================================
func set_move_input(value: Vector2) -> void:
	move_input = value

func add_look_input(delta: Vector2) -> void:
	if is_dead:
		return
	var sensitivity: float = touch_sensitivity if OS.has_feature("mobile") else mouse_sensitivity
	rotate_y(-delta.x * sensitivity)
	camera_pivot.rotation.x = clampf(
		camera_pivot.rotation.x - delta.y * sensitivity,
		min_pitch,
		max_pitch
	)

# ============================================================
# نشانه‌گیری
# ============================================================
func set_aiming(value: bool) -> void:
	if is_dead or is_aiming == value:
		return
	is_aiming = value
	aimed.emit(is_aiming)
	
	# تغییر فاصله دوربین
	var target_distance: float = aim_camera_distance if is_aiming else camera_distance
	var tween: Tween = create_tween()
	tween.tween_property(camera, "position:z", target_distance, 0.2)

# ============================================================
# دویدن
# ============================================================
func set_sprinting(value: bool) -> void:
	if is_dead:
		return
	is_sprinting = value
	sprinted.emit(is_sprinting)

func toggle_sprint() -> void:
	set_sprinting(not is_sprinting)

# ============================================================
# شلیک
# ============================================================
func try_fire() -> void:
	if is_dead or not can_fire:
		return
	if not bullet_scene:
		push_warning("[Player] bullet_scene تنظیم نشده!")
		return
	if GameManager and not GameManager.use_ammo():
		if AudioManager:
			AudioManager.play_sfx("reload_empty")
		return
	
	can_fire = false
	
	# ساخت گلوله
	var bullet: Node3D = bullet_scene.instantiate() as Node3D
	if not bullet:
		can_fire = true
		return
	
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	
	# جهت گلوله
	var direction: Vector3 = -camera.global_transform.basis.z
	if bullet.has_method("set_direction"):
		bullet.set_direction(direction)
	elif "direction" in bullet:
		bullet.direction = direction
	
	# صدا و افکت
	if AudioManager:
		AudioManager.play_sfx("gunshot_pistol")
	
	fired.emit()
	
	# تایمر نرخ شلیک
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true

# ============================================================
# خشاب‌گذاری
# ============================================================
func reload() -> void:
	if is_dead:
		return
	if GameManager and GameManager.reload():
		if AudioManager:
			AudioManager.play_sfx("reload")
		reloaded.emit()

# ============================================================
# آسیب و مرگ
# ============================================================
func take_damage(amount: int) -> void:
	if is_dead:
		return
	health = max(0, health - amount)
	damaged.emit(amount)
	
	if GameManager:
		GameManager.damage_player(amount)
	
	if AudioManager:
		AudioManager.play_sfx("player_hurt")
	
	if health <= 0:
		_die()

func heal(amount: int) -> void:
	if is_dead:
		return
	health = min(max_health, health + amount)
	if GameManager:
		GameManager.heal_player(amount)

func _die() -> void:
	if is_dead:
		return
	is_dead = true
	died.emit()
	if AudioManager:
		AudioManager.play_sfx("player_death")
	print("[Player] بازیکن از پا افتاد.")

func _on_game_over(_won: bool) -> void:
	is_dead = true

# ============================================================
# تعامل
# ============================================================
func _try_interact() -> void:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		camera.global_position,
		camera.global_position + (-camera.global_transform.basis.z * 3.0)
	)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var result: Dictionary = space_state.intersect_ray(query)
	
	if result.is_empty():
		return
	
	var collider: Node = result.get("collider")
	if collider and collider.has_method("interact"):
		collider.interact(self)
		interacted.emit(collider)

# ============================================================
# توابع کمکی
# ============================================================
func get_health() -> int:
	return health

func get_health_percent() -> float:
	return float(health) / float(max_health)

func is_player_dead() -> bool:
	return is_dead

func get_move_input() -> Vector2:
	return move_input

func get_camera() -> Camera3D:
	return camera

func get_aim_direction() -> Vector3:
	return -camera.global_transform.basis.z
