extends Node
## SaveManager - سیستم ذخیره و بارگذاری
## ذخیره‌ی پیشرفت، تنظیمات، و وضعیت بازی با نسخه‌بندی.

# ============================================================
# سیگنال‌ها
# ============================================================
signal save_started(slot: int)
signal save_completed(slot: int, success: bool)
signal load_started(slot: int)
signal load_completed(slot: int, success: bool)
signal save_deleted(slot: int)

# ============================================================
# ثابت‌ها
# ============================================================
const SAVE_VERSION: int = 1
const SAVE_DIR: String = "user://saves/"
const MAX_SLOTS: int = 3
const AUTO_SAVE_SLOT: int = 0

# ============================================================
# توابع اولیه
# ============================================================
func _ready() -> void:
	_ensure_save_dir()

func _ensure_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func _get_save_path(slot: int) -> String:
	return SAVE_DIR + "save_" + str(slot) + ".sav"

# ============================================================
# ذخیره‌ی بازی
# ============================================================
func save_game(slot: int = 1) -> bool:
	save_started.emit(slot)
	
	var save_data: Dictionary = {
		"version": SAVE_VERSION,
		"timestamp": Time.get_datetime_string_from_system(),
		"playtime": _get_playtime(),
		"game": _collect_game_data(),
		"story": StoryManager.get_save_data() if StoryManager else {},
		"settings": _collect_settings_data()
	}
	
	var file: FileAccess = FileAccess.open(_get_save_path(slot), FileAccess.WRITE)
	if not file:
		push_error("[SaveManager] خطا در باز کردن فایل ذخیره: " + _get_save_path(slot))
		save_completed.emit(slot, false)
		return false
	
	var json_string: String = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	
	print("[SaveManager] بازی ذخیره شد در اسلات ", slot)
	save_completed.emit(slot, true)
	return true

# ============================================================
# بارگذاری بازی
# ============================================================
func load_game(slot: int = 1) -> bool:
	load_started.emit(slot)
	
	var path: String = _get_save_path(slot)
	if not FileAccess.file_exists(path):
		push_warning("[SaveManager] فایل ذخیره پیدا نشد: " + path)
		load_completed.emit(slot, false)
		return false
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("[SaveManager] خطا در باز کردن فایل: " + path)
		load_completed.emit(slot, false)
		return false
	
	var json_text: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	var parse_result: int = json.parse(json_text)
	if parse_result != OK:
		push_error("[SaveManager] خطا در تجزیه JSON: " + json.get_error_message())
		load_completed.emit(slot, false)
		return false
	
	var data: Variant = json.data
	if not data is Dictionary:
		push_error("[SaveManager] ساختار فایل ذخیره معتبر نیست")
		load_completed.emit(slot, false)
		return false
	
	# اعتبارسنجی نسخه
	var version: int = data.get("version", 0)
	if version > SAVE_VERSION:
		push_warning("[SaveManager] نسخه‌ی ذخیره جدیدتر است: ", version)
	
	_apply_game_data(data.get("game", {}))
	if StoryManager:
		StoryManager.load_save_data(data.get("story", {}))
	_apply_settings_data(data.get("settings", {}))
	
	print("[SaveManager] بازی بارگذاری شد از اسلات ", slot)
	load_completed.emit(slot, true)
	return true

# ============================================================
# حذف ذخیره
# ============================================================
func delete_save(slot: int) -> bool:
	var path: String = _get_save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		save_deleted.emit(slot)
		print("[SaveManager] ذخیره حذف شد: اسلات ", slot)
		return true
	return false

# ============================================================
# بررسی وجود ذخیره
# ============================================================
func save_exists(slot: int) -> bool:
	return FileAccess.file_exists(_get_save_path(slot))

func get_save_info(slot: int) -> Dictionary:
	var path: String = _get_save_path(slot)
	if not FileAccess.file_exists(path):
		return {}
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	
	var json_text: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	if json.parse(json_text) != OK:
		return {}
	
	var data: Variant = json.data
	if not data is Dictionary:
		return {}
	
	return {
		"timestamp": data.get("timestamp", "?"),
		"playtime": data.get("playtime", 0.0),
		"chapter": data.get("story", {}).get("current_chapter", 0),
		"version": data.get("version", 0)
	}

func get_all_saves() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for i in range(MAX_SLOTS):
		result.append(get_save_info(i))
	return result

# ============================================================
# جمع‌آوری داده
# ============================================================
func _collect_game_data() -> Dictionary:
	if not GameManager:
		return {}
	return {
		"player_health": GameManager.player_health,
		"max_health": GameManager.max_health,
		"ammo": GameManager.ammo,
		"max_ammo": GameManager.max_ammo,
		"reserve_ammo": GameManager.reserve_ammo,
		"score": GameManager.score,
		"kills": GameManager.kills
	}

func _apply_game_data(data: Dictionary) -> void:
	if not GameManager or data.is_empty():
		return
	GameManager.player_health = data.get("player_health", 100)
	GameManager.max_health = data.get("max_health", 100)
	GameManager.ammo = data.get("ammo", 30)
	GameManager.max_ammo = data.get("max_ammo", 30)
	GameManager.reserve_ammo = data.get("reserve_ammo", 120)
	GameManager.score = data.get("score", 0)
	GameManager.kills = data.get("kills", 0)

func _collect_settings_data() -> Dictionary:
	if not SettingsManager:
		return {}
	return {
		"music_volume": SettingsManager.music_volume,
		"sfx_volume": SettingsManager.sfx_volume,
		"voice_volume": SettingsManager.voice_volume,
		"graphics_quality": SettingsManager.graphics_quality,
		"language": SettingsManager.language
	}

func _apply_settings_data(data: Dictionary) -> void:
	if not SettingsManager or data.is_empty():
		return
	SettingsManager.music_volume = data.get("music_volume", 0.7)
	SettingsManager.sfx_volume = data.get("sfx_volume", 0.8)
	SettingsManager.voice_volume = data.get("voice_volume", 1.0)
	SettingsManager.graphics_quality = data.get("graphics_quality", 1)
	SettingsManager.language = data.get("language", "fa")

func _get_playtime() -> float:
	return Time.get_ticks_msec() / 1000.0

# ============================================================
# ذخیره‌ی خودکار
# ============================================================
func auto_save() -> bool:
	return save_game(AUTO_SAVE_SLOT)
