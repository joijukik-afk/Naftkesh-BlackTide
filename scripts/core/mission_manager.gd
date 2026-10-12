extends Node
## MissionManager - مدیریت مأموریت‌ها
## اهداف، پیشرفت، پیروزی و شکست مأموریت‌ها را کنترل می‌کند.

# ============================================================
# سیگنال‌ها
# ============================================================
signal mission_started(mission_id: String, mission_name: String)
signal mission_completed(mission_id: String, success: bool)
signal objective_added(objective_id: String, text: String, is_primary: bool)
signal objective_completed(objective_id: String)
signal objective_failed(objective_id: String)
signal objective_updated(objective_id: String, progress: float)
signal all_objectives_completed
signal mission_failed(reason: String)

# ============================================================
# ساختار مأموریت
# ============================================================
class Objective:
	var id: String
	var text: String
	var is_primary: bool
	var is_completed: bool
	var is_failed: bool
	var is_optional: bool
	var progress: float
	var target_count: int
	var current_count: int
	
	func _init(p_id: String, p_text: String, p_primary: bool, p_target: int = 1) -> void:
		id = p_id
		text = p_text
		is_primary = p_primary
		is_completed = false
		is_failed = false
		is_optional = not p_primary
		progress = 0.0
		target_count = p_target
		current_count = 0

# ============================================================
# وضعیت مأموریت فعلی
# ============================================================
var current_mission_id: String = ""
var current_mission_name: String = ""
var current_objectives: Array[Objective] = []
var is_mission_active: bool = false
var mission_start_time: float = 0.0

# ============================================================
# توابع اولیه
# ============================================================
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

# ============================================================
# شروع مأموریت
# ============================================================
func start_mission(mission_id: String, mission_name: String) -> void:
	current_mission_id = mission_id
	current_mission_name = mission_name
	current_objectives.clear()
	is_mission_active = true
	mission_start_time = Time.get_ticks_msec() / 1000.0
	mission_started.emit(mission_id, mission_name)
	print("[MissionManager] مأموریت شروع شد: ", mission_name)

# ============================================================
# پایان مأموریت
# ============================================================
func complete_mission(success: bool = true) -> void:
	if not is_mission_active:
		return
	is_mission_active = false
	mission_completed.emit(current_mission_id, success)
	print("[MissionManager] مأموریت ", "موفق" if success else "ناموفق", ": ", current_mission_name)

# ============================================================
# مدیریت اهداف
# ============================================================
func add_objective(objective_id: String, text: String, is_primary: bool = true, target_count: int = 1) -> void:
	var obj: Objective = Objective.new(objective_id, text, is_primary, target_count)
	current_objectives.append(obj)
	objective_added.emit(objective_id, text, is_primary)
	print("[MissionManager] هدف اضافه شد: ", text)

func update_objective_progress(objective_id: String, amount: int = 1) -> void:
	for obj in current_objectives:
		if obj.id == objective_id and not obj.is_completed and not obj.is_failed:
			obj.current_count += amount
			obj.progress = float(obj.current_count) / float(obj.target_count)
			objective_updated.emit(objective_id, obj.progress)
			if obj.current_count >= obj.target_count:
				_complete_objective(obj)
			return

func complete_objective(objective_id: String) -> void:
	for obj in current_objectives:
		if obj.id == objective_id and not obj.is_completed:
			_complete_objective(obj)
			return

func _complete_objective(obj: Objective) -> void:
	obj.is_completed = true
	obj.progress = 1.0
	objective_completed.emit(obj.id)
	print("[MissionManager] هدف کامل شد: ", obj.text)
	_check_all_objectives()

func fail_objective(objective_id: String) -> void:
	for obj in current_objectives:
		if obj.id == objective_id and not obj.is_failed:
			obj.is_failed = true
			objective_failed.emit(obj.id)
			print("[MissionManager] هدف شکست خورد: ", obj.text)
			if obj.is_primary:
				fail_mission("هدف اصلی شکست خورد: " + obj.text)
			return

func _check_all_objectives() -> void:
	for obj in current_objectives:
		if obj.is_primary and not obj.is_completed:
			return
	all_objectives_completed.emit()
	complete_mission(true)

# ============================================================
# شکست مأموریت
# ============================================================
func fail_mission(reason: String = "") -> void:
	if not is_mission_active:
		return
	is_mission_active = false
	mission_failed.emit(reason)
	mission_completed.emit(current_mission_id, false)
	print("[MissionManager] مأموریت شکست خورد: ", reason)

# ============================================================
# توابع کمکی
# ============================================================
func get_objective(objective_id: String) -> Objective:
	for obj in current_objectives:
		if obj.id == objective_id:
			return obj
	return null

func get_mission_time() -> float:
	if not is_mission_active:
		return 0.0
	return (Time.get_ticks_msec() / 1000.0) - mission_start_time

func get_primary_objectives() -> Array[Objective]:
	var result: Array[Objective] = []
	for obj in current_objectives:
		if obj.is_primary:
			result.append(obj)
	return result

func get_optional_objectives() -> Array[Objective]:
	var result: Array[Objective] = []
	for obj in current_objectives:
		if obj.is_optional:
			result.append(obj)
	return result

func clear_mission() -> void:
	current_mission_id = ""
	current_mission_name = ""
	current_objectives.clear()
	is_mission_active = false

# ============================================================
# مأموریت‌های آماده فصل اول
# ============================================================
func start_chapter_1_mission_1() -> void:
	start_mission("ch1_m1", "DEAD WATER - بیداری")
	add_objective("reach_deck", "به عرشه اصلی برس", true)
	add_objective("eliminate_raiders", "۵ مهاجم را از بین ببر", true, 5)
	add_objective("save_crew", "خدمه را نجات بده", false)

func start_chapter_1_mission_2() -> void:
	start_mission("ch1_m2", "DEAD WATER - دفاع")
	add_objective("defend_bridge", "از پل فرماندهی دفاع کن", true)
	add_objective("restore_power", "برق پشتیبان را فعال کن", true)
	add_objective("find_spy_clue", "سرنخ جاسوس را پیدا کن", false)
