class_name StormHUD
extends CanvasLayer

signal intro_started
signal choice_selected(index: int)

var root: Control
var top_date_label: Label
var top_weather_label: Label
var top_place_label: Label
var objective_label: Label
var progress_label: Label
var prompt_panel: PanelContainer
var prompt_label: Label
var dialogue_panel: PanelContainer
var dialogue_speaker: Label
var dialogue_text: Label
var choices_box: HBoxContainer
var intro_overlay: ColorRect
var toast_panel: PanelContainer
var toast_label: Label
var toast_timer: Timer


func _ready() -> void:
	layer = 20
	_build_interface()


func _build_interface() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var top_panel := PanelContainer.new()
	top_panel.position = Vector2(16, 16)
	top_panel.size = Vector2(720, 62)
	top_panel.add_theme_stylebox_override(
		"panel", _panel_style(Color(0.035, 0.055, 0.065, 0.92), Color("53636b"), 10)
	)
	root.add_child(top_panel)
	var top_box := HBoxContainer.new()
	top_box.add_theme_constant_override("separation", 18)
	top_panel.add_child(top_box)
	top_date_label = _make_label("暴雨前第3天 · 上午8:05", 16, Color("f4d18a"))
	top_weather_label = _make_label("阴 · 尚未下雨", 14, Color("c4d1d5"))
	top_place_label = _make_label("家 · 一楼", 14, Color("a9c9d5"))
	top_box.add_child(top_date_label)
	top_box.add_child(_separator())
	top_box.add_child(top_weather_label)
	top_box.add_child(_separator())
	top_box.add_child(top_place_label)

	var objective_panel := PanelContainer.new()
	objective_panel.anchor_left = 1.0
	objective_panel.anchor_right = 1.0
	objective_panel.offset_left = -360.0
	objective_panel.offset_right = -16.0
	objective_panel.offset_top = 16.0
	objective_panel.offset_bottom = 154.0
	objective_panel.add_theme_stylebox_override(
		"panel", _panel_style(Color(0.045, 0.065, 0.075, 0.94), Color("4c5c64"), 10)
	)
	root.add_child(objective_panel)
	var objective_box := VBoxContainer.new()
	objective_box.add_theme_constant_override("separation", 7)
	objective_panel.add_child(objective_box)
	var heading := _make_label("当前目标", 15, Color("f0c36d"))
	objective_box.add_child(heading)
	objective_label = _make_label("与家人聊聊，检查房屋的关键位置。", 14, Color("e1e7e7"))
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_box.add_child(objective_label)
	progress_label = _make_label("家人对话 0/4 · 房屋检查 0/5", 12, Color("9eacb1"))
	objective_box.add_child(progress_label)

	prompt_panel = PanelContainer.new()
	prompt_panel.anchor_left = 0.5
	prompt_panel.anchor_right = 0.5
	prompt_panel.anchor_top = 1.0
	prompt_panel.anchor_bottom = 1.0
	prompt_panel.offset_left = -230.0
	prompt_panel.offset_right = 230.0
	prompt_panel.offset_top = -82.0
	prompt_panel.offset_bottom = -34.0
	prompt_panel.add_theme_stylebox_override(
		"panel", _panel_style(Color(0.035, 0.055, 0.063, 0.94), Color("caa45f"), 9)
	)
	prompt_panel.visible = false
	root.add_child(prompt_panel)
	prompt_label = _make_label("E 互动", 15, Color("fff0cc"))
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_panel.add_child(prompt_label)

	dialogue_panel = PanelContainer.new()
	dialogue_panel.anchor_left = 0.08
	dialogue_panel.anchor_right = 0.92
	dialogue_panel.anchor_top = 0.61
	dialogue_panel.anchor_bottom = 0.96
	dialogue_panel.add_theme_stylebox_override(
		"panel", _panel_style(Color(0.035, 0.055, 0.065, 0.98), Color("d0aa67"), 12, 2)
	)
	dialogue_panel.visible = false
	root.add_child(dialogue_panel)
	var dialogue_box := VBoxContainer.new()
	dialogue_box.add_theme_constant_override("separation", 9)
	dialogue_panel.add_child(dialogue_box)
	dialogue_speaker = _make_label("人物", 17, Color("f1c36c"))
	dialogue_box.add_child(dialogue_speaker)
	dialogue_text = _make_label("对话内容", 15, Color("eef2ef"))
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dialogue_box.add_child(dialogue_text)
	choices_box = HBoxContainer.new()
	choices_box.add_theme_constant_override("separation", 9)
	dialogue_box.add_child(choices_box)

	toast_panel = PanelContainer.new()
	toast_panel.anchor_left = 0.5
	toast_panel.anchor_right = 0.5
	toast_panel.offset_left = -250.0
	toast_panel.offset_right = 250.0
	toast_panel.offset_top = 92.0
	toast_panel.offset_bottom = 142.0
	toast_panel.add_theme_stylebox_override(
		"panel", _panel_style(Color(0.04, 0.07, 0.08, 0.96), Color("61737b"), 9)
	)
	toast_panel.visible = false
	root.add_child(toast_panel)
	toast_label = _make_label("提示", 13, Color("e9eeee"))
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_panel.add_child(toast_label)
	toast_timer = Timer.new()
	toast_timer.one_shot = true
	toast_timer.timeout.connect(_on_toast_timeout)
	add_child(toast_timer)

	_build_intro()


