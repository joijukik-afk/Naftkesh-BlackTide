extends Node
## SquadManager - مدیریت یاران تیم
## فرمان‌ها، وضعیت یاران، و هماهنگی تاکتیکی را مدیریت می‌کند.

# ============================================================
# سیگنال‌ها
# ============================================================
signal squad_member_added(member_id: String)
signal squad_member_removed(member_id: String)
signal command_issued(command: String)
signal command_executed(command: String, member_id: String)
signal squad_member_downed(member_id: String)
signal squad_member_revived(member_id: String)
signal all_squad_downed

# ============================================================
# فرمان‌های تیم
# ============================================================
enum Command {
	FOLLOW_PLAYER,
	HOLD_POSITION,
	GUARD_OBJECTIVE,
	TAKE_COVER,
	MOVE_TO_MARKER,
	ASSIST_TEAMMATE,
	REVIVE_ALLY,
	RETREAT_TO_SAFE_ZONE,
	INVESTIGATE_EVENT,
	RETURN_TO_FORMATION
}

const COMMAND_NAMES: Dictionary = {
	Command.FOLLOW_PLAYER: "FOLLOW_PLAYER",
	Command.HOLD_POSITION: "HOLD_POSITION",
	Command.GUARD_OBJECTIVE: "GUARD_OBJECTIVE",
	Command.TAKE_COVER: "TAKE_COVER",
	Command.MOVE_TO_MARKER: "MOVE_TO_MARKER",
	Command.ASSIST_TEAMMATE: "ASSIST_TEAMMATE",
	Command.REVIVE_ALLY: "REVIVE_ALLY",
	Command.RETREAT_TO_SAFE_ZONE: "RETREAT_TO_SAFE_ZONE",
	Command.INVESTIGATE_EVENT: "INVESTIGATE_EVENT",
	Command.RETURN_TO_FORMATION: "RETURN_TO_FORMATION"
}

# ============================================================
# وضعیت جوخه
# ============================================================
var active_members: Array[String] = []
var member_nodes: Dictionary = {}  # member_id -> Node
var current_command: Command = Command.FOLLOW_PLAYER
var formation_radius: float = 4.0
var max_active_members: int = 3  # حداکثر یاران فعال برای بهینه‌سازی موبایل

# ============================================================
# توابع اولیه
# ============================================================
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_connect_dialogue()

func _connect_dialogue() -> void:
	if not DialogueSystem:
		return
	DialogueSystem.dialogue_finished.connect(_on_dialogue_finished)

# ============================================================
# مدیریت اعضا
# ============================================================
func add_member(member_id: String, node: Node = null) -> bool:
	if member_id in active_members:
		return false
	if active_members.size() >= max_active_members:
		push_warning("[SquadManager] جوخه پر است. حداکثر: " + str(max_active_members))
		return false
	
	active_members.append(member_id)
	if node:
		member_nodes[member_id] = node
	squad_member_added.emit(member_id)
	print("[SquadManager] عضو اضافه شد: ", member_id)
	return true

func remove_member(member_id: String) -> void:
	active_members.erase(member_id)
	member_nodes.erase(member_id)
	squad_member_removed.emit(member_id)

func clear_squad() -> void:
	active_members.clear()
	member_nodes.clear()

# ============================================================
# صدور فرمان
# ============================================================
func issue_command(command: Command) -> void:
	current_command = command
	command_issued.emit(COMMAND_NAMES[command])
	
	for member_id in active_members:
		if member_nodes.has(member_id) and is_instance_valid(member_nodes[member_id]):
			var member: Node = member_nodes[member_id]
			if member.has_method("receive_command"):
				member.receive_command(command)
			command_executed.emit(COMMAND_NAMES[command], member_id)
	
	_show_command_dialogue(command)
	print("[SquadManager] فرمان صادر شد: ", COMMAND_NAMES[command])

# ============================================================
# دیالوگ فرمان
# ============================================================
func _show_command_dialogue(command: Command) -> void:
	if not DialogueSystem or not DialogueData:
		return
	
	var orders: Dictionary = DialogueData.get_team_orders()
	var dialogue: Array = []
	
	match command:
		Command.FOLLOW_PLAYER:
			dialogue = orders.get("follow", [])
		Command.HOLD_POSITION, Command.GUARD_OBJECTIVE:
			dialogue = orders.get("hold", [])
		Command.MOVE_TO_MARKER, Command.INVESTIGATE_EVENT:
			dialogue = orders.get("attack", [])
		Command.RETREAT_TO_SAFE_ZONE:
			dialogue = orders.get("retreat", [])
		_:
			return
	
	if not dialogue.is_empty():
		DialogueSystem.start_dialogue("command_" + COMMAND_NAMES[command], dialogue)

func _on_dialogue_finished(_id: String) -> void:
	pass

# ============================================================
# مدیریت زمین‌گیری
# ============================================================
func notify_member_downed(member_id: String) -> void:
	squad_member_downed.emit(member_id)
	print("[SquadManager] عضو زمین‌گیر شد: ", member_id)
	
	# بررسی آیا همه زمین‌گیر شدند
	var all_downed: bool = true
	for member in active_members:
		if member_nodes.has(member) and is_instance_valid(member_nodes[member]):
			if member_nodes[member].has_method("is_downed") and not member_nodes[member].is_downed():
				all_downed = false
				break
	
	if all_downed:
		all_squad_downed.emit()

func notify_member_revived(member_id: String) -> void:
	squad_member_revived.emit(member_id)
	print("[SquadManager] عضو احیا شد: ", member_id)

# ============================================================
# موقعیت شکل‌بندی
# ============================================================
func get_formation_position(player_position: Vector3, member_index: int) -> Vector3:
	var angle: float = (TAU / max(active_members.size(), 1)) * member_index
	var offset: Vector3 = Vector3(cos(angle), 0, sin(angle)) * formation_radius
	return player_position + offset

func get_formation_positions(player_position: Vector3) -> Array[Vector3]:
	var positions: Array[Vector3] = []
	for i in range(active_members.size()):
		positions.append(get_formation_position(player_position, i))
	return positions

# ============================================================
# توابع کمکی
# ============================================================
func get_member_node(member_id: String) -> Node:
	return member_nodes.get(member_id, null)

func get_active_members() -> Array[String]:
	return active_members.duplicate()

func get_member_count() -> int:
	return active_members.size()

func has_member(member_id: String) -> bool:
	return member_id in active_members

func get_current_command() -> Command:
	return current_command
