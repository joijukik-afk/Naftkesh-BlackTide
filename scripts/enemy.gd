extends CharacterBody3D
## Enemy - دشمن پایه (Raider)
## هوش مصنوعی با ماشین حالت: Patrol → Investigate → Alert → Engage → Cover → Retreat

# ============================================================
# سیگنال‌ها
# ============================================================
signal state_changed(new_state: int)
signal player_spotted()
signal player_lost()
signal damaged(amount: int)
signal died()

# ============================================================
# شمارش حالت‌ها
# ============================================================
enum State {
	PATROL,
	INVESTIGATE,
	ALERT,
	ENGAGE,
	SEEK_COVER,
	REPOSITION,
	RETREAT,
	SEARCH_LAST_KNOWN,
	DEFEATED
}

const STATE_NAMES: Dictionary = {
	State.PATROL: "Patrol",
	State.INVESTIGATE: "Investigate",
	State.ALERT: "Alert",
	State.ENGAGE: "Engage",
	State.SEEK_COVER: "SeekCover",
	State.REPOSITION: "Reposition",
	State.RETREAT: "Retreat",
	State.SEARCH_LAST_KNOWN: "SearchLastKnown",
	State.DEFEATED: "Defeated"
}

# ============================================================
# نوع دشمن
# ============================================================
enum EnemyType {
	RAIDER,
	DECKBREAKER,
	GHOST_RECON,
	SEA_VIPER,
	IRON_WAKE,
	WARDEN
}

# ============================================================
# پارامترها
# ============================================================
@export_group("Stats")
@export var enemy_type: EnemyType = EnemyType.RAIDER
@export var enemy_name: String = "Raider"
@export var max_health: int = 50
@export var walk_speed: float = 1.5
@export var run_speed: float = 4.5
@export var damage: int = 10
@export var attack_range: float = 2.5
@export var attack_cooldown: float = 1.5

@export_group("Perception")
@export var vision_range: float = 25.0
@export var vision_angle: float = 90.0
@export var hearing_range: float = 15.0
@export var memory_duration: float = 8.0

@export_group("Weapon")
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.8
@export var fire_range: float = 20.0

@export_group("Patrol")
@export var patrol_points: Array[NodePath] = []

# ============================================================
# گره‌ها
# ============================================================
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var muzzle: Marker3D = $Muzzle if has_node("Muzzle") else null

# ============================================================
# وضعیت
# ============================================================
var state: State = State.PATROL
var health: int = 50
var player: Node3D = null
var last_known_player_position: Vector3 = Vector3.ZERO
var memory_timer: float = 0.0
var attack_timer: float = 0.0
var can_attack: bool = true
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 24.0)
var patrol_index: int = 0
var patrol_wait_timer: float = 0.0
var state_timer: float = 0.0
var is_dead: bool = false

# ============================================================
# توابع اولیه
# ============================================================
func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	_apply_type_stats()
	
	# پیدا کردن بازیکن
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player") as Node3D
	
	print("[Enemy] ", enemy_name, " آماده شد. جان: ", health)

func _apply_type_stats() -> void:
	match enemy_type:
		EnemyType.RAIDER:
			enemy_name = "Raider"
			max_health = 50
			damage = 10
			walk_speed = 1.5
			run_speed = 4.5
		EnemyType.DECKBREAKER:
			enemy_name = "Deckbreaker"
			max_health = 200
			damage = 25
			walk_speed = 1.0
			run_speed = 3.0
		EnemyType.GHOST_RECON:
			enemy_name = "Ghost Recon"
			max_health = 35
			damage = 8
			walk_speed = 2.0
			run_speed = 5.5
		EnemyType.SEA_VIPER:
			enemy_name = "Sea Viper"
			max_health = 40
			damage = 12
			walk_speed = 1.8
			run_speed = 6.0
		EnemyType.IRON_WAKE:
			enemy_name = "Iron Wake"
			max_health = 300
			damage = 30
			walk_speed = 1.2
			run_speed = 3.5
		EnemyType.WARDEN:
			enemy_name = "Warden"
			max_health = 500
			damage = 40
			walk_speed = 1.5
			run_speed = 4.0
	
	health = max_health

# ============================================================
# فیزیک
# ============================================================
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# تایمرها
	memory_timer = max(0.0, memory_timer - delta)
	attack_timer = max(0.0, attack_timer - delta)
	state_timer += delta
	
	# اجرای حالت فعلی
	_update_state(delta)
	
	move_and_slide()

