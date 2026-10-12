extends CanvasLayer
## TouchControls - کنترل‌های لمسی موبایل
## جوی‌استیک حرکت، چرخش دوربین با لمس، و دکمه‌های اکشن.

# ============================================================
# سیگنال‌ها
# ============================================================
signal joystick_moved(direction: Vector2)
signal joystick_released()
signal camera_rotated(delta: Vector2)

# ============================================================
# تنظیمات
# ============================================================
@export_group("Joystick")
@export var joystick_radius: float = 100.0
@export var joystick_deadzone: float = 0.15

@export_group("Camera")
@export var look_sensitivity: float = 1.0

@export_group("Vibration")
@export var vibration_enabled: bool = true

# ============================================================
# گره‌ها
# ============================================================
@onready var joystick_base: Control = $JoystickBase
@onready var joystick_knob: Control = $JoystickBase/Knob
@onready var look_area: Control = $LookArea
@onready var fire_button: TouchScreenButton = $FireButton
@onready var reload_button: TouchScreenButton = $ReloadButton
@onready var aim_button: TouchScreenButton = $AimButton
@onready var sprint_button: TouchScreenButton = $SprintButton
@onready var interact_button: TouchScreenButton = $InteractButton
@onready var pause_button: TouchScreenButton = $PauseButton

# ============================================================
# وضعیت داخلی
# ============================================================
var joystick_touch_id: int = -1
var look_touch_id: int = -1
var joystick_center: Vector2 = Vector2.ZERO
var last_look_position: Vector2 = Vector2.ZERO
var player: CharacterBody3D = null

var is_firing: bool = false
var is_aiming: bool = false
var fire_hold_timer: float = 0.0

# ============================================================
# توابع اولیه
# ============================================================
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# محاسبه مرکز جوی‌استیک
	joystick_center = joystick_base.size / 2.0
	joystick_knob.position = joystick_center - joystick_knob.size / 2.0
	
	# اتصال دکمه‌ها
	_connect_buttons()
	
	# پیدا کردن بازیکن
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	
	# نمایش/مخفی بر اساس پلتفرم
	if not OS.has_feature("mobile") and not OS.has_feature("android"):
		# روی دسکتاپ می‌تونی تست کنی
		pass
	
	print("[TouchControls] آماده. بازیکن: ", "پیدا شد" if player else "پیدا نشد")

func _connect_buttons() -> void:
	if fire_button:
		fire_button.pressed.connect(_on_fire_pressed)
		fire_button.released.connect(_on_fire_released)
	if reload_button:
		reload_button.pressed.connect(_on_reload_pressed)
	if aim_button:
		aim_button.pressed.connect(_on_aim_pressed)
		aim_button.released.connect(_on_aim_released)
	if sprint_button:
		sprint_button.pressed.connect(_on_sprint_pressed)
		sprint_button.released.connect(_on_sprint_released)
	if interact_button:
		interact_button.pressed.connect(_on_interact_pressed)
	if pause_button:
		pause_button.pressed.connect(_on_pause_pressed)

# ============================================================
# ورودی‌های لمسی
# ============================================================
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)
	elif event is InputEventMouseButton and event.pressed and OS.has_feature("editor"):
		# تست روی دسکتاپ با ماوس
		pass

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		# لمس جوی‌استیک
		if joystick_touch_id == -1 and _is_in_joystick_area(event.position):
			joystick_touch_id = event.index
			_update_joystick(event.position)
		# لمس ناحیه چرخش دوربین
		elif look_touch_id == -1 and _is_in_look_area(event.position):
			look_touch_id = event.index
			last_look_position = event.position
	else:
		# رها کردن لمس
		if event.index == joystick_touch_id:
			joystick_touch_id = -1
			_reset_joystick()
		elif event.index == look_touch_id:
			look_touch_id = -1

func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index == joystick_touch_id:
		_update_joystick(event.position)
	elif event.index == look_touch_id:
		var delta: Vector2 = event.position - last_look_position
		last_look_position = event.position
		if player and player.has_method("add_look_input"):
			player.add_look_input(delta * look_sensitivity)
			camera_rotated.emit(delta)

