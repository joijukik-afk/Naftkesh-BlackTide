extends Area3D
## Bullet - گلوله
## حرکت، برخورد، آسیب و افکت‌های بصری.

# ============================================================
# سیگنال‌ها
# ============================================================
signal hit_target(target: Node)
signal hit_wall(position: Vector3, normal: Vector3)

# ============================================================
# پارامترها
# ============================================================
@export var speed: float = 60.0
@export var damage: int = 15
@export var lifetime: float = 3.0
@export var is_player_bullet: bool = true
@export var knockback_force: float = 2.0

# ============================================================
# وضعیت
# ============================================================
var direction: Vector3 = Vector3.FORWARD
var time_alive: float = 0.0

# ============================================================
# گره‌ها
# ============================================================
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D if has_node("MeshInstance3D") else null
@onready var collision_shape: CollisionShape3D = $CollisionShape3D if has_node("CollisionShape3D") else null

# ============================================================
# توابع اولیه
# ============================================================
func _ready() -> void:
	# اتصال سیگنال‌ها
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# جهت‌گیری اولیه
	if direction.length() > 0.01:
		look_at(global_position + direction, Vector3.UP)

func _exit_tree() -> void:
	pass

# ============================================================
# حرکت
# ============================================================
func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	time_alive += delta
	
	if time_alive >= lifetime:
		queue_free()

# ============================================================
# تنظیم جهت
# ============================================================
func set_direction(new_direction: Vector3) -> void:
	direction = new_direction.normalized()
	if direction.length() > 0.01:
		look_at(global_position + direction, Vector3.UP)

func set_shooter(is_player: bool) -> void:
	is_player_bullet = is_player

func set_damage(amount: int) -> void:
	damage = amount

# ============================================================
# برخورد با اجسام
# ============================================================
func _on_body_entered(body: Node3D) -> void:
	if body == null:
		return
	
	# اگر به بازیکن برخورد کرد و گلوله دشمن است
	if is_player_bullet:
		if body.is_in_group("enemies"):
			_hit_enemy(body)
		else:
			_hit_environment(body)
	else:
		if body.is_in_group("player"):
			_hit_player(body)
		else:
			_hit_environment(body)

func _on_area_entered(area: Area3D) -> void:
	# برای برخورد با سایر Area‌ها (مثلاً ذرات)
	pass

# ============================================================
# برخورد با دشمن
# ============================================================
func _hit_enemy(enemy: Node) -> void:
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)
	hit_target.emit(enemy)
	_spawn_hit_effect(global_position, Vector3.UP, "hit_flesh")
	queue_free()

# ============================================================
# برخورد با بازیکن
# ============================================================
func _hit_player(player: Node) -> void:
	if player.has_method("take_damage"):
		player.take_damage(damage)
	hit_target.emit(player)
	_spawn_hit_effect(global_position, Vector3.UP, "hit_flesh")
	queue_free()

# ============================================================
# برخورد با محیط
# ============================================================
func _hit_environment(body: Node) -> void:
	# پیدا کردن نرمال سطح
	var normal: Vector3 = -direction
	
	# تشخیص نوع سطح
	var sfx_name: String = "hit_wall"
	if body.name.to_lower().contains("metal") or body.name.to_lower().contains("iron"):
		sfx_name = "hit_metal"
	
	_spawn_hit_effect(global_position, normal, sfx_name)
	hit_wall.emit(global_position, normal)
	queue_free()

# ============================================================
# افکت برخورد
# ============================================================
func _spawn_hit_effect(position: Vector3, normal: Vector3, sfx_name: String) -> void:
	# صدا
	if AudioManager:
		AudioManager.play_sfx(sfx_name)
	
	# ذرات اثر
	_spawn_particles(position, normal)

func _spawn_particles(position: Vector3, normal: Vector3) -> void:
	var particles: GPUParticles3D = GPUParticles3D.new()
	var material: ParticleProcessMaterial = ParticleProcessMaterial.new()
	
	material.direction = normal
	material.spread = 45.0
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 5.0
	material.gravity = Vector3(0, -9.8, 0)
	material.scale_min = 0.05
	material.scale_max = 0.15
	material.color = Color(1.0, 0.8, 0.2)
	material.lifetime_randomness = 0.3
	
	particles.process_material = material
	particles.amount = 8
	particles.lifetime = 0.5
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.global_position = position
	
	# اضافه کردن به صحنه
	var scene: Node = get_tree().current_scene
	if scene:
		scene.add_child(particles)
		particles.emitting = true
		
		# حذف پس از پایان
		await get_tree().create_timer(1.0).timeout
		if is_instance_valid(particles):
			particles.queue_free()

# ============================================================
# توابع کمکی
# ============================================================
func get_damage() -> int:
	return damage

func get_direction() -> Vector3:
	return direction

func get_time_alive() -> float:
	return time_alive