# ============================================================
# ماشین حالت
# ============================================================
func _update_state(delta: float) -> void:
	match state:
		State.PATROL: _state_patrol(delta)
		State.INVESTIGATE: _state_investigate(delta)
		State.ALERT: _state_alert(delta)
		State.ENGAGE: _state_engage(delta)
		State.SEEK_COVER: _state_seek_cover(delta)
		State.REPOSITION: _state_reposition(delta)
		State.RETREAT: _state_retreat(delta)
		State.SEARCH_LAST_KNOWN: _state_search_last_known(delta)

func change_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state
	state_timer = 0.0
	state_changed.emit(new_state)
	print("[Enemy:", enemy_name, "] حالت: ", STATE_NAMES[new_state])

# ============================================================
# حالت‌ها
# ============================================================
func _state_patrol(delta: float) -> void:
	if _can_see_player():
		change_state(State.ENGAGE)
		return
	
	# حرکت بین نقاط گشت
	if patrol_points.is_empty():
		# بدون نقطه گشت، ثابت بمون
		velocity.x = move_toward(velocity.x, 0, 10.0 * delta)
		velocity.z = move_toward(velocity.z, 0, 10.0 * delta)
		return
	
	if patrol_wait_timer > 0:
		patrol_wait_timer -= delta
		velocity.x = move_toward(velocity.x, 0, 10.0 * delta)
		velocity.z = move_toward(velocity.z, 0, 10.0 * delta)
		return
	
	var target_path: NodePath = patrol_points[patrol_index]
	var target: Node = get_node_or_null(target_path)
	if not target:
		patrol_index = (patrol_index + 1) % patrol_points.size()
		return
	
	var direction: Vector3 = target.global_position - global_position
	direction.y = 0
	
	if direction.length() < 1.5:
		patrol_wait_timer = 2.0
		patrol_index = (patrol_index + 1) % patrol_points.size()
		return
	
	direction = direction.normalized()
	velocity.x = direction.x * walk_speed
	velocity.z = direction.z * walk_speed
	_look_at_direction(direction)

func _state_investigate(delta: float) -> void:
	if _can_see_player():
		change_state(State.ENGAGE)
		return
	
	var direction: Vector3 = last_known_player_position - global_position
	direction.y = 0
	
	if direction.length() < 1.5:
		# به مقصد رسید، جستجو کن
		change_state(State.SEARCH_LAST_KNOWN)
		return
	
	direction = direction.normalized()
	velocity.x = direction.x * walk_speed * 1.3
	velocity.z = direction.z * walk_speed * 1.3
	_look_at_direction(direction)

func _state_alert(delta: float) -> void:
	# چرخش به اطراف و آماده باش
	velocity.x = move_toward(velocity.x, 0, 10.0 * delta)
	velocity.z = move_toward(velocity.z, 0, 10.0 * delta)
	rotate_y(delta * 1.5)
	
	if _can_see_player():
		change_state(State.ENGAGE)
		return
	
	if state_timer > 3.0:
		change_state(State.PATROL)

func _state_engage(delta: float) -> void:
	if not player or not is_instance_valid(player):
		change_state(State.PATROL)
		return
	
	var to_player: Vector3 = player.global_position - global_position
	to_player.y = 0
	var distance: float = to_player.length()
	
	# اگر دیدیم، آخرین موقعیت رو ذخیره کن
	if _can_see_player():
		last_known_player_position = player.global_position
		memory_timer = memory_duration
	else:
		# بازیکن رو گم کردیم
		if memory_timer <= 0.0:
			change_state(State.SEARCH_LAST_KNOWN)
			return
	
	# چرخش به سمت بازیکن
	if distance > 0.1:
		_look_at_direction(to_player.normalized())
	
	# اگر دور بود، به سمت بازیکن بدو
	if distance > attack_range:
		var direction: Vector3 = to_player.normalized()
		velocity.x = direction.x * run_speed
		velocity.z = direction.z * run_speed
	else:
		# نزدیک، حمله کن
		velocity.x = move_toward(velocity.x, 0, 15.0 * delta)
		velocity.z = move_toward(velocity.z, 0, 15.0 * delta)
		if can_attack and attack_timer <= 0.0:
			_attack()

func _state_seek_cover(delta: float) -> void:
	# به دنبال نزدیک‌ترین پوشش
	velocity.x = move_toward(velocity.x, 0, 10.0 * delta)
	velocity.z = move_toward(velocity.z, 0, 10.0 * delta)
	
	if state_timer > 2.0:
		if _can_see_player():
			change_state(State.ENGAGE)
		else:
			change_state(State.SEARCH_LAST_KNOWN)

func _state_reposition(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 8.0 * delta)
	velocity.z = move_toward(velocity.z, 0, 8.0 * delta)
	
	if state_timer > 1.5:
		change_state(State.ENGAGE)

