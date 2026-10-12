extends Area3D

@export var speed: float = 60.0
@export var damage: int = 10
@export var lifetime: float = 2.0

var direction: Vector3 = Vector3.FORWARD
var time_alive: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
