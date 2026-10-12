extends Node3D

@onready var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	GameManager.reset()
	GameManager.game_over.connect(_on_game_over)
	spawn_timer.timeout.connect(_spawn_enemy)
	spawn_timer.start(3.0)
	for i in range(3):
		_spawn_enemy()

func _spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	var angle = randf() * TAU
	var radius = randf_range(15.0, 25.0)
	enemy.global_position = Vector3(cos(angle) * radius, 1.0, sin(angle) * radius)
	add_child(enemy)

func _on_game_over(won: bool) -> void:
	spawn_timer.stop()
	get_tree().paused = true
	var label = Label.new()
	label.text = "You Win!" if won else "Game Over"
	label.add_theme_font_size_override("font_size", 64)
	label.position = Vector2(400, 300)
	add_child(label)