func _state_retreat(delta: float) -> void:
	if not player or not is_instance_valid(player):
		change_state(State.PATROL)
		return
	
	# دور شدن از بازیکن
	var direction: Vector3 = (global_position - player.global_position).normalized()
	velocity.x = direction.x * run_speed * 1.2
	velocity.z = direction.z * run_speed * 1.2
	_look_at_direction(-direction)
	
	if state_timer > 5.0:
		change_state(State.SEARCH_LAST_KNOWN)

func _state_search_last_known(delta: float) -> void:
	var direction: Vector3 = last_known_player_position - global_position
	direction.y = 0
	
	if direction.length() > 1.5:
		direction = direction.normalized()
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
		_look_at_direction(direction)
	else:
		# در محل جستجو کن
		velocity.x = move_toward(velocity.x, 0, 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0, 8.0 * delta)
		rotate_y(delta * 2.0)
		
		if state_timer > 4.0:
			change_state(State.PATROL)
	
	if _can_see_player():
		change_state(State.ENGAGE)

# ============================================================
# درک محیط
# ============================================================
func _can_see_player() -> bool:
	if not player or not is_instance_valid(player):
		return false
	
	var to_player: Vector3 = player.global_position - global_position
	var distance: float = to_player.length()
	
	if distance > vision_range:
		return false
	
	# بررسی زاویه دید
	var forward: Vector3 = -global_transform.basis.z
	var angle_to_player: float = rad_to_deg(forward.angle_to(to_player.normalized()))
	if angle_to_player > vision_angle / 2.0:
		return false
	
	# بررسی خط دید (Raycast)
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		global_position + Vector3(0, 1.5, 0),
		player.global_position + Vector3(0, 1.0, 0)
	)
	query.exclude = [self]
	var result: Dictionary = space_state.intersect_ray(query)
	
	if result.is_empty():
		return true
	
	var collider: Node = result.get("collider")
	return collider == player

# ============================================================
# حمله
# ============================================================
func _attack() -> void:
	can_attack = false
	attack_timer = attack_cooldown
	
	if not player or not is_instance_valid(player):
		can_attack = true
		return
	
	# اگر سلاح دارد، شلیک کن
	if bullet_scene and muzzle and global_position.distance_to(player.global_position) > attack_range:
		_shoot()
	else:
		# حمله نزدیک
		if player.has_method("take_damage"):
			player.take_damage(damage)
	
	if AudioManager:
		AudioManager.play_sfx("gunshot_pistol")
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _shoot() -> void:
	if not bullet_scene or not muzzle:
		return
	
	var bullet: Node3D = bullet_scene.instantiate() as Node3D
	if not bullet:
		return
	
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	
	var target_position: Vector3 = player.global_position + Vector3(0, 1.0, 0)
	var direction: Vector3 = (target_position - muzzle.global_position).normalized()
	
	if bullet.has_method("set_direction"):
		bullet.set_direction(direction)
	elif "direction" in bullet:
		bullet.direction = direction

# ============================================================
# آسیب و مرگ
# ============================================================
func take_damage(amount: int) -> void:
	if is_dead:
		return
	health = max(0, health - amount)
	damaged.emit(amount)
	
	# اگر آسیب دید، حالت رو تغییر بده
	if state == State.PATROL or state == State.INVESTIGATE:
		if player and is_instance_valid(player):
			last_known_player_position = player.global_position
			change_state(State.ENGAGE)
	
	# اگر جان کم شد، عقب‌نشینی
	if health < max_health * 0.25 and state != State.RETREAT:
		change_state(State.RETREAT)
	
	if health <= 0:
		_die()

func _die() -> void:
	if is_dead:
		return
	is_dead = true
	change_state(State.DEFEATED)
	died.emit()
	
	if GameManager:
		GameManager.register_kill(enemy_name)
	
	# حذف پس از تاخیر
	await get_tree().create_timer(0.5).timeout
	queue_free()

# ============================================================
# توابع کمکی
# ============================================================
func _look_at_direction(direction: Vector3) -> void:
	if direction.length() < 0.01:
		return
	var target_position: Vector3 = global_position + direction
	var target: Vector3 = Vector3(target_position.x, global_position.y, target_position.z)
	if global_position.distance_to(target) > 0.1:
		look_at(target, Vector3.UP)

func get_health() -> int:
	return health

func get_health_percent() -> float:
	return float(health) / float(max_health)

func is_enemy_dead() -> bool:
	return is_dead

func get_state_name() -> String:
	return STATE_NAMES.get(state, "Unknown")

func force_alert(position: Vector3) -> void:
	last_known_player_position = position
	if state == State.PATROL:
		change_state(State.INVESTIGATE)