# ============================================================
# بررسی نواحی لمسی
# ============================================================
func _is_in_joystick_area(position: Vector2) -> bool:
	if not joystick_base:
		return false
	var rect: Rect2 = joystick_base.get_global_rect()
	rect = rect.grow(joystick_radius * 0.5)
	return rect.has_point(position)

func _is_in_look_area(position: Vector2) -> bool:
	if not look_area:
		return false
	return look_area.get_global_rect().has_point(position)

# ============================================================
# جوی‌استیک
# ============================================================
func _update_joystick(touch_position: Vector2) -> void:
	if not joystick_base or not joystick_knob:
		return
	
	var local_pos: Vector2 = joystick_base.get_global_transform().affine_inverse() * touch_position
	var direction: Vector2 = local_pos - joystick_center
	var distance: float = direction.length()
	
	# محدود کردن به شعاع
	if distance > joystick_radius:
		direction = direction.normalized() * joystick_radius
		distance = joystick_radius
	
	# حرکت دادن دسته
	joystick_knob.position = joystick_center + direction - joystick_knob.size / 2.0
	
	# محاسبه ورودی
	var input_vector: Vector2 = direction / joystick_radius
	if input_vector.length() < joystick_deadzone:
		input_vector = Vector2.ZERO
	
	# ارسال به بازیکن
	if player and player.has_method("set_move_input"):
		player.set_move_input(input_vector)
	
	joystick_moved.emit(input_vector)

func _reset_joystick() -> void:
	if joystick_knob:
		joystick_knob.position = joystick_center - joystick_knob.size / 2.0
	if player and player.has_method("set_move_input"):
		player.set_move_input(Vector2.ZERO)
	joystick_released.emit()

# ============================================================
# دکمه‌ها
# ============================================================
func _on_fire_pressed() -> void:
	is_firing = true
	_do_fire()
	_vibrate(30)

func _on_fire_released() -> void:
	is_firing = false

func _do_fire() -> void:
	if player and player.has_method("try_fire"):
		player.try_fire()

func _on_reload_pressed() -> void:
	if player and player.has_method("reload"):
		player.reload()
		_vibrate(20)

func _on_aim_pressed() -> void:
	is_aiming = true
	if player and player.has_method("set_aiming"):
		player.set_aiming(true)
	_vibrate(15)

func _on_aim_released() -> void:
	is_aiming = false
	if player and player.has_method("set_aiming"):
		player.set_aiming(false)

func _on_sprint_pressed() -> void:
	if player and player.has_method("set_sprinting"):
		player.set_sprinting(true)

func _on_sprint_released() -> void:
	if player and player.has_method("set_sprinting"):
		player.set_sprinting(false)

func _on_interact_pressed() -> void:
	if player and player.has_method("_try_interact"):
		player._try_interact()
	_vibrate(15)

func _on_pause_pressed() -> void:
	if GameManager:
		GameManager.toggle_pause()
	_vibrate(20)

# ============================================================
# شلیک مداوم (نگه داشتن دکمه)
# ============================================================
func _process(delta: float) -> void:
	if is_firing:
		fire_hold_timer -= delta
		if fire_hold_timer <= 0.0:
			_do_fire()
			fire_hold_timer = 0.1

# ============================================================
# لرزش
# ============================================================
func _vibrate(duration_ms: int) -> void:
	if not vibration_enabled:
		return
	if SettingsManager and not SettingsManager.vibration_enabled:
		return
	Input.vibrate_handheld(duration_ms)

# ============================================================
# توابع عمومی
# ============================================================
func set_visible_controls(visible: bool) -> void:
	visible = visible

func set_look_sensitivity(value: float) -> void:
	look_sensitivity = clampf(value, 0.3, 3.0)

func enable_vibration(enabled: bool) -> void:
	vibration_enabled = enabled

func get_move_direction() -> Vector2:
	if not joystick_knob or not joystick_base:
		return Vector2.ZERO
	var center: Vector2 = joystick_base.size / 2.0
	var knob_center: Vector2 = joystick_knob.position + joystick_knob.size / 2.0
	return (knob_center - center) / joystick_radius

func is_player_aiming() -> bool:
	return is_aiming

func is_player_firing() -> bool:
	return is_firing
