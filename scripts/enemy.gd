extends CharacterBody3D

@export var speed: float = 3.0
@export var health: int = 30
@export var damage: int = 10
@export var attack_range: float = 2.5
@export var attack_cooldown: float = 1.5

var player: Node3D
var can_attack: bool = true
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	add_to_group("enemies")
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if player and is_instance_valid(player):
		var to_player = player.global_position - global_position
		to_player.y = 0
		var dist = to_player.length()

		if dist > 1.5:
			var dir = to_player.normalized()
			velocity.x = dir.x * speed
			velocity.z = dir.z * speed
			var target = Vector3(player.global_position.x, global_position.y, player.global_position.z)
			if target.distance_to(global_position) > 0.1:
				look_at(target, Vector3.UP)
		else:
			velocity.x = 0
			velocity.z = 0

		if dist < attack_range and can_attack:
			_attack()
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func _attack() -> void:
	can_attack = false
	GameManager.damage_player(damage)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()

func die() -> void:
	GameManager.add_score(10)
	queue_free()
