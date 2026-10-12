extends Node
## SettingsManager - مدیریت تنظیمات بازی
## این فایل تنظیمات صدا، گرافیک، کنترل و زبان را ذخیره و بارگذاری می‌کند.

# ============================================================
# سیگنال‌ها
# ============================================================
signal music_volume_changed(value: float)
signal sfx_volume_changed(value: float)
signal voice_volume_changed(value: float)
signal graphics_quality_changed(level: int)
signal camera_sensitivity_changed(value: float)
signal language_changed(lang: String)
signal vibration_changed(enabled: bool)

# ============================================================
# مسیر فایل ذخیره‌سازی
# ============================================================
const SETTINGS_PATH: String = "user://settings.cfg"

# ============================================================
# مقادیر تنظیمات
# ============================================================
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var voice_volume: float = 1.0
var graphics_quality: int = 1  # 0=Low, 1=Medium, 2=High
var camera_sensitivity: float = 0.5
var language: String = "fa"  # fa = فارسی, en = English
var vibration_enabled: bool = true
var show_subtitles: bool = true
var show_damage_numbers: bool = true

# ============================================================
# توابع اولیه
# ============================================================
func _ready() -> void:
	load_settings()
	apply_all_settings()

# ============================================================
# بارگذاری تنظیمات از فایل
# ============================================================
func load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: int = config.load(SETTINGS_PATH)
	
	if err != OK:
		print("[SettingsManager] فایل تنظیمات پیدا نشد، از مقادیر پیش‌فرض استفاده می‌شود.")
		save_settings()
		return
	
	music_volume = config.get_value("audio", "music_volume", 0.7)
	sfx_volume = config.get_value("audio", "sfx_volume", 0.8)
	voice_volume = config.get_value("audio", "voice_volume", 1.0)
	graphics_quality = config.get_value("graphics", "quality", 1)
	camera_sensitivity = config.get_value("controls", "camera_sensitivity", 0.5)
	language = config.get_value("general", "language", "fa")
	vibration_enabled = config.get_value("controls", "vibration", true)
	show_subtitles = config.get_value("ui", "show_subtitles", true)
	show_damage_numbers = config.get_value("ui", "show_damage_numbers", true)
	
	print("[SettingsManager] تنظیمات بارگذاری شد.")

# ============================================================
# ذخیره تنظیمات در فایل
# ============================================================
func save_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "voice_volume", voice_volume)
	config.set_value("graphics", "quality", graphics_quality)
	config.set_value("controls", "camera_sensitivity", camera_sensitivity)
	config.set_value("controls", "vibration", vibration_enabled)
	config.set_value("general", "language", language)
	config.set_value("ui", "show_subtitles", show_subtitles)
	config.set_value("ui", "show_damage_numbers", show_damage_numbers)
	
	var err: int = config.save(SETTINGS_PATH)
	if err == OK:
		print("[SettingsManager] تنظیمات ذخیره شد.")
	else:
		push_error("[SettingsManager] خطا در ذخیره تنظیمات!")

# ============================================================
# اعمال تمام تنظیمات
# ============================================================
func apply_all_settings() -> void:
	music_volume_changed.emit(music_volume)
	sfx_volume_changed.emit(sfx_volume)
	voice_volume_changed.emit(voice_volume)
	graphics_quality_changed.emit(graphics_quality)
	camera_sensitivity_changed.emit(camera_sensitivity)
	language_changed.emit(language)
	vibration_changed.emit(vibration_enabled)

# ============================================================
# تنظیم صداها
# ============================================================
func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	music_volume_changed.emit(music_volume)
	save_settings()

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	sfx_volume_changed.emit(sfx_volume)
	save_settings()

func set_voice_volume(value: float) -> void:
	voice_volume = clampf(value, 0.0, 1.0)
	voice_volume_changed.emit(voice_volume)
	save_settings()

# ============================================================
# تنظیمات گرافیک
# ============================================================
func set_graphics_quality(level: int) -> void:
	graphics_quality = clampi(level, 0, 2)
	_apply_graphics_quality()
	graphics_quality_changed.emit(graphics_quality)
	save_settings()

func _apply_graphics_quality() -> void:
	match graphics_quality:
		0:  # Low
			RenderingServer.directional_shadow_atlas_set_size(512, true)
			RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_DISABLED)
		1:  # Medium
			RenderingServer.directional_shadow_atlas_set_size(1024, true)
			RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_DISABLED)
		2:  # High
			RenderingServer.directional_shadow_atlas_set_size(2048, true)
			RenderingServer.viewport_set_msaa_3d(get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_MSAA_2X)

# ============================================================
# تنظیمات کنترل
# ============================================================
func set_camera_sensitivity(value: float) -> void:
	camera_sensitivity = clampf(value, 0.1, 2.0)
	camera_sensitivity_changed.emit(camera_sensitivity)
	save_settings()

func set_vibration(enabled: bool) -> void:
	vibration_enabled = enabled
	vibration_changed.emit(vibration_enabled)
	save_settings()

# ============================================================
# تنظیمات زبان
# ============================================================
func set_language(lang: String) -> void:
	language = lang
	TranslationServer.set_locale(lang)
	language_changed.emit(language)
	save_settings()

# ============================================================
# تنظیمات رابط کاربری
# ============================================================
func set_show_subtitles(value: bool) -> void:
	show_subtitles = value
	save_settings()

func set_show_damage_numbers(value: bool) -> void:
	show_damage_numbers = value
	save_settings()
