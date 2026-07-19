class_name StormHUD
extends CanvasLayer

const ITEM_ICON_SCRIPT = preload("res://scripts/item_icon.gd")
const EVENT_BROWSER_SCRIPT = preload("res://scripts/event_browser.gd")

signal intro_started
signal choice_selected(index: int)
signal item_grid_item_selected(item_id: String)
signal item_grid_primary
signal item_grid_closed
signal day_summary_confirmed
signal day_transition_blackout
signal day_transition_finished
signal quick_travel_selected(location_id: String)
signal survival_manual_requested
signal debug_action_selected(action_id: String)
signal event_browser_preview_requested(event_id: String)
signal event_browser_reset_requested(event_id: String)

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
var item_grid_overlay: ColorRect
var item_grid_title: Label
var item_grid_subtitle: Label
var item_grid: GridContainer
var item_grid_primary_button: Button
var day_summary_overlay: ColorRect
var day_summary_title: Label
var day_summary_subtitle: Label
var day_summary_rows: VBoxContainer
var day_summary_note: Label
var transition_overlay: ColorRect
var transition_card: VBoxContainer
var transition_date_label: Label
var transition_time_label: Label
var transition_detail_label: Label
var transition_continue_button: Button
var transition_waiting_for_confirm: bool = false
var family_overlay: ColorRect
var family_household_label: Label
var family_cards: HBoxContainer
var manual_overlay: ColorRect
var manual_objective_label: Label
var manual_records_label: Label
var quick_travel_overlay: ColorRect
var debug_overlay: ColorRect
var event_browser: StormEventBrowser


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

	_build_utility_controls()
	_build_item_grid_overlay()
	_build_day_summary_overlay()
	_build_day_transition_overlay()
	_build_family_overlay()
	_build_survival_manual_overlay()
	_build_quick_travel_overlay()
	_build_debug_overlay()
	_build_event_browser()
	_build_intro()


func _build_utility_controls() -> void:
	var utility_bar := VBoxContainer.new()
	utility_bar.position = Vector2(16.0, 92.0)
	utility_bar.add_theme_constant_override("separation", 7)
	root.add_child(utility_bar)

	var travel_button := Button.new()
	travel_button.text = "快捷移动  T"
	travel_button.custom_minimum_size = Vector2(132.0, 38.0)
	travel_button.tooltip_text = "在家中已经熟悉的房间之间快速移动"
	travel_button.pressed.connect(toggle_quick_travel)
	utility_bar.add_child(travel_button)

	var manual_button := Button.new()
	manual_button.text = "生存手册  J"
	manual_button.custom_minimum_size = Vector2(132.0, 38.0)
	manual_button.tooltip_text = "暂停并查看当前目标与已经确认的检查记录"
	manual_button.pressed.connect(_on_survival_manual_pressed)
	utility_bar.add_child(manual_button)

	if OS.is_debug_build():
		var debug_button := Button.new()
		debug_button.text = "测试工具  F1"
		debug_button.custom_minimum_size = Vector2(132.0, 38.0)
		debug_button.tooltip_text = "仅调试版本显示，不会进入正式发行版"
		debug_button.pressed.connect(toggle_debug_menu)
		utility_bar.add_child(debug_button)


