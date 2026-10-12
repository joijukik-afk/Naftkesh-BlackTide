extends CharacterBody3D

@export var speed: float = 6.0
@export var mouse_sensitivity: float = 0.005
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.15

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var muzzle: Marker3D = $CameraPivot/Camera3D/Muzzle

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var can_fire: bool = true
var move_input: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var direction := (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		add_look_input(event.relative * 0.5)
	if Input.is_action_just_pressed("fire"):
		try_fire()
	if Input.is_action_just_pressed("reload"):
		reload()

func set_move_input(value: Vector2) -> void:
	move_input = value

func add_look_input(delta: Vector2) -> void:
	rotate_y(-delta.x * mouse_sensitivity)
	camera_pivot.rotation.x = clamp(
		camera_pivot.rotation.x - delta.y * mouse_sensitivity,
		-PI / 2.5, PI / 2.5
	)

func try_fire() -> void:
	if not can_fire or not bullet_scene:
		return
	if not GameManager.use_ammo():
		return
	can_fire = false
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.direction = -camera.global_transform.basis.z
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true

func reload() -> void:
	GameManager.reload()
