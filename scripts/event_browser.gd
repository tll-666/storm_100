class_name StormEventBrowser
extends ColorRect

signal preview_event_requested(event_id: String)
signal reset_event_requested(event_id: String)

var entries: Array = []
var selected_event_id: String = ""
var event_list: VBoxContainer
var detail_title: Label
var detail_meta: Label
var detail_status: Label
var detail_conditions: Label
var detail_clues: Label
var detail_text: Label
var detail_choices: Label
var preview_button: Button
var reset_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color = Color(0.008, 0.015, 0.02, 0.96)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	_build_interface()


func _build_interface() -> void:
	var panel := PanelContainer.new()
	panel.anchor_left = 0.03
	panel.anchor_right = 0.97
	panel.anchor_top = 0.04
	panel.anchor_bottom = 0.96
	add_child(panel)

	var root_box := VBoxContainer.new()
	root_box.add_theme_constant_override("separation", 10)
	panel.add_child(root_box)

	var header := HBoxContainer.new()
	root_box.add_child(header)
	var title := Label.new()
	title.text = "事件浏览器 · 仅调试版"
	title.add_theme_font_size_override("font_size", 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close_button := Button.new()
	close_button.text = "关闭 ×"
	close_button.custom_minimum_size = Vector2(110.0, 40.0)
	close_button.pressed.connect(hide_browser)
	header.add_child(close_button)

	var note := Label.new()
	note.text = "左侧选择事件；右侧可查看条件、提前线索、全部分支结果和合流点。强制播放会真实修改当前测试进度。"
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_color_override("font_color", Color("aebdc1"))
	root_box.add_child(note)

	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_box.add_child(body)

	var list_panel := PanelContainer.new()
	list_panel.custom_minimum_size.x = 340.0
	body.add_child(list_panel)
	var list_scroll := ScrollContainer.new()
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	list_panel.add_child(list_scroll)
	event_list = VBoxContainer.new()
	event_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	event_list.add_theme_constant_override("separation", 6)
	list_scroll.add_child(event_list)

	var detail_panel := PanelContainer.new()
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(detail_panel)
	var detail_scroll := ScrollContainer.new()
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail_panel.add_child(detail_scroll)
	var detail_box := VBoxContainer.new()
	detail_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_box.add_theme_constant_override("separation", 9)
	detail_scroll.add_child(detail_box)

	detail_title = _make_detail_label("请选择事件", 22, Color("f1c36c"))
	detail_box.add_child(detail_title)
	detail_meta = _make_detail_label("", 13, Color("aebdc1"))
	detail_box.add_child(detail_meta)
	detail_status = _make_detail_label("", 14, Color("8fc5a4"))
	detail_box.add_child(detail_status)
	detail_conditions = _make_detail_label("", 13, Color("d2d9d9"))
	detail_box.add_child(detail_conditions)
	detail_clues = _make_detail_label("", 13, Color("e6bd70"))
	detail_box.add_child(detail_clues)
	detail_text = _make_detail_label("", 14, Color("eef2ef"))
	detail_box.add_child(detail_text)
	var separator := HSeparator.new()
	detail_box.add_child(separator)
	detail_choices = _make_detail_label("", 13, Color("c9d4d6"))
	detail_box.add_child(detail_choices)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_END
	footer.add_theme_constant_override("separation", 10)
	root_box.add_child(footer)
	reset_button = Button.new()
	reset_button.text = "允许重新触发（不回滚后果）"
	reset_button.custom_minimum_size = Vector2(230.0, 42.0)
	reset_button.pressed.connect(_on_reset_pressed)
	reset_button.disabled = true
	footer.add_child(reset_button)
	preview_button = Button.new()
	preview_button.text = "强制播放此事件"
	preview_button.custom_minimum_size = Vector2(190.0, 42.0)
	preview_button.pressed.connect(_on_preview_pressed)
	preview_button.disabled = true
	footer.add_child(preview_button)


func show_entries(new_entries: Array) -> void:
	entries = new_entries
	for child in event_list.get_children():
		event_list.remove_child(child)
		child.queue_free()
	for raw_entry in entries:
		if not (raw_entry is Dictionary):
			continue
		var entry: Dictionary = raw_entry
		var button := Button.new()
		button.text = "%s\n%s" % [str(entry.get("day", "")), str(entry.get("title", entry.get("id", "")))]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(315.0, 54.0)
		button.pressed.connect(_select_event.bind(str(entry.get("id", ""))))
		event_list.add_child(button)
	visible = true
	move_to_front()
	if not entries.is_empty():
		_select_event(str((entries[0] as Dictionary).get("id", "")))


func hide_browser() -> void:
	visible = false


func _select_event(event_id: String) -> void:
	selected_event_id = event_id
	var entry := _entry_by_id(event_id)
	if entry.is_empty():
		return
	detail_title.text = "%s\n[%s]" % [str(entry.get("title", event_id)), event_id]
	detail_meta.text = "日期：%s　阶段：%s　类型：%s　地点：%s" % [
		str(entry.get("day", "")),
		str(entry.get("phase", "")),
		str(entry.get("type", "")),
		str(entry.get("location", "")),
	]
	detail_status.text = "当前状态：%s" % str(entry.get("status", ""))
	detail_conditions.text = "触发条件：%s" % str(entry.get("conditions", "无"))
	detail_clues.text = "提前线索：%s" % str(entry.get("clues", "无"))
	detail_text.text = "事件正文：\n%s" % str(entry.get("text", ""))
	var choice_lines: Array[String] = []
	var choices: Array = entry.get("choices", [])
	for index in range(choices.size()):
		var choice: Dictionary = choices[index]
		choice_lines.append(
			"分支%d：%s\n结果：%s\n系统影响：%s" % [
				index + 1,
				str(choice.get("label", "")),
				str(choice.get("result", "")),
				str(choice.get("effects", "无")),
			]
		)
	choice_lines.append("合流点：%s" % str(entry.get("merge", "无")))
	detail_choices.text = "\n\n".join(choice_lines)
	preview_button.disabled = false
	reset_button.disabled = false


func _entry_by_id(event_id: String) -> Dictionary:
	for raw_entry in entries:
		if raw_entry is Dictionary and str(raw_entry.get("id", "")) == event_id:
			return raw_entry
	return {}


func _on_preview_pressed() -> void:
	if selected_event_id.is_empty():
		return
	hide_browser()
	preview_event_requested.emit(selected_event_id)


func _on_reset_pressed() -> void:
	if selected_event_id.is_empty():
		return
	reset_event_requested.emit(selected_event_id)


func _make_detail_label(text_value: String, font_size: int, color_value: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color_value)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label