func _build_intro() -> void:
	intro_overlay = ColorRect.new()
	intro_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	intro_overlay.color = Color(0.018, 0.03, 0.035, 0.94)
	intro_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(intro_overlay)
	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -350.0
	panel.offset_right = 350.0
	panel.offset_top = -245.0
	panel.offset_bottom = 245.0
	panel.add_theme_stylebox_override(
		"panel", _panel_style(Color("1a252b"), Color("687981"), 14, 2)
	)
	intro_overlay.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 15)
	panel.add_child(box)
	var kicker := _make_label("GODOT正式工程 · 灰盒检查点 0.1.1", 13, Color("90bccc"))
	box.add_child(kicker)
	var title := _make_label("暴雨100天", 36, Color("f4eee1"))
	box.add_child(title)
	var subtitle := _make_label("暴雨前第3天 · 雨还没有开始", 20, Color("e9bd6b"))
	box.add_child(subtitle)
	var description := _make_label(
		"这一版用于确认正式房屋比例、房间动线、镜头距离与互动手感。你可以在一楼、前院、住宅街、二楼和公共阳台之间探索，并与四位家人交谈。", 15, Color("cbd5d7")
	)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size.y = 78.0
	box.add_child(description)
	var controls := _make_label(
		"WASD / 方向键：移动　　E：互动　　Esc：关闭对话\nF5：保存检查点　　F9：读取检查点", 14, Color("aebcc1")
	)
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(controls)
	var note := _make_label("当前使用功能性家具和灰盒色块，不代表最终美术。", 13, Color("88979d"))
	box.add_child(note)
	var start_button := Button.new()
	start_button.text = "进入房屋灰盒"
	start_button.custom_minimum_size = Vector2(0.0, 50.0)
	start_button.add_theme_font_size_override("font_size", 16)
	start_button.pressed.connect(_on_intro_button_pressed)
	box.add_child(start_button)


func set_context(day_and_time: String, weather: String, place: String, objective: String) -> void:
	top_date_label.text = day_and_time
	top_weather_label.text = weather
	top_place_label.text = place
	objective_label.text = objective


func set_progress(talked_count: int, inspected_count: int) -> void:
	progress_label.text = "家人对话 %d/4 · 房屋检查 %d/5" % [talked_count, mini(inspected_count, 5)]


func set_prompt(text: String) -> void:
	prompt_panel.visible = not text.is_empty() and not is_blocking()
	prompt_label.text = "E　%s" % text


func show_dialogue(speaker: String, text: String, choices: Array[String]) -> void:
	dialogue_speaker.text = speaker
	dialogue_text.text = text
	for child in choices_box.get_children():
		child.queue_free()
	for index in range(choices.size()):
		var button := Button.new()
		button.text = choices[index]
		button.custom_minimum_size = Vector2(138.0, 42.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 13)
		button.pressed.connect(_on_choice_button_pressed.bind(index))
		choices_box.add_child(button)
	dialogue_panel.visible = true
	prompt_panel.visible = false


func hide_dialogue() -> void:
	dialogue_panel.visible = false


func close_top_overlay() -> void:
	if dialogue_panel.visible:
		hide_dialogue()


func is_blocking() -> bool:
	return (
		(intro_overlay != null and intro_overlay.visible)
		or (dialogue_panel != null and dialogue_panel.visible)
	)


func show_toast(message: String, duration: float = 2.4) -> void:
	toast_label.text = message
	toast_panel.visible = true
	toast_timer.start(duration)


func _on_intro_button_pressed() -> void:
	intro_overlay.visible = false
	intro_started.emit()


func _on_choice_button_pressed(index: int) -> void:
	choice_selected.emit(index)


func _on_toast_timeout() -> void:
	toast_panel.visible = false


func _make_label(text_value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _separator() -> VSeparator:
	var separator := VSeparator.new()
	separator.custom_minimum_size.x = 2.0
	return separator


func _panel_style(
	background: Color, border: Color, radius: int, border_width: int = 1
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 11.0
	style.content_margin_bottom = 11.0
	return style
