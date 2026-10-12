extends CanvasLayer

var player: Node = null

var joystick_touch_id: int = -1
var joystick_center: Vector2
const JOYSTICK_RADIUS: float = 120.0
var joystick_knob: Panel

var look_touch_id: int = -1
var last_look_pos: Vector2

func _ready() -> void:
	print("=== TouchControls ready ===")
	_create_ui()
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	print("Player found: ", player)

func _create_ui() -> void:
	var screen := get_viewport().get_visible_rect().size
	print("Screen size: ", screen)
	joystick_center = Vector2(200, screen.y - 200)

	# پایه جوی‌استیک
	var base := Panel.new()
	base.size = Vector2(240, 240)
	base.position = joystick_center - Vector2(120, 120)
	var base_style := StyleBoxFlat.new()
	base_style.bg_color = Color(1, 1, 1, 0.15)
	base_style.corner_radius_top_left = 120
	base_style.corner_radius_top_right = 120
	base_style.corner_radius_bottom_left = 120
	base_style.corner_radius_bottom_right = 120
	base.add_theme_stylebox_override("panel", base_style)
	add_child(base)

	# دستگیره جوی‌استیک
	joystick_knob = Panel.new()
	joystick_knob.size = Vector2(80, 80)
	joystick_knob.position = joystick_center - Vector2(40, 40)
	var knob_style := StyleBoxFlat.new()
	knob_style.bg_color = Color(0.5, 0.8, 1.0, 0.8)
	knob_style.corner_radius_top_left = 40
	knob_style.corner_radius_top_right = 40
	knob_style.corner_radius_bottom_left = 40
	knob_style.corner_radius_bottom_right = 40
	joystick_knob.add_theme_stylebox_override("panel", knob_style)
	add_child(joystick_knob)

	# دکمه FIRE
	var fire := Button.new()
	fire.text = "FIRE"
	fire.add_theme_font_size_override("font_size", 28)
	fire.size = Vector2(160, 160)
	fire.position = Vector2(screen.x - 200, screen.y - 250)
	var fire_style := StyleBoxFlat.new()
	fire_style.bg_color = Color(0.8, 0.2, 0.2, 0.7)
	fire_style.corner_radius_top_left = 80
	fire_style.corner_radius_top_right = 80
	fire_style.corner_radius_bottom_left = 80
	fire_style.corner_radius_bottom_right = 80
	fire.add_theme_stylebox_override("normal", fire_style)
	fire.add_theme_stylebox_override("pressed", fire_style)
	fire.pressed.connect(_on_fire)
	add_child(fire)

	# دکمه RELOAD
	var reload := Button.new()
	reload.text = "RELOAD"
	reload.add_theme_font_size_override("font_size", 18)
	reload.size = Vector2(140, 90)
	reload.position = Vector2(screen.x - 380, screen.y - 180)
	var reload_style := StyleBoxFlat.new()
	reload_style.bg_color = Color(0.2, 0.4, 0.8, 0.7)
	reload_style.corner_radius_top_left = 15
	reload_style.corner_radius_top_right = 15
	reload_style.corner_radius_bottom_left = 15
	reload_style.corner_radius_bottom_right = 15
	reload.add_theme_stylebox_override("normal", reload_style)
	reload.add_theme_stylebox_override("pressed", reload_style)
	reload.pressed.connect(_on_reload)
	add_child(reload)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	var screen := get_viewport().get_visible_rect().size
	if event.pressed:
		if joystick_touch_id == -1 and event.position.x < screen.x / 2:
			joystick_touch_id = event.index
			_update_joystick(event.position)
		elif look_touch_id == -1 and event.position.x >= screen.x / 2:
			look_touch_id = event.index
			last_look_pos = event.position
	else:
		if event.index == joystick_touch_id:
			joystick_touch_id = -1
			_reset_joystick()
		elif event.index == look_touch_id:
			look_touch_id = -1

func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index == joystick_touch_id:
		_update_joystick(event.position)
	elif event.index == look_touch_id:
		var delta = event.position - last_look_pos
		last_look_pos = event.position
		if player and player.has_method("add_look_input"):
			player.add_look_input(delta * 1.5)

func _update_joystick(touch_pos: Vector2) -> void:
	var dir = touch_pos - joystick_center
	var dist = min(dir.length(), JOYSTICK_RADIUS)
	var clamped = dir.normalized() * dist if dir.length() > 0.01 else Vector2.ZERO
	joystick_knob.position = joystick_center + clamped - Vector2(40, 40)
	var input_vec = clamped / JOYSTICK_RADIUS
	if player and player.has_method("set_move_input"):
		player.set_move_input(Vector2(input_vec.x, input_vec.y))

func _reset_joystick() -> void:
	joystick_knob.position = joystick_center - Vector2(40, 40)
	if player and player.has_method("set_move_input"):
		player.set_move_input(Vector2.ZERO)

func _on_fire() -> void:
	print("FIRE pressed")
	if player and player.has_method("try_fire"):
		player.try_fire()

func _on_reload() -> void:
	print("RELOAD pressed")
	if player and player.has_method("reload"):
		player.reload()
