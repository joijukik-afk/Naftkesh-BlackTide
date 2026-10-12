extends Node
## SceneTransition - مدیریت انتقال بین صحنه‌ها
## انتقال نرم با افکت محو شدن، پشتیبانی از صفحه بارگذاری.

# ============================================================
# سیگنال‌ها
# ============================================================
signal transition_started(from_scene: String, to_scene: String)
signal transition_midpoint
signal transition_finished(to_scene: String)

# ============================================================
# تنظیمات
# ============================================================
@export var fade_duration: float = 0.5
@export var fade_color: Color = Color(0, 0, 0, 1)

# ============================================================
# وضعیت
# ============================================================
var is_transitioning: bool = false
var _fade_rect: ColorRect
var _loading_label: Label
var _canvas: CanvasLayer

# ============================================================
# توابع اولیه
# ============================================================
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_overlay()

func _setup_overlay() -> void:
	_canvas = CanvasLayer.new()
	_canvas.layer = 128
	add_child(_canvas)
	
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(fade_color.r, fade_color.g, fade_color.b, 0.0)
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.add_child(_fade_rect)
	
	_loading_label = Label.new()
	_loading_label.text = ""
	_loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_loading_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_loading_label.add_theme_font_size_override("font_size", 24)
	_loading_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	_loading_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_loading_label.visible = false
	_canvas.add_child(_loading_label)

# ============================================================
# انتقال به صحنه جدید
# ============================================================
func change_scene(scene_path: String, show_loading: bool = true) -> void:
	if is_transitioning:
		push_warning("[SceneTransition] انتقال قبلی هنوز در حال اجراست.")
		return
	
	if not ResourceLoader.exists(scene_path):
		push_error("[SceneTransition] صحنه پیدا نشد: " + scene_path)
		return
	
	is_transitioning = true
	var from_scene: String = ""
	if get_tree().current_scene:
		from_scene = get_tree().current_scene.scene_file_path
	
	transition_started.emit(from_scene, scene_path)
	
	# محو شدن به سیاه
	await _fade_to_black()
	transition_midpoint.emit()
	
	# نمایش صفحه بارگذاری
	if show_loading:
		_show_loading("در حال بارگذاری...")
	
	# صبر یک فریم
	await get_tree().process_frame
	
	# تغییر صحنه
	var err: int = get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("[SceneTransition] خطا در تغییر صحنه: " + str(err))
		is_transitioning = false
		_hide_loading()
		await _fade_from_black()
		return
	
	# صبر تا صحنه جدید لود شود
	await get_tree().process_frame
	await get_tree().process_frame
	
	# مخفی کردن بارگذاری
	_hide_loading()
	
	# روشن شدن از سیاه
	await _fade_from_black()
	
	is_transitioning = false
	transition_finished.emit(scene_path)
	print("[SceneTransition] انتقال کامل شد به: ", scene_path)

# ============================================================
# انتقال با PackedScene
# ============================================================
func change_scene_packed(packed: PackedScene) -> void:
	if is_transitioning or not packed:
		return
	
	is_transitioning = true
	
	await _fade_to_black()
	transition_midpoint.emit()
	
	var err: int = get_tree().change_scene_to_packed(packed)
	if err != OK:
		push_error("[SceneTransition] خطا در تغییر صحنه: " + str(err))
	
	await get_tree().process_frame
	await _fade_from_black()
	
	is_transitioning = false

# ============================================================
# افکت‌های محو شدن
# ============================================================
func _fade_to_black() -> void:
	_loading_label.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(_fade_rect, "color:a", 1.0, fade_duration)
	await tween.finished

func _fade_from_black() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_fade_rect, "color:a", 0.0, fade_duration)
	tween.parallel().tween_property(_loading_label, "modulate:a", 0.0, fade_duration)
	await tween.finished

func _show_loading(text: String) -> void:
	_loading_label.text = text
	_loading_label.visible = true
	_loading_label.modulate.a = 1.0

func _hide_loading() -> void:
	_loading_label.visible = false

# ============================================================
# انتقال ساده (بدون تغییر صحنه)
# ============================================================
func fade_in(duration: float = -1.0) -> void:
	var d: float = duration if duration > 0 else fade_duration
	var tween: Tween = create_tween()
	tween.tween_property(_fade_rect, "color:a", 1.0, d)
	await tween.finished

func fade_out(duration: float = -1.0) -> void:
	var d: float = duration if duration > 0 else fade_duration
	var tween: Tween = create_tween()
	tween.tween_property(_fade_rect, "color:a", 0.0, d)
	await tween.finished

# ============================================================
# توابع کمکی
# ============================================================
func is_busy() -> bool:
	return is_transitioning

func reload_current_scene() -> void:
	var current: Node = get_tree().current_scene
	if current and current.scene_file_path != "":
		change_scene(current.scene_file_path)