func _build_item_grid_overlay() -> void:
	item_grid_overlay = ColorRect.new()
	item_grid_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	item_grid_overlay.color = Color(0.015, 0.025, 0.03, 0.84)
	item_grid_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	item_grid_overlay.visible = false
	root.add_child(item_grid_overlay)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -480.0
	panel.offset_right = 480.0
	panel.offset_top = -320.0
	panel.offset_bottom = 320.0
	panel.add_theme_stylebox_override(
		"panel", _panel_style(Color("18252b"), Color("82939a"), 14, 2)
	)
	item_grid_overlay.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	content.add_child(header)
	item_grid_title = _make_label("物品栏", 23, Color("f1c36c"))
	item_grid_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(item_grid_title)
	var close_button := Button.new()
	close_button.text = "关闭 ×"
	close_button.custom_minimum_size = Vector2(100, 38)
	close_button.pressed.connect(_on_item_grid_close_pressed)
	header.add_child(close_button)

	item_grid_subtitle = _make_label("物品与容量", 13, Color("bbc7ca"))
	item_grid_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item_grid_subtitle.custom_minimum_size.y = 42.0
	content.add_child(item_grid_subtitle)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)
	item_grid = GridContainer.new()
	item_grid.columns = 5
	item_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_grid.add_theme_constant_override("h_separation", 10)
	item_grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(item_grid)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_END
	content.add_child(footer)
	item_grid_primary_button = Button.new()
	item_grid_primary_button.custom_minimum_size = Vector2(230, 46)
	item_grid_primary_button.add_theme_font_size_override("font_size", 15)
	item_grid_primary_button.pressed.connect(_on_item_grid_primary_pressed)
	item_grid_primary_button.visible = false
	footer.add_child(item_grid_primary_button)


func _build_day_summary_overlay() -> void:
	day_summary_overlay = ColorRect.new()
	day_summary_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	day_summary_overlay.color = Color(0.012, 0.022, 0.027, 0.88)
	day_summary_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	day_summary_overlay.visible = false
	root.add_child(day_summary_overlay)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -390.0
	panel.offset_right = 390.0
	panel.offset_top = -280.0
	panel.offset_bottom = 280.0
	panel.add_theme_stylebox_override(
		"panel", _panel_style(Color("18252b"), Color("bd9d61"), 14, 2)
	)
	day_summary_overlay.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 13)
	panel.add_child(content)
	var kicker := _make_label("一天结束", 13, Color("9fb5bc"))
	content.add_child(kicker)
	day_summary_title = _make_label("暴雨前第3天 · 夜间结算", 27, Color("f2d18a"))
	content.add_child(day_summary_title)
	day_summary_subtitle = _make_label("今天的重要行动已经完成。", 14, Color("c9d3d5"))
	day_summary_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(day_summary_subtitle)
	var line := HSeparator.new()
	content.add_child(line)
	day_summary_rows = VBoxContainer.new()
	day_summary_rows.add_theme_constant_override("separation", 9)
	day_summary_rows.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(day_summary_rows)
	day_summary_note = _make_label("夜间情况", 13, Color("d2bf91"))
	day_summary_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	day_summary_note.custom_minimum_size.y = 48.0
	content.add_child(day_summary_note)
	var confirm_button := Button.new()
	confirm_button.text = "进入下一天"
	confirm_button.custom_minimum_size = Vector2(0, 50)
	confirm_button.add_theme_font_size_override("font_size", 16)
	confirm_button.pressed.connect(_on_day_summary_confirmed)
	content.add_child(confirm_button)


func _build_day_transition_overlay() -> void:
	transition_overlay = ColorRect.new()
	transition_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition_overlay.color = Color("0b1115")
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	transition_overlay.visible = false
	root.add_child(transition_overlay)

	transition_card = VBoxContainer.new()
	transition_card.anchor_left = 0.5
	transition_card.anchor_right = 0.5
	transition_card.anchor_top = 0.5
	transition_card.anchor_bottom = 0.5
	transition_card.offset_left = -360.0
	transition_card.offset_right = 360.0
	transition_card.offset_top = -125.0
	transition_card.offset_bottom = 125.0
	transition_card.alignment = BoxContainer.ALIGNMENT_CENTER
	transition_card.add_theme_constant_override("separation", 13)
	transition_overlay.add_child(transition_card)
	transition_date_label = _make_label("暴雨前第2天", 36, Color("f1e9da"))
	transition_date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transition_card.add_child(transition_date_label)
	transition_time_label = _make_label("上午07:10", 20, Color("e6bd70"))
	transition_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transition_card.add_child(transition_time_label)
	transition_detail_label = _make_label("距离预报中的强降雨，还有两天。", 14, Color("9fb0b5"))
	transition_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transition_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	transition_card.add_child(transition_detail_label)
	transition_continue_button = Button.new()
	transition_continue_button.text = "进入新的一天（Enter）"
	transition_continue_button.custom_minimum_size = Vector2(260.0, 48.0)
	transition_continue_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	transition_continue_button.add_theme_font_size_override("font_size", 15)
	transition_continue_button.pressed.connect(_on_transition_continue_pressed)
	transition_continue_button.visible = false
	transition_card.add_child(transition_continue_button)


