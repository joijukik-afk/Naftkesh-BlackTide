extends Node

# Signals for UI/Controls to connect to
signal move_vector_changed(vector: Vector2)
signal look_vector_changed(vector: Vector2)
signal fire_pressed
signal fire_released
signal aim_pressed
signal aim_released
signal reload_pressed
signal jump_pressed
signal interact_pressed

var move_input: Vector2 = Vector2.ZERO
var look_input: Vector2 = Vector2.ZERO
var is_firing: bool = false
var is_aiming: bool = false

func _input(event):
	# Handle Physical Keyboard/Gamepad fallback
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed:
			emit_signal("jump_pressed")
		if event.keycode == KEY_R and event.pressed:
			emit_signal("reload_pressed")
		if event.keycode == KEY_E and event.pressed:
			emit_signal("interact_pressed")
		if event.keycode == KEY_MOUSE_LEFT and event.pressed:
			emit_signal("fire_pressed")
		if event.keycode == KEY_MOUSE_LEFT and not event.pressed:
			emit_signal("fire_released")
		if event.keycode == KEY_MOUSE_RIGHT and event.pressed:
			emit_signal("aim_pressed")
		if event.keycode == KEY_MOUSE_RIGHT and not event.pressed:
			emit_signal("aim_released")

# Called by Virtual Joystick Scripts
func set_move_vector(vec: Vector2):
	move_input = vec
	emit_signal("move_vector_changed", move_input)

# Called by Camera Touch Area Scripts
func add_look_vector(vec: Vector2):
	look_input += vec
	# Normalize to prevent extreme speeds if multiple touches occur
	if look_input.length() > 1.0:
		look_input = look_input.normalized()

func reset_look_vector():
	look_input = Vector2.ZERO

func trigger_fire():
	emit_signal("fire_pressed")

func stop_fire():
	emit_signal("fire_released")

func trigger_aim():
	is_aiming = true
	emit_signal("aim_pressed")

func stop_aim():
	is_aiming = false
	emit_signal("aim_released")

func trigger_reload():
	emit_signal("reload_pressed")

func trigger_interact():
	emit_signal("interact_pressed")
