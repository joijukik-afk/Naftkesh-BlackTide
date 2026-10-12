extends Node
## StoryManager - مدیریت پیشرفت داستان
## فصل‌ها، انتخاب‌های بازیکن، و مسیر داستان را مدیریت می‌کند.

# ============================================================
# سیگنال‌ها
# ============================================================
signal chapter_started(chapter_id: int)
signal chapter_completed(chapter_id: int)
signal story_flag_set(flag_name: String, value: Variant)
signal choice_recorded(choice_id: String, choice_value: String)

# ============================================================
# شماره‌گذاری فصل‌ها
# ============================================================
enum Chapter { NONE, DEAD_WATER, SILENT_ENGINE, GHOST_PLATFORM, BLACK_TIDE }

const CHAPTER_NAMES: Dictionary = {
	Chapter.DEAD_WATER: "DEAD WATER",
	Chapter.SILENT_ENGINE: "SILENT ENGINE",
	Chapter.GHOST_PLATFORM: "GHOST PLATFORM",
	Chapter.BLACK_TIDE: "BLACK TIDE"
}

# ============================================================
# وضعیت داستان
# ============================================================
var current_chapter: Chapter = Chapter.NONE
var current_mission: int = 0
var completed_missions: Array[int] = []
var story_flags: Dictionary = {}
var player_choices: Dictionary = {}

# اطلاعات تیم - وضعیت هر شخصیت
var team_status: Dictionary = {
	"Nargil": {"alive": true, "available": true, "trust": 50},
	"KhalfKarAsli": {"alive": true, "available": true, "trust": 50},
	"AmirAlavi": {"alive": true, "available": true, "trust": 50},
	"Best Time Kabir": {"alive": true, "available": true, "trust": 50},
	"Captain": {"alive": true, "available": true, "trust": 50},
	"Kasra": {"alive": true, "available": true, "trust": 50},
	"Shakeri": {"alive": true, "available": true, "trust": 50},
	"Jalil": {"alive": true, "available": true, "trust": 50},
	"Bacteria": {"alive": true, "available": true, "trust": 50},
	"SeedRoy": {"alive": true, "available": true, "trust": 50},
	"Ananas": {"alive": true, "available": true, "trust": 50},
	"Alififa": {"alive": true, "available": true, "trust": 50},
	"Nima": {"alive": true, "available": true, "trust": 50},
	"Saeed": {"alive": true, "available": true, "trust": 50},
	"Yggdrasi_KS": {"alive": true, "available": true, "trust": 50}
}

# ============================================================
# توابع اولیه
# ============================================================
func _ready() -> void:
	reset_story()

func reset_story() -> void:
	current_chapter = Chapter.NONE
	current_mission = 0
	completed_missions.clear()
	story_flags.clear()
	player_choices.clear()
	for member in team_status.keys():
		team_status[member]["alive"] = true
		team_status[member]["available"] = true
		team_status[member]["trust"] = 50

# ============================================================
# مدیریت فصل‌ها
# ============================================================
func start_chapter(chapter: Chapter) -> void:
	current_chapter = chapter
	current_mission = 0
	chapter_started.emit(chapter)
	print("[StoryManager] شروع فصل: ", CHAPTER_NAMES.get(chapter, "?"))

func complete_chapter(chapter: Chapter) -> void:
	chapter_completed.emit(chapter)
	print("[StoryManager] پایان فصل: ", CHAPTER_NAMES.get(chapter, "?"))
	if chapter < Chapter.BLACK_TIDE:
		start_chapter((chapter + 1) as Chapter)

func get_chapter_name(chapter_id: int = -1) -> String:
	var ch: Chapter = current_chapter if chapter_id < 0 else chapter_id as Chapter
	return CHAPTER_NAMES.get(ch, "UNKNOWN")

# ============================================================
# مدیریت مأموریت
# ============================================================
func complete_mission(mission_id: int) -> void:
	if mission_id not in completed_missions:
		completed_missions.append(mission_id)
	current_mission = mission_id + 1

func is_mission_completed(mission_id: int) -> bool:
	return mission_id in completed_missions

# ============================================================
# پرچم‌های داستانی
# ============================================================
func set_flag(flag_name: String, value: Variant = true) -> void:
	story_flags[flag_name] = value
	story_flag_set.emit(flag_name, value)

func get_flag(flag_name: String, default_value: Variant = false) -> Variant:
	return story_flags.get(flag_name, default_value)

func has_flag(flag_name: String) -> bool:
	return story_flags.has(flag_name)

# ============================================================
# انتخاب‌های بازیکن
# ============================================================
func record_choice(choice_id: String, choice_value: String) -> void:
	player_choices[choice_id] = choice_value
	choice_recorded.emit(choice_id, choice_value)
	print("[StoryManager] انتخاب ثبت شد: ", choice_id, " = ", choice_value)

func get_choice(choice_id: String, default_value: String = "") -> String:
	return player_choices.get(choice_id, default_value)

# ============================================================
# وضعیت تیم
# ============================================================
func set_team_member_status(member: String, alive: bool, available: bool) -> void:
	if team_status.has(member):
		team_status[member]["alive"] = alive
		team_status[member]["available"] = available

func is_member_alive(member: String) -> bool:
	if team_status.has(member):
		return team_status[member]["alive"]
	return false

func is_member_available(member: String) -> bool:
	if team_status.has(member):
		return team_status[member]["alive"] and team_status[member]["available"]
	return false

func change_trust(member: String, amount: int) -> void:
	if team_status.has(member):
		var new_trust: int = clampi(team_status[member]["trust"] + amount, 0, 100)
		team_status[member]["trust"] = new_trust

func get_trust(member: String) -> int:
	if team_status.has(member):
		return team_status[member]["trust"]
	return 0

# ============================================================
# ذخیره و بارگذاری
# ============================================================
func get_save_data() -> Dictionary:
	return {
		"current_chapter": current_chapter,
		"current_mission": current_mission,
		"completed_missions": completed_missions.duplicate(),
		"story_flags": story_flags.duplicate(),
		"player_choices": player_choices.duplicate(),
		"team_status": team_status.duplicate(true)
	}

func load_save_data(data: Dictionary) -> void:
	current_chapter = data.get("current_chapter", Chapter.NONE)
	current_mission = data.get("current_mission", 0)
	completed_missions = data.get("completed_missions", [])
	story_flags = data.get("story_flags", {})
	player_choices = data.get("player_choices", {})
	team_status = data.get("team_status", team_status)
	print("[StoryManager] داستان بارگذاری شد: ", get_chapter_name())