func _build_family_overlay() -> void:
	family_overlay = ColorRect.new()
	family_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	family_overlay.color = Color(0.012, 0.022, 0.027, 0.90)
	family_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	family_overlay.visible = false
	root.add_child(family_overlay)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -600.0
	panel.offset_right = 600.0
	panel.offset_top = -320.0
	panel.offset_bottom = 320.0
	panel.add_theme_stylebox_override(
		"panel", _panel_style(Color("18252b"), Color("78909a"), 14, 2)
	)
	family_overlay.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	var header := HBoxContainer.new()
	content.add_child(header)
	var title := _make_label("五人家庭状态", 25, Color("f1c36c"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close_button := Button.new()
	close_button.text = "关闭 ×"
	close_button.custom_minimum_size = Vector2(100, 38)
	close_button.pressed.connect(hide_family_status)
	header.add_child(close_button)
	family_household_label = _make_label("家庭资源与公共设施", 14, Color("b8c8cc"))
	family_household_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	family_household_label.custom_minimum_size.y = 52.0
	content.add_child(family_household_label)
	var separator := HSeparator.new()
	content.add_child(separator)
	family_cards = HBoxContainer.new()
	family_cards.add_theme_constant_override("separation", 10)
	family_cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(family_cards)
	var note := _make_label(
		"数值会在每天结算时变化。正常情况下食物和水自动平均分配，严重短缺时才让玩家决定优先顺序。",
		12,
		Color("899a9f")
	)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(note)


func _build_survival_manual_overlay() -> void:
	manual_overlay = ColorRect.new()
	manual_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	manual_overlay.color = Color(0.012, 0.022, 0.027, 0.92)
	manual_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	manual_overlay.visible = false
	root.add_child(manual_overlay)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -460.0
	panel.offset_right = 460.0
	panel.offset_top = -310.0
	panel.offset_bottom = 310.0
	panel.add_theme_stylebox_override(
		"panel", _panel_style(Color("18252b"), Color("78909a"), 14, 2)
	)
	manual_overlay.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	var header := HBoxContainer.new()
	content.add_child(header)
	var title := _make_label("家庭生存手册", 25, Color("f1c36c"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close_button := Button.new()
	close_button.text = "关闭 ×"
	close_button.custom_minimum_size = Vector2(100.0, 38.0)
	close_button.pressed.connect(hide_survival_manual)
	header.add_child(close_button)

	var pause_note := _make_label("手册属于思考界面，打开时世界时间暂停。", 13, Color("9fb0b5"))
	content.add_child(pause_note)
	var objective_heading := _make_label("当前主要目标", 16, Color("e6bd70"))
	content.add_child(objective_heading)
	manual_objective_label = _make_label("尚无目标。", 15, Color("eef2ef"))
	manual_objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	manual_objective_label.custom_minimum_size.y = 54.0
	content.add_child(manual_objective_label)
	content.add_child(HSeparator.new())
	var records_heading := _make_label("已确认的环境记录", 16, Color("e6bd70"))
	content.add_child(records_heading)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)
	manual_records_label = _make_label("尚未检查任何环境对象。", 14, Color("cbd5d7"))
	manual_records_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	manual_records_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(manual_records_label)


func _build_quick_travel_overlay() -> void:
	quick_travel_overlay = ColorRect.new()
	quick_travel_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	quick_travel_overlay.color = Color(0.012, 0.022, 0.027, 0.88)
	quick_travel_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	quick_travel_overlay.visible = false
	root.add_child(quick_travel_overlay)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -300.0
	panel.offset_right = 300.0
	panel.offset_top = -230.0
	panel.offset_bottom = 230.0
	panel.add_theme_stylebox_override(
		"panel", _panel_style(Color("18252b"), Color("78909a"), 14, 2)
	)
	quick_travel_overlay.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	var title := _make_label("房屋快捷移动", 25, Color("f1c36c"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)
	var note := _make_label(
		"省略已经走过的室内路程，不推进时间，也不会触发或跳过剧情。",
		13,
		Color("b8c8cc")
	)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(note)

	var locations := [
		["living_room", "一楼 · 客厅与餐桌"],
		["garage", "一楼 · 车库"],
		["master_bedroom", "二楼 · 主卧床边"],
		["balcony", "二楼 · 公共阳台"],
	]
	for entry in locations:
		var button := Button.new()
		button.text = str(entry[1])
		button.custom_minimum_size = Vector2(430.0, 44.0)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.pressed.connect(_on_quick_travel_pressed.bind(str(entry[0])))
		content.add_child(button)
	var close_button := Button.new()
	close_button.text = "取消"
	close_button.custom_minimum_size = Vector2(180.0, 40.0)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_button.pressed.connect(hide_quick_travel)
	content.add_child(close_button)


func _build_debug_overlay() -> void:
	debug_overlay = ColorRect.new()
	debug_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	debug_overlay.color = Color(0.012, 0.022, 0.027, 0.90)
	debug_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	debug_overlay.visible = false
	root.add_child(debug_overlay)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -360.0
	panel.offset_right = 360.0
	panel.offset_top = -275.0
	panel.offset_bottom = 275.0
	panel.add_theme_stylebox_override(
		"panel", _panel_style(Color("18252b"), Color("b48758"), 14, 2)
	)
	debug_overlay.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)
	var title := _make_label("测试工具", 25, Color("f1c36c"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)
	var note := _make_label(
		"这些按钮只在Godot调试运行时显示，用于跳过重复流程。不会写进正式发行版。",
		13,
		Color("b8c8cc")
	)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(note)

	var actions := [
		["unlock_car", "完成前置调查（立刻解锁开车）"],
		["go_store", "直接进入第一次购物"],
		["after_shop", "跳到第一次购物回家后"],
		["evening_bed", "跳到当天晚上并传送到主卧"],
		["day_two", "直接进入暴雨前第2天"],
		["day_one", "直接进入暴雨前第1天"],
		["rain_day_one", "直接进入暴雨第1天"],
		["rain_day_two", "直接进入暴雨第2天"],
		["rain_day_three", "直接进入暴雨第3天"],
		["rain_day_four", "直接进入暴雨第4天"],
		["rain_day_five", "直接进入暴雨第5天"],
		["rain_day_six", "直接进入暴雨第6天"],
		["rain_day_seven", "直接进入暴雨第7天"],
		["faucet_prototype", "检查原型：切换水龙头状态"],
		["event_browser", "打开事件浏览器（查看全部分支）"],
		["reset", "重置本次测试"],
	]
	var actions_grid := GridContainer.new()
	actions_grid.columns = 2
	actions_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	actions_grid.add_theme_constant_override("h_separation", 10)
	actions_grid.add_theme_constant_override("v_separation", 8)
	content.add_child(actions_grid)
	for entry in actions:
		var button := Button.new()
		button.text = str(entry[1])
		button.custom_minimum_size = Vector2(315.0, 42.0)
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.pressed.connect(_on_debug_action_pressed.bind(str(entry[0])))
		actions_grid.add_child(button)
	var close_button := Button.new()
	close_button.text = "关闭"
	close_button.custom_minimum_size = Vector2(180.0, 38.0)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_button.pressed.connect(hide_debug_menu)
	content.add_child(close_button)


func _build_event_browser() -> void:
	event_browser = EVENT_BROWSER_SCRIPT.new()
	event_browser.preview_event_requested.connect(_on_event_browser_preview_requested)
	event_browser.reset_event_requested.connect(_on_event_browser_reset_requested)
	root.add_child(event_browser)


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
	var kicker := _make_label("GODOT正式工程 · 事件系统 0.6.0", 13, Color("90bccc"))
	box.add_child(kicker)
	var title := _make_label("暴雨100天", 36, Color("f4eee1"))
	box.add_child(title)
	var subtitle := _make_label("暴雨前第3天 · 雨还没有开始", 20, Color("e9bd6b"))
	box.add_child(subtitle)
	var description := _make_label(
		"完成采购后，食物、饮水、供水和供电会参与夜间结算，并真正改变五个人的健康、饱腹、水分和精神。按C可随时查看家庭状态。", 15, Color("cbd5d7")
	)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size.y = 78.0
	box.add_child(description)
	var controls := _make_label(
		"WASD / 方向键：移动　E：互动　B：背包　C：家庭状态　J：生存手册　T：快捷移动\nEsc：关闭界面　F1：测试工具　F5：保存　F9：读取", 14, Color("aebcc1")
	)
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(controls)
	var note := _make_label("测试时可用F1跳过重复流程；日期切换会等待你确认，不会自动闪过。", 13, Color("88979d"))
	box.add_child(note)
	var start_button := Button.new()
	start_button.text = "开始灾前第3天"
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


func set_progress_text(text: String) -> void:
	progress_label.text = text


func show_item_grid(
	title: String,
	subtitle: String,
	entries: Array,
	capacity: int = 0,
	primary_text: String = "",
	clickable: bool = false
) -> void:
	item_grid_title.text = title
	item_grid_subtitle.text = subtitle
	for child in item_grid.get_children():
		item_grid.remove_child(child)
		child.queue_free()
	var occupied_cells := 0
	for raw_entry in entries:
		var entry: Dictionary = raw_entry
		_add_item_grid_cell(entry, clickable)
		var span := maxi(1, int(entry.get("span", 1))) if capacity > 0 else 1
		occupied_cells += span
		for extra_index in range(span - 1):
			_add_occupied_grid_cell(str(entry.get("name", "物品")), extra_index)
	var empty_cells := maxi(0, capacity - occupied_cells)
	for index in range(empty_cells):
		_add_empty_grid_cell(index)
	item_grid_primary_button.text = primary_text
	item_grid_primary_button.visible = not primary_text.is_empty()
	item_grid_overlay.visible = true
	dialogue_panel.visible = false
	prompt_panel.visible = false


func hide_item_grid() -> void:
	item_grid_overlay.visible = false


func show_day_summary(
	title: String, subtitle: String, rows: Array, note: String, extra: Dictionary = {}
) -> void:
	day_summary_title.text = title
	day_summary_subtitle.text = subtitle
	for child in day_summary_rows.get_children():
		day_summary_rows.remove_child(child)
		child.queue_free()
	for raw_row in rows:
		var row: Dictionary = raw_row
		var row_panel := PanelContainer.new()
		row_panel.add_theme_stylebox_override(
			"panel", _panel_style(Color(0.09, 0.14, 0.16, 0.75), Color(0.25, 0.34, 0.36, 0.7), 8)
		)
		day_summary_rows.add_child(row_panel)
		var row_box := HBoxContainer.new()
		row_box.add_theme_constant_override("separation", 12)
		row_panel.add_child(row_box)
		var name_label := _make_label(str(row.get("name", "状态")), 14, Color("9eb8c0"))
		name_label.custom_minimum_size.x = 105.0
		row_box.add_child(name_label)
		var value_label := _make_label(str(row.get("value", "")), 14, Color("edf0e9"))
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row_box.add_child(value_label)
	day_summary_note.text = note
	if not extra.is_empty():
		if extra.has("rooms") and str(extra.get("rooms", "")) != "所有房间正常":
			var rooms_label := _make_label("房间状态：" + str(extra.get("rooms", "")), 12, Color("cbd5d7"))
			rooms_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			day_summary_rows.add_child(rooms_label)
		if extra.has("audio_hint"):
			var audio_label := _make_label("今晚的声音：" + str(extra.get("audio_hint", "")), 11, Color(0.5, 0.6, 0.65, 0.9))
			audio_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			day_summary_rows.add_child(audio_label)
	day_summary_overlay.visible = true
	dialogue_panel.visible = false
	prompt_panel.visible = false


func hide_day_summary() -> void:
	day_summary_overlay.visible = false


func show_family_status(members: Array, household: Dictionary) -> void:
	family_household_label.text = (
		"供水：%s　　供电：%s　　食物：%s　　储备饮水：%s　　备用电力：%s　　背包：%s"
		% [
			str(household.get("water", "未知")),
			str(household.get("power", "未知")),
			str(household.get("food", "0份")),
			str(household.get("water_reserve", "0升")),
			str(household.get("backup_power", "0格")),
			str(household.get("bag", "0/6格")),
		]
	)
	for child in family_cards.get_children():
		family_cards.remove_child(child)
		child.queue_free()
	for raw_member in members:
		var member: Dictionary = raw_member
		_add_family_card(member)
	family_overlay.visible = true
	dialogue_panel.visible = false
	item_grid_overlay.visible = false
	prompt_panel.visible = false


func hide_family_status() -> void:
	family_overlay.visible = false


func show_survival_manual(objective: String, inspection_entries: Array) -> void:
	manual_objective_label.text = objective if not objective.is_empty() else "尚无明确目标。"
	var lines: Array[String] = []
	for raw_entry in inspection_entries:
		if not (raw_entry is Dictionary):
			continue
		var entry: Dictionary = raw_entry
		lines.append(
			"%s\n%s\n记录时间：%s"
			% [
				str(entry.get("name", "未知对象")),
				str(entry.get("summary", "状态未知")),
				str(entry.get("checked_at", "尚未检查")),
			]
		)
	manual_records_label.text = (
		"\n\n".join(lines) if not lines.is_empty() else "尚未检查任何环境对象。"
	)
	manual_overlay.visible = true
	manual_overlay.move_to_front()
	prompt_panel.visible = false


func hide_survival_manual() -> void:
	manual_overlay.visible = false


func current_objective_text() -> String:
	return objective_label.text


func _add_family_card(member: Dictionary) -> void:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(214, 390)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override(
		"panel", _panel_style(Color(0.075, 0.115, 0.13, 0.92), Color(0.30, 0.40, 0.43, 0.85), 10)
	)
	family_cards.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	card.add_child(box)
	var name_label := _make_label(str(member.get("name", "成员")), 19, Color("eef1e9"))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(name_label)
	_add_member_metric(box, "健康", int(member.get("health", 100)), Color("81b88b"))
	_add_member_metric(box, "饱腹", int(member.get("hunger", 80)), Color("d2ad68"))
	_add_member_metric(box, "水分", int(member.get("thirst", 80)), Color("68abc2"))
	_add_member_metric(box, "精神", int(member.get("morale", 70)), Color("b08bc0"))
	var lowest := mini(
		int(member.get("health", 100)),
		mini(int(member.get("hunger", 100)), int(member.get("thirst", 100)))
	)
	var status := "状态正常"
	if lowest < 20:
		status = "情况危险"
	elif lowest < 40:
		status = "身体虚弱"
	elif lowest < 65:
		status = "需要留意"
	var status_label := _make_label(status, 13, Color("aebdc1"))
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(status_label)


func _add_member_metric(box: VBoxContainer, label_text: String, value: int, color: Color) -> void:
	var label := _make_label("%s　%d" % [label_text, value], 13, color)
	box.add_child(label)
	var progress := ProgressBar.new()
	progress.min_value = 0
	progress.max_value = 100
	progress.value = value
	progress.show_percentage = false
	progress.custom_minimum_size.y = 17.0
	box.add_child(progress)


func play_day_transition(date_text: String, time_text: String, detail_text: String) -> void:
	transition_waiting_for_confirm = false
	transition_date_label.text = date_text
	transition_time_label.text = time_text
	transition_detail_label.text = detail_text
	transition_continue_button.visible = false
	transition_continue_button.disabled = false
	transition_overlay.visible = true
	transition_overlay.modulate.a = 0.0
	transition_card.modulate.a = 0.0
	var fade_to_black := create_tween()
	fade_to_black.tween_property(transition_overlay, "modulate:a", 1.0, 0.55)
	await fade_to_black.finished
	day_transition_blackout.emit()
	await get_tree().process_frame
	var reveal_card := create_tween()
	reveal_card.tween_property(transition_card, "modulate:a", 1.0, 0.35)
	await reveal_card.finished
	transition_waiting_for_confirm = true
	transition_continue_button.visible = true
	transition_continue_button.grab_focus()


func _on_transition_continue_pressed() -> void:
	if not transition_waiting_for_confirm:
		return
	transition_waiting_for_confirm = false
	transition_continue_button.disabled = true
	var fade_from_black := create_tween()
	fade_from_black.tween_property(transition_overlay, "modulate:a", 0.0, 0.55)
	await fade_from_black.finished
	transition_overlay.visible = false
	transition_continue_button.visible = false
	transition_continue_button.disabled = false
	day_transition_finished.emit()


func toggle_quick_travel() -> void:
	if quick_travel_overlay.visible:
		hide_quick_travel()
	elif not is_blocking():
		quick_travel_overlay.visible = true
		quick_travel_overlay.move_to_front()


func hide_quick_travel() -> void:
	quick_travel_overlay.visible = false


func toggle_debug_menu() -> void:
	if not OS.is_debug_build():
		return
	if debug_overlay.visible:
		hide_debug_menu()
	elif not is_blocking():
		debug_overlay.visible = true
		debug_overlay.move_to_front()


func hide_debug_menu() -> void:
	debug_overlay.visible = false


func show_event_browser(entries: Array, validation_errors: Array[String] = []) -> void:
	hide_debug_menu()
	event_browser.show_entries(entries, validation_errors)


func hide_event_browser() -> void:
	if event_browser != null:
		event_browser.hide_browser()


func _on_quick_travel_pressed(location_id: String) -> void:
	hide_quick_travel()
	quick_travel_selected.emit(location_id)


func _on_survival_manual_pressed() -> void:
	if not is_blocking():
		survival_manual_requested.emit()


func _on_debug_action_pressed(action_id: String) -> void:
	hide_debug_menu()
	debug_action_selected.emit(action_id)


func _on_event_browser_preview_requested(event_id: String) -> void:
	event_browser_preview_requested.emit(event_id)


func _on_event_browser_reset_requested(event_id: String) -> void:
	event_browser_reset_requested.emit(event_id)


func is_item_grid_open() -> bool:
	return item_grid_overlay != null and item_grid_overlay.visible


func _add_item_grid_cell(entry: Dictionary, clickable: bool) -> void:
	var button := Button.new()
	button.custom_minimum_size = Vector2(168, 142)
	button.focus_mode = Control.FOCUS_NONE
	item_grid.add_child(button)

	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 7.0
	box.offset_top = 6.0
	box.offset_right = -7.0
	box.offset_bottom = -6.0
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	button.add_child(box)

	var item_id := str(entry.get("id", ""))
	var icon: StormItemIcon = ITEM_ICON_SCRIPT.new()
	icon.configure(item_id, int(entry.get("count", 1)))
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(icon)
	var name_label := _make_label(str(entry.get("name", item_id)), 14, Color("eef2ed"))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(name_label)
	var meta := str(entry.get("meta", ""))
	if not meta.is_empty():
		var meta_label := _make_label(meta, 11, Color("aab9bd"))
		meta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		meta_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.add_child(meta_label)
	if clickable:
		button.pressed.connect(_on_item_grid_item_pressed.bind(item_id))
	else:
		button.mouse_default_cursor_shape = Control.CURSOR_ARROW


func _add_empty_grid_cell(_index: int) -> void:
	var empty := PanelContainer.new()
	empty.custom_minimum_size = Vector2(168, 142)
	empty.add_theme_stylebox_override(
		"panel", _panel_style(Color(0.08, 0.12, 0.14, 0.45), Color(0.32, 0.39, 0.41, 0.45), 9)
	)
	item_grid.add_child(empty)
	var label := _make_label("空格", 12, Color(0.55, 0.62, 0.64, 0.55))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	empty.add_child(label)


func _add_occupied_grid_cell(item_name: String, _index: int) -> void:
	var occupied := PanelContainer.new()
	occupied.custom_minimum_size = Vector2(168, 142)
	occupied.add_theme_stylebox_override(
		"panel", _panel_style(Color(0.16, 0.20, 0.21, 0.70), Color(0.48, 0.53, 0.54, 0.68), 9)
	)
	item_grid.add_child(occupied)
	var label := _make_label("↳ %s\n占用此格" % item_name, 12, Color(0.67, 0.73, 0.74, 0.82))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	occupied.add_child(label)


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
	if day_summary_overlay != null and day_summary_overlay.visible:
		return
	if transition_overlay != null and transition_overlay.visible:
		return
	if event_browser != null and event_browser.visible:
		hide_event_browser()
		return
	if debug_overlay != null and debug_overlay.visible:
		hide_debug_menu()
		return
	if quick_travel_overlay != null and quick_travel_overlay.visible:
		hide_quick_travel()
		return
	if manual_overlay != null and manual_overlay.visible:
		hide_survival_manual()
		return
	if family_overlay != null and family_overlay.visible:
		hide_family_status()
		return
	if is_item_grid_open():
		hide_item_grid()
		item_grid_closed.emit()
	elif dialogue_panel.visible:
		hide_dialogue()


func is_blocking() -> bool:
	return (
		(intro_overlay != null and intro_overlay.visible)
		or (dialogue_panel != null and dialogue_panel.visible)
		or (item_grid_overlay != null and item_grid_overlay.visible)
		or (day_summary_overlay != null and day_summary_overlay.visible)
		or (transition_overlay != null and transition_overlay.visible)
		or (family_overlay != null and family_overlay.visible)
		or (manual_overlay != null and manual_overlay.visible)
		or (quick_travel_overlay != null and quick_travel_overlay.visible)
		or (debug_overlay != null and debug_overlay.visible)
		or (event_browser != null and event_browser.visible)
	)


func show_toast(message: String, duration: float = 2.4) -> void:
	toast_label.text = message
	toast_panel.visible = true
	toast_panel.move_to_front()
	toast_timer.start(duration)


func _on_intro_button_pressed() -> void:
	intro_overlay.visible = false
	intro_started.emit()


func _on_choice_button_pressed(index: int) -> void:
	choice_selected.emit(index)


func _on_item_grid_item_pressed(item_id: String) -> void:
	item_grid_item_selected.emit(item_id)


func _on_item_grid_primary_pressed() -> void:
	item_grid_primary.emit()


func _on_item_grid_close_pressed() -> void:
	hide_item_grid()
	item_grid_closed.emit()


func _on_day_summary_confirmed() -> void:
	day_summary_confirmed.emit()


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
