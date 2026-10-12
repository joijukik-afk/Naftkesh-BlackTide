extends Node3D

@onready var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	GameManager.reset()
	GameManager.game_over.connect(_on_game_over)
	
	_setup_environment()
	
	spawn_timer.timeout.connect(_spawn_enemy)
	spawn_timer.start(3.0)
	for i in range(3):
		_spawn_enemy()

func _setup_environment() -> void:
	var positions = [
		Vector3(8, 1, 8), Vector3(-8, 1, 8), Vector3(8, 1, -8),
		Vector3(-8, 1, -8), Vector3(5, 0.5, -5), Vector3(-5, 0.5, 5),
		Vector3(12, 1, 0), Vector3(-12, 1, 0), Vector3(0, 1, -12), Vector3(0, 1, 12)
	]
	for pos in positions:
		var box = StaticBody3D.new()
		var mesh = MeshInstance3D.new()
		var bm = BoxMesh.new()
		bm.size = Vector3(2, 2, 2)
		mesh.mesh = bm
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.35, 0.25, 0.2)
		mesh.material_override = mat
		box.add_child(mesh)
		var col = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = Vector3(2, 2, 2)
		col.shape = shape
		box.add_child(col)
		box.position = pos
		add_child(box)

func _spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	var angle = randf() * TAU
	var radius = randf_range(10.0, 18.0)
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
