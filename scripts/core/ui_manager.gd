extends Node
## UIManager - مدیریت رابط کاربری
## منوها، HUD، و انتقالات بین صفحات رابط کاربری.

# ============================================================
# سیگنال‌ها
# ============================================================
signal menu_opened(menu_name: String)
signal menu_closed(menu_name: String)
signal hud_visibility_changed(visible: bool)
signal notification_shown(text: String)
signal damage_number_requested(position: Vector2, amount: int, is_critical: bool)

# ============================================================
# منابع رابط کاربری
# ============================================================
const MAIN_MENU_SCENE: String = "res://scenes/ui/main_menu.tscn"
const PAUSE_MENU_SCENE: String = "res://scenes/ui/pause_menu.tscn"
const SETTINGS_MENU_SCENE: String = "res://scenes/ui/settings_menu.tscn"
const HUD_SCENE: String = "res://scenes/ui/hud.tscn"
const DIALOGUE_UI_SCENE: String = "res://scenes/ui/dialogue_ui.tscn"

# ============================================================
# وضعیت
# ============================================================
var active_menu: Control = null
var hud: CanvasLayer = null
var dialogue_ui: CanvasLayer = null
var ui_stack: Array[Control] = []
var is_hud_visible: bool = true

# ============================================================
# توابع اولیه
# ============================================================
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# ============================================================
# مدیریت منوها
# ============================================================
func open_menu(menu_scene_path: String) -> Control:
	if not ResourceLoader.exists(menu_scene_path):
		push_warning("[UIManager] منو پیدا نشد: " + menu_scene_path)
		return null
	
	var scene: PackedScene = load(menu_scene_path)
	if not scene:
		return null
	
	var menu: Control = scene.instantiate() as Control
	if not menu:
		return null
	
	get_tree().root.add_child(menu)
	ui_stack.append(menu)
	active_menu = menu
	
	if menu.has_signal("closed"):
		menu.closed.connect(func(): close_menu(menu))
	
	menu_opened.emit(menu_scene_path.get_file())
	return menu

func close_menu(menu: Control = null) -> void:
	if menu == null:
		menu = active_menu
	if menu == null:
		return
	
	var menu_name: String = menu.name
	ui_stack.erase(menu)
	menu.queue_free()
	
	if ui_stack.size() > 0:
		active_menu = ui_stack[-1]
	else:
		active_menu = null
	
	menu_closed.emit(menu_name)

func close_all_menus() -> void:
	for menu in ui_stack:
		if is_instance_valid(menu):
			menu.queue_free()
	ui_stack.clear()
	active_menu = null

# ============================================================
# HUD
# ============================================================
func show_hud() -> void:
	if hud and is_instance_valid(hud):
		hud.visible = true
		is_hud_visible = true
		hud_visibility_changed.emit(true)
		return
	
	if not ResourceLoader.exists(HUD_SCENE):
		return
	
	var scene: PackedScene = load(HUD_SCENE)
	if not scene:
		return
	
	hud = scene.instantiate() as CanvasLayer
	if hud:
		get_tree().root.add_child(hud)
		is_hud_visible = true
		hud_visibility_changed.emit(true)

func hide_hud() -> void:
	if hud and is_instance_valid(hud):
		hud.visible = false
		is_hud_visible = false
		hud_visibility_changed.emit(false)

func toggle_hud() -> void:
	if is_hud_visible:
		hide_hud()
	else:
		show_hud()

# ============================================================
# رابط دیالوگ
# ============================================================
func show_dialogue_ui() -> CanvasLayer:
	if dialogue_ui and is_instance_valid(dialogue_ui):
		dialogue_ui.visible = true
		return dialogue_ui
	
	if not ResourceLoader.exists(DIALOGUE_UI_SCENE):
		return null
	
	var scene: PackedScene = load(DIALOGUE_UI_SCENE)
	if not scene:
		return null
	
	dialogue_ui = scene.instantiate() as CanvasLayer
	if dialogue_ui:
		get_tree().root.add_child(dialogue_ui)
	return dialogue_ui

# ============================================================
# اعلان‌ها
# ============================================================
func show_notification(text: String, duration: float = 2.5) -> void:
	notification_shown.emit(text)
	
	if not hud or not is_instance_valid(hud):
		return
	
	var notification: Label = Label.new()
	notification.text = text
	notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification.add_theme_font_size_override("font_size", 24)
	notification.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	notification.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	notification.add_theme_constant_override("shadow_offset_x", 2)
	notification.add_theme_constant_override("shadow_offset_y", 2)
	
	notification.set_anchors_preset(Control.PRESET_CENTER_TOP)
	notification.position = Vector2(0, 100)
	notification.size = Vector2(400, 50)
	
	hud.add_child(notification)
	
	var tween: Tween = create_tween()
	tween.tween_property(notification, "modulate:a", 1.0, 0.3)
	tween.tween_interval(duration)
	tween.tween_property(notification, "modulate:a", 0.0, 0.5)
	tween.finished.connect(func(): notification.queue_free())

# ============================================================
# اعداد آسیب
# ============================================================
func spawn_damage_number(world_position: Vector3, amount: int, is_critical: bool = false) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if not camera:
		return
	
	if camera.is_position_behind(world_position):
		return
	
	var screen_pos: Vector2 = camera.unproject_position(world_position)
	damage_number_requested.emit(screen_pos, amount, is_critical)

# ============================================================
# صفحه‌های مخصوص
# ============================================================
func show_game_over(won: bool) -> void:
	hide_hud()
	
	var canvas: CanvasLayer = CanvasLayer.new()
	var label: Label = Label.new()
	label.text = "پیروزی!" if won else "شکست"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 64)
	label.add_theme_color_override("font_color", Color(1, 0.8, 0.2) if won else Color(0.9, 0.2, 0.2))
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	canvas.add_child(label)
	get_tree().root.add_child(canvas)
	
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(canvas):
		canvas.queue_free()

# ============================================================
# توابع کمکی
# ============================================================
func is_menu_open() -> bool:
	return active_menu != null and is_instance_valid(active_menu)

func is_hud_showing() -> bool:
	return is_hud_visible

func get_active_menu() -> Control:
	return active_menu
