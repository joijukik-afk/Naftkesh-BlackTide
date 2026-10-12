extends Node
## DialogueSystem - سیستم مدیریت دیالوگ
## نمایش و پیشروی دیالوگ‌ها، اتصال به صدا، و مدیریت انتخاب‌های بازیکن.

# ============================================================
# سیگنال‌ها
# ============================================================
signal dialogue_started(dialogue_id: String)
signal dialogue_line_shown(speaker: String, text: String, portrait: String)
signal dialogue_advanced(current_index: int, total: int)
signal dialogue_finished(dialogue_id: String)
signal dialogue_choice_requested(choices: Array)
signal dialogue_choice_made(choice_index: int, choice_text: String)

# ============================================================
# وضعیت داخلی
# ============================================================
var current_dialogue: Array = []
var current_index: int = 0
var is_active: bool = false
var current_id: String = ""
var auto_advance: bool = false
var auto_advance_delay: float = 3.0
var typewriter_speed: float = 0.03
var is_typing: bool = false
var full_text: String = ""

var _auto_timer: Timer
var _type_timer: Timer

# ============================================================
# توابع اولیه
# ============================================================
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_auto_timer = Timer.new()
	_auto_timer.one_shot = true
	_auto_timer.timeout.connect(_on_auto_advance)
	add_child(_auto_timer)
	
	_type_timer = Timer.new()
	_type_timer.wait_time = typewriter_speed
	_type_timer.timeout.connect(_on_type_tick)
	add_child(_type_timer)

# ============================================================
# شروع دیالوگ
# ============================================================
func start_dialogue(dialogue_id: String, lines: Array) -> void:
	if is_active:
		push_warning("[DialogueSystem] دیالوگ قبلی هنوز فعاله: " + current_id)
		return
	
	if lines.is_empty():
		push_warning("[DialogueSystem] آرایه دیالوگ خالیه: " + dialogue_id)
		return
	
	current_id = dialogue_id
	current_dialogue = lines
	current_index = 0
	is_active = true
	
	dialogue_started.emit(dialogue_id)
	print("[DialogueSystem] شروع دیالوگ: ", dialogue_id, " (", lines.size(), " خط)")
	_show_current_line()

# ============================================================
# نمایش خط فعلی
# ============================================================
func _show_current_line() -> void:
	if current_index >= current_dialogue.size():
		_end_dialogue()
		return
	
	var line: Dictionary = current_dialogue[current_index]
	var speaker: String = line.get("speaker", "")
	var text: String = line.get("text", "")
	var portrait: String = line.get("portrait", "")
	var voice: String = line.get("voice", "")
	
	# شروع تایپ متن
	full_text = text
	_start_typewriter()
	
	# پخش صدا اگر وجود داشت
	if voice != "" and AudioManager:
		AudioManager.play_voice("res://assets/audio/voice/" + voice)
	
	dialogue_line_shown.emit(speaker, text, portrait)
	dialogue_advanced.emit(current_index, current_dialogue.size())

# ============================================================
# تایپ‌رایتر (نمایش تدریجی متن)
# ============================================================
func _start_typewriter() -> void:
	is_typing = true
	_type_timer.start()

func _on_type_tick() -> void:
	# این فقط یک سیگنال است؛ متن اصلی توسط UI نمایش داده می‌شود
	# ولی ما سرعت را با stop/start تنظیم می‌کنیم
	pass

# ============================================================
# پیشروی به خط بعدی
# ============================================================
func next_line() -> void:
	if not is_active:
		return
	
	# اگر در حال تایپ است، اول متن کامل را نشان بده
	if is_typing:
		is_typing = false
		_type_timer.stop()
		return
	
	current_index += 1
	_show_current_line()

# ============================================================
# پایان دیالوگ
# ============================================================
func _end_dialogue() -> void:
	is_active = false
	_type_timer.stop()
	_auto_timer.stop()
	
	if AudioManager:
		AudioManager.stop_voice()
	
	var finished_id: String = current_id
	current_dialogue.clear()
	current_index = 0
	current_id = ""
	
	dialogue_finished.emit(finished_id)
	print("[DialogueSystem] پایان دیالوگ: ", finished_id)

# ============================================================
# رد کردن دیالوگ
# ============================================================
func skip_dialogue() -> void:
	if is_active:
		_end_dialogue()

# ============================================================
# انتخاب‌های داستانی
# ============================================================
func show_choices(choices: Array) -> void:
	if not is_active:
		return
	dialogue_choice_requested.emit(choices)

func select_choice(index: int, text: String) -> void:
	dialogue_choice_made.emit(index, text)
	next_line()

# ============================================================
# پیشروی خودکار
# ============================================================
func _on_auto_advance() -> void:
	if is_active and auto_advance:
		next_line()

func set_auto_advance(enabled: bool, delay: float = 3.0) -> void:
	auto_advance = enabled
	auto_advance_delay = delay
	if enabled:
		_auto_timer.wait_time = delay

# ============================================================
# تنظیم سرعت تایپ
# ============================================================
func set_typewriter_speed(speed: float) -> void:
	typewriter_speed = clampf(speed, 0.01, 0.2)
	_type_timer.wait_time = typewriter_speed

# ============================================================
# توابع کمکی
# ============================================================
func is_dialogue_active() -> bool:
	return is_active

func get_current_speaker() -> String:
	if not is_active or current_index >= current_dialogue.size():
		return ""
	return current_dialogue[current_index].get("speaker", "")

func get_progress() -> float:
	if current_dialogue.is_empty():
		return 0.0
	return float(current_index) / float(current_dialogue.size())
