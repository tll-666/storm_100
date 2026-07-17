extends Node2D

const DIALOGUES := {
	"partner":
	{
		"name": "伴侣",
		"text": "米快吃完了，顺便买点菜。卫生用品和清洁用品也不多了。天气预报说晚上有雨，早点回来。",
		"choices": ["都记下了。", "钱可能不够。", "雨应该没那么严重。"],
		"follows":
		[
			"伴侣点点头，又提醒你别忘了把车停回车库。",
			"“先买真正缺的，别为了打折买一堆用不上的东西。”",
			"“希望吧。社区群里已经有人问排水沟的事了。”",
		],
		"repeats":
		[
			"你答应过都记下来。伴侣问你有没有漏掉什么。",
			"伴侣没有催你，只说先买真正缺少的东西。",
			"伴侣望向窗外：“但愿真像你说的那样。”",
		],
		"relations": [1, 0, -1],
		"flags": ["partner_reassured", "essentials_first", "dismissed_rain"],
	},
	"teen":
	{
		"name": "大孩子",
		"text": "能帮我看看充电宝吗？下午社团结束得晚。再带几包方便面和电池，学校设备最近总没电。",
		"choices": ["我尽量。", "先买家里必需的。", "下雨我开车接你。"],
		"follows":
		[
			"“那我放学前给你发消息。”",
			"“知道了……但你别又联系不上我。”",
			"大孩子看了眼窗外：“那你记得看消息。”",
		],
		"repeats":
		[
			"大孩子又问了一句：“充电宝真的会看吗？”",
			"大孩子没再提充电宝，只提醒你手机别静音。",
			"大孩子说：“你答应下雨来接我的，别忘了。”",
		],
		"relations": [0, -1, 1],
		"flags": ["teen_try", "teen_refused", "promised_pickup"],
	},
	"child":
	{
		"name": "小孩子",
		"text": "可以买牛奶、巧克力，还有带卡片的方便面吗？下雨天在家吃最好了。",
		"choices": ["只能选两样。", "看钱够不够。", "先把饭吃完。"],
		"follows":
		[
			"小孩子认真想了一会，最后小声说想要牛奶和巧克力。",
			"“那我不要很贵的。”",
			"小孩子低头看了看碗，又悄悄望向窗外的云。",
		],
		"repeats": ["小孩子还在纠结那两样东西。", "小孩子说自己挑便宜的就好。", "小孩子没有再提零食，只盯着窗外。"],
		"relations": [0, 1, -1],
		"flags": ["child_two_items", "child_considerate", "child_brushed_off"],
	},
	"elder":
	{
		"name": "老人",
		"text": "看见鱼罐头就带两盒。收音机电池也没电了，瓶装水有地方就放几瓶。",
		"choices": ["您还挺会准备。", "预报只说下几天。", "先买电池。"],
		"follows":
		[
			"“不是准备。年纪大了，就喜欢家里有点存货。”",
			"“以前也下过大雨。排水河没堵就没事。”",
			"“也行。手机没信号的时候，收音机比人可靠。”",
		],
		"repeats": ["老人笑了笑：“家里有存货，心里才不慌。”", "老人提起那条排水河，似乎仍有些不放心。", "老人又转了转收音机没有电的旋钮。"],
		"relations": [1, 0, 1],
		"flags": ["elder_stock", "elder_drains", "radio_first"],
	},
}

const INSPECTIONS := {
	"car": ["汽车和后备箱", "油箱只剩三分之一。后备箱很宽，普通购物可以按10格计算；真正外出时个人只能携带6格。"],
	"garage_drain": ["车库排水口", "排水口周围积着灰尘和落叶。车库地面比住宅低，将来会是最早积水的位置。"],
	"fridge": ["冰箱", "只剩少量肉、鸡蛋、牛奶和蔬菜，大约够一家人吃两天。"],
	"pantry": ["食品柜", "米缸快见底了，旁边还有几包方便面。这里将是家庭食品储存的主要位置。"],
	"radio": ["收音机", "旋钮转动时只有沙沙声。电池已经没什么电了。"],
	"bathroom": ["厕所 / 洗衣区", "卫生用品和清洁用品都快用完了。二楼厕所与这里共用一条上下水管线。"],
	"breaker": ["配电箱", "线路看起来很旧。连续潮湿以后，这里可能出现跳闸或短路。"],
	"front_yard": ["住宅街", "街道地势向排水河方向缓慢下降。现在路面干燥，只有风比平时更大。"],
	"balcony_drain": ["二楼阳台", "公共阳台位于车库上方。排水口落着几片叶子，角落可以放接雨水的容器。"],
	"balcony_view": ["阳台外", "从这里能看见住宅街和远处的排水河方向。后期也可以用于观察、求救和接收投递。"],
	"teen_desk": ["大孩子的书桌", "充电宝只有一半电，充电线被压在书本下面。"],
	"child_toys": ["小孩子的玩具柜", "玩具和绘本塞得很满。长时间不能外出时，这里会影响小孩子的情绪。"],
}

const STORE_SHELVES := {
	"shelf_food":
	{
		"name": "主食和罐头",
		"text": "货架还很整齐。大米比较占地方，方便面和罐头更容易塞进后备箱。",
		"items": ["rice", "noodles", "canned_fish"],
	},
	"shelf_fresh":
	{
		"name": "蔬菜和零食",
		"text": "今天看起来只是普通采购，蔬菜、牛奶和巧克力都没有限购。",
		"items": ["vegetables", "milk", "chocolate"],
	},
	"shelf_daily":
	{
		"name": "卫生和清洁用品",
		"text": "卫生纸体积不小。清洁用品和瓶装水摆在旁边，没有人抢购。",
		"items": ["toilet_paper", "cleaner", "bottled_water"],
	},
	"shelf_power":
	{
		"name": "电池、充电和常用药",
		"text": "充电宝明显比其他东西贵。收银台旁的小药架只放着最普通的家庭常用药。",
		"items": ["batteries", "power_bank", "basic_medicine"],
	},
	"shelf_drinks":
	{
		"name": "饮料冷柜",
		"text": "冷柜发出稳定的嗡鸣声。牛奶、巧克力和瓶装水都能从这里拿到。",
		"items": ["milk", "chocolate", "bottled_water"],
	},
}

var current_floor: int = 1
var current_target: InteractionObject
var pending_action: Dictionary = {}
var game_started: bool = false
var pending_day_transition: String = ""

@onready var world: HouseWorld = $World
@onready var player: StormPlayer = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var hud: StormHUD = $HUD


func _ready() -> void:
	world.build_floor(current_floor)
	player.global_position = world.spawn_position(current_floor)
	player.movement_enabled = false
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(HouseWorld.WORLD_SIZE.x)
	camera.limit_bottom = int(HouseWorld.WORLD_SIZE.y)
	hud.intro_started.connect(_on_intro_started)
	hud.choice_selected.connect(_on_choice_selected)
	hud.item_grid_item_selected.connect(_on_item_grid_item_selected)
	hud.item_grid_primary.connect(_on_item_grid_primary)
	hud.item_grid_closed.connect(_on_item_grid_closed)
	hud.day_summary_confirmed.connect(_on_day_summary_confirmed)
	hud.day_transition_blackout.connect(_on_day_transition_blackout)
	hud.day_transition_finished.connect(_on_day_transition_finished)
	hud.quick_travel_selected.connect(_on_quick_travel_selected)
	hud.debug_action_selected.connect(_on_debug_action_selected)
	hud.event_browser_preview_requested.connect(_on_event_browser_preview_requested)
	hud.event_browser_reset_requested.connect(_on_event_browser_reset_requested)
	_update_hud()


func _process(_delta: float) -> void:
	player.movement_enabled = game_started and not hud.is_blocking()
	if not game_started or hud.is_blocking():
		current_target = null
		world.get_nearest_interactable(Vector2(-10000.0, -10000.0), 1.0)
		hud.set_prompt("")
		return
	current_target = world.get_nearest_interactable(player.global_position)
	var prompt := current_target.prompt_text if current_target != null else ""
	if current_target != null and current_target.object_id == "car" and _ready_for_store():
		prompt = "开车去社区超市"
	if current_target != null and current_target.object_id == "day_planner":
		if GameState.phase_id == "pre_rain_day_3_after_first_shop":
			prompt = "安排今天下午"
		elif GameState.phase_id == "pre_rain_day_2_clues":
			prompt = "根据线索安排重点准备"
		elif GameState.phase_id == "pre_rain_day_2_notices":
			prompt = "查看学校和社区通知"
		elif GameState.phase_id == "pre_rain_day_2_evening":
			prompt = "和家人讨论明天"
	if current_target != null and current_target.object_id == "master_bed":
		if GameState.phase_id in ["pre_rain_day_3_evening", "pre_rain_day_2_bedtime"]:
			prompt = "结束今天"
	hud.set_prompt(prompt)


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		hud.close_top_overlay()
		pending_action.clear()
		return
	if event.keycode == KEY_T and game_started:
		hud.toggle_quick_travel()
		return
	if event.keycode == KEY_F1 and game_started and OS.is_debug_build():
		hud.toggle_debug_menu()
		return
	if event.keycode == KEY_B and game_started and not hud.is_blocking():
		_open_personal_inventory()
		return
	if event.keycode == KEY_C and game_started and not hud.is_blocking():
		_open_family_status()
		return
	if event.keycode == KEY_E and game_started and not hud.is_blocking():
		_interact_with_current_target()
		return
	if event.keycode == KEY_F5 and game_started:
		var saved := GameState.save_checkpoint(player.global_position, current_floor)
		hud.show_toast("检查点已保存。" if saved else "保存失败。")
		return
	if event.keycode == KEY_F9 and game_started:
		_load_checkpoint()


func _interact_with_current_target() -> void:
	if current_target == null:
		return
	match current_target.category:
		"npc":
			_start_npc_dialogue(current_target.object_id)
		"stairs":
			_switch_floor(2 if current_target.object_id == "stairs_up" else 1)
		"inspect":
			_inspect_object(current_target.object_id)
		"shop":
			_open_shop_shelf(current_target.object_id)
		"checkout":
			_open_checkout()
		"store_exit":
			_open_store_exit()
		"time_action":
			_handle_time_action(current_target.object_id)


func _start_npc_dialogue(character_id: String) -> void:
	if not DIALOGUES.has(character_id):
		return
	var data: Dictionary = DIALOGUES[character_id]
	if GameState.dialogue_choices.has(character_id):
		var chosen := int(GameState.dialogue_choices[character_id])
		pending_action = {"type": "close"}
		hud.show_dialogue(str(data.name), str(data.repeats[chosen]), ["结束对话"])
		return
	pending_action = {"type": "npc_choice", "character_id": character_id}
	var choices: Array[String] = []
	choices.assign(data.choices)
	hud.show_dialogue(str(data.name), str(data.text), choices)


func _inspect_object(object_id: String) -> void:
	if object_id == "radio" and GameState.phase_id == "pre_rain_day_3_afternoon":
		_open_evening_forecast()
		return
	if object_id == "radio" and GameState.phase_id == "pre_rain_day_2_morning":
		_open_day_two_weather_event()
		return
	if GameState.phase_id == "pre_rain_day_2_clues":
		var clue_events := {
			"radio": "d2_clue_radio",
			"balcony_view": "d2_clue_balcony",
			"front_yard": "d2_clue_street",
			"garage_drain": "d2_clue_garage",
		}
		if clue_events.has(object_id) and EventManager.is_available(str(clue_events[object_id])):
			_open_database_event(str(clue_events[object_id]))
			return
	if object_id == "car" and _ready_for_store():
		pending_action = {"type": "travel_to_store"}
		hud.show_dialogue(
			"汽车",
			"需求已经记得差不多了。现在去社区超市，回来后再处理下午的安排。",
			["开车去超市", "再检查一下"]
		)
		return
	if not INSPECTIONS.has(object_id):
		return
	if object_id in ["fridge", "pantry", "bathroom"]:
		GameState.record_inspection(object_id)
		_open_home_container(object_id)
		_update_hud()
		return
	var info: Array = INSPECTIONS[object_id]
	if object_id == "car" and GameState.has_flag("first_shopping_complete"):
		info = ["汽车和后备箱", "第一次购物已经搬回家。油箱仍然只剩三分之一，下午是否开车还需要考虑。"]
	GameState.record_inspection(object_id)
	pending_action = {"type": "close"}
	hud.show_dialogue(str(info[0]), str(info[1]), ["记下了"])
	_update_hud()


func _on_choice_selected(index: int) -> void:
	var action_type := str(pending_action.get("type", "close"))
	if action_type == "close":
		hud.hide_dialogue()
		pending_action.clear()
		return
	if action_type == "travel_to_store":
		hud.hide_dialogue()
		pending_action.clear()
		if index == 0:
			_enter_supermarket()
		return
	if action_type == "store_exit":
		hud.hide_dialogue()
		pending_action.clear()
		return
	if action_type == "return_summary":
		hud.hide_dialogue()
		pending_action.clear()
		hud.show_toast("到客厅餐桌旁安排今天下午。", 3.0)
		_update_hud()
		return
	if action_type == "afternoon_plan":
		_handle_afternoon_plan_choice(index)
		return
	if action_type == "evening_forecast":
		_handle_evening_forecast_choice(index)
		return
	if action_type == "end_day":
		if index == 0:
			hud.hide_dialogue()
			pending_action.clear()
			_show_night_summary()
		else:
			hud.hide_dialogue()
			pending_action.clear()
		return
	if action_type == "day_two_morning":
		hud.hide_dialogue()
		pending_action.clear()
		return
	if action_type == "database_event":
		var event_id := str(pending_action.get("event_id", ""))
		var force := bool(pending_action.get("force", false))
		var result: Dictionary = EventManager.apply_choice(event_id, index, force)
		if not bool(result.get("ok", false)):
			hud.hide_dialogue()
			pending_action.clear()
			hud.show_toast(str(result.get("error", "事件无法执行。")))
			return
		pending_action = {"type": "close"}
		hud.show_dialogue(
			str(EventManager.event_data(event_id).get("title", "事件结果")),
			str(result.get("result", "")),
			["继续"]
		)
		_update_hud()
		return
	if action_type == "end_day_two":
		hud.hide_dialogue()
		pending_action.clear()
		if index == 0:
			_show_day_two_summary()
		return
	if action_type != "npc_choice":
		return
	var character_id := str(pending_action.character_id)
	var data: Dictionary = DIALOGUES[character_id]
	var safe_index := clampi(index, 0, data.choices.size() - 1)
	GameState.record_dialogue_choice(
		character_id, safe_index, int(data.relations[safe_index]), str(data.flags[safe_index])
	)
	pending_action = {"type": "close"}
	hud.show_dialogue(str(data.name), str(data.follows[safe_index]), ["结束对话"])
	_update_hud()


func _switch_floor(floor_number: int) -> void:
	current_floor = floor_number
	world.build_floor(current_floor)
	player.global_position = world.spawn_position(current_floor)
	hud.show_toast("来到二楼和公共阳台。" if current_floor == 2 else "回到一楼。")
	_update_hud()


func _on_quick_travel_selected(location_id: String) -> void:
	if current_floor == 3:
		hud.show_toast("正在超市购物，先从出口或收银台回家。")
		return
	var destinations := {
		"living_room": {"floor": 1, "position": Vector2(825.0, 605.0), "name": "一楼客厅"},
		"garage": {"floor": 1, "position": Vector2(350.0, 720.0), "name": "一楼车库"},
		"master_bedroom": {"floor": 2, "position": Vector2(650.0, 275.0), "name": "二楼主卧"},
		"balcony": {"floor": 2, "position": Vector2(330.0, 735.0), "name": "二楼公共阳台"},
	}
	if not destinations.has(location_id):
		return
	var destination: Dictionary = destinations[location_id]
	current_floor = int(destination.floor)
	world.build_floor(current_floor)
	player.global_position = destination.position
	current_target = null
	pending_action.clear()
	hud.show_toast("已快捷移动到%s；没有推进时间。" % str(destination.name))
	_update_hud()


func _on_debug_action_selected(action_id: String) -> void:
	match action_id:
		"unlock_car":
			_debug_unlock_car()
			hud.show_toast("测试：前置调查已完成，现在可以直接去车库开车。", 3.2)
		"go_store":
			_debug_unlock_car()
			_enter_supermarket()
		"after_shop":
			_debug_skip_after_shop()
			hud.show_toast("测试：已跳到第一次购物回家后。")
		"evening_bed":
			_debug_skip_to_evening_bed()
			hud.show_toast("测试：已跳到晚上，并来到主卧床边。")
		"day_two":
			_debug_skip_to_day_two()
		"event_browser":
			hud.show_event_browser(EventManager.debug_entries())
		"reset":
			_debug_reset_run()


func _on_event_browser_preview_requested(event_id: String) -> void:
	_open_database_event(event_id, true)


func _on_event_browser_reset_requested(event_id: String) -> void:
	EventManager.debug_reset_event(event_id)
	hud.show_event_browser(EventManager.debug_entries())
	hud.show_toast("已允许事件重新触发；已经产生的资源和人物后果不会自动回滚。", 3.5)


func _debug_unlock_car() -> void:
	for character_id in ["partner", "teen", "child", "elder"]:
		GameState.talked_to[character_id] = true
	for object_id in ["car", "garage_drain", "fridge", "pantry", "balcony_drain"]:
		GameState.inspected[object_id] = true
	GameState.flags["debug_prerequisites"] = true
	if current_floor == 3:
		current_floor = 1
		world.build_floor(current_floor)
		player.global_position = Vector2(350.0, 720.0)
	_update_hud()


func _debug_skip_after_shop() -> void:
	_debug_unlock_car()
	GameState.shopping_cart.clear()
	GameState.flags["first_shopping_complete"] = true
	GameState.phase_id = "pre_rain_day_3_after_first_shop"
	GameState.day_label = "暴雨前第3天"
	GameState.time_label = "上午11:45"
	GameState.time_segment = "daytime"
	GameState.weather_label = "阴 · 风声渐紧"
	current_floor = 1
	world.build_floor(current_floor)
	player.global_position = Vector2(825.0, 605.0)
	current_target = null
	pending_action.clear()
	_update_hud()


func _debug_skip_to_evening_bed() -> void:
	_debug_skip_after_shop()
	if GameState.afternoon_plan.is_empty():
		GameState.afternoon_plan = "inspect_house"
	GameState.flags["evening_forecast_heard"] = true
	GameState.phase_id = "pre_rain_day_3_evening"
	GameState.time_label = "晚上19:10"
	GameState.time_segment = "evening"
	GameState.weather_label = "阴 · 远处偶有闷雷"
	current_floor = 2
	world.build_floor(current_floor)
	player.global_position = Vector2(650.0, 275.0)
	_update_hud()


func _debug_skip_to_day_two() -> void:
	_debug_skip_after_shop()
	GameState.flags["day_three_settled"] = true
	GameState.begin_day_two()
	current_floor = 1
	world.build_floor(current_floor)
	player.global_position = Vector2(790.0, 735.0)
	pending_action = {"type": "day_two_morning"}
	_update_hud()
	hud.show_dialogue(
		"测试跳转 · 第二天清晨",
		"已经绕过前一天的重复流程。现在可以直接测试第二天的天气提醒。",
		["开始测试第二天"]
	)


func _debug_reset_run() -> void:
	hud.hide_dialogue()
	hud.hide_item_grid()
	hud.hide_family_status()
	hud.hide_quick_travel()
	hud.hide_debug_menu()
	hud.hide_event_browser()
	GameState.reset_prologue()
	current_floor = 1
	world.build_floor(current_floor)
	player.global_position = world.spawn_position(current_floor)
	current_target = null
	pending_action.clear()
	game_started = true
	hud.show_toast("测试进度已经重置。", 2.8)
	_update_hud()


func _on_intro_started() -> void:
	game_started = true
	hud.show_toast("先和四位家人交谈，并检查至少5处关键位置。", 3.2)


func _load_checkpoint() -> void:
	var payload := GameState.load_checkpoint()
	if payload.is_empty():
		hud.show_toast("还没有可读取的检查点。")
		return
	current_floor = int(payload.get("current_floor", 1))
	world.build_floor(current_floor)
	player.global_position = Vector2(
		float(payload.get("player_x", 790.0)), float(payload.get("player_y", 735.0))
	)
	hud.show_toast("已读取检查点。")
	_update_hud()


func _update_hud() -> void:
	if current_floor == 3:
		hud.set_context(
			"%s · %s" % [GameState.day_label, GameState.time_label],
			GameState.weather_label,
			"社区超市",
			"在220元和10格后备箱限制下购物，最后到收银台确认。"
		)
		hud.set_progress_text(
			"预算 ¥%d · 后备箱 %d/%d格 · 购物篮 ¥%d"
			% [GameState.money, GameState.cart_slots(), GameState.trunk_capacity, GameState.cart_total()]
		)
		return
	var place := "家 · 一楼 / 前院" if current_floor == 1 else "家 · 二楼 / 公共阳台"
	var talked_count := GameState.talked_to.size()
	var inspected_count := GameState.inspected.size()
	var objective := "与四位家人交谈，检查房屋关键位置。"
	if talked_count >= 4:
		objective = "家人的需求已经记下。继续检查车库、厨房和阳台。"
	if talked_count >= 4 and inspected_count >= 5:
		objective = "需求已经记下：到车库开车去社区超市。"
	if GameState.has_flag("first_shopping_complete"):
		match GameState.phase_id:
			"pre_rain_day_3_after_first_shop":
				objective = "第一次购物完成：到一楼餐桌旁安排今天下午。"
			"pre_rain_day_3_afternoon":
				objective = "下午已经过去：到客厅收音机旁听傍晚天气预报。"
			"pre_rain_day_3_evening":
				objective = "今天的行动结束：到二楼主卧床铺旁结束今天。"
			"pre_rain_day_2_morning":
				objective = "第二天清晨：到客厅检查收音机，确认最新天气提醒。"
			"pre_rain_day_2_clues":
				objective = "从收音机、阳台、住宅街或车库取得至少两条额外线索。"
			"pre_rain_day_2_notices":
				objective = "重点准备已完成：到客厅餐桌查看学校和社区通知。"
			"pre_rain_day_2_evening":
				objective = "通知已经确认：到客厅餐桌和家人讨论明天。"
			"pre_rain_day_2_bedtime":
				objective = "今天的准备已经结束：到二楼主卧睡觉。"
			"pre_rain_day_1_morning":
				objective = "零星小雨已经开始。接人和第二次购物将在v0.7继续。"
	hud.set_context(
		"%s · %s" % [GameState.day_label, GameState.time_label],
		GameState.weather_label,
		place,
		objective
	)
	if GameState.has_flag("first_shopping_complete"):
		var segment_text := "上午"
		match GameState.time_segment:
			"daytime":
				segment_text = "白天"
			"evening":
				segment_text = "晚上"
			"night":
				segment_text = "夜间"
		if GameState.phase_id == "pre_rain_day_2_clues":
			hud.set_progress_text("已知线索 %d/3 · 再调查房屋或外部环境" % mini(GameState.clues.size(), 3))
		elif GameState.phase_id.begins_with("pre_rain_day_2") and not GameState.day_two_preparation.is_empty():
			hud.set_progress_text("%s阶段 · 今日准备：%s" % [segment_text, GameState.day_two_preparation_label()])
		else:
			hud.set_progress_text("%s阶段 · 剩余 ¥%d" % [segment_text, GameState.money])
	else:
		hud.set_progress(talked_count, inspected_count)


func _ready_for_store() -> bool:
	return (
		current_floor == 1
		and GameState.talked_to.size() >= 4
		and GameState.inspected.size() >= 5
		and not GameState.has_flag("first_shopping_complete")
	)


func _enter_supermarket() -> void:
	current_floor = 3
	GameState.phase_id = "pre_rain_day_3_first_shop"
	GameState.time_label = "上午10:20"
	GameState.time_segment = "daytime"
	GameState.weather_label = "阴 · 风比早上更大"
	world.build_floor(current_floor)
	player.global_position = world.spawn_position(current_floor)
	hud.show_toast("社区超市：商品没有限购，但预算和后备箱空间有限。", 3.2)
	_update_hud()


func _open_shop_shelf(shelf_id: String) -> void:
	if not STORE_SHELVES.has(shelf_id):
		return
	var shelf: Dictionary = STORE_SHELVES[shelf_id]
	var item_ids: Array[String] = []
	item_ids.assign(shelf.get("items", []))
	var entries: Array = []
	for item_id in item_ids:
		var item := GameState.shop_item(item_id)
		entries.append(
			{
				"id": item_id,
				"name": str(item.get("name", item_id)),
				"count": 1,
				"meta": "¥%d · %s" % [int(item.get("price", 0)), _survival_item_meta(item)],
			}
		)
	pending_action = {"type": "shop_grid", "shelf_id": shelf_id}
	hud.show_item_grid(
		str(shelf.get("name", "货架")),
		"%s\n点击商品图标拿取。当前购物篮：%d/%d格，预计¥%d，剩余预算¥%d。"
		% [
			str(shelf.get("text", "")),
			GameState.cart_slots(),
			GameState.trunk_capacity,
			GameState.cart_total(),
			GameState.money - GameState.cart_total(),
		],
		entries,
		0,
		"",
		true
	)


func _open_checkout() -> void:
	var entries := _entries_from_item_list(GameState.shopping_cart, true)
	var instruction := "购物篮为空。你也可以不购物，直接结束这次采购。"
	if not GameState.shopping_cart.is_empty():
		instruction = "点击商品图标可放回一件，然后用下方按钮结账。"
	pending_action = {"type": "cart_grid"}
	hud.show_item_grid(
		"后备箱购物篮",
		"%s\n合计¥%d，占用%d/%d格，结账后剩余¥%d。"
		% [
			instruction,
			GameState.cart_total(),
			GameState.cart_slots(),
			GameState.trunk_capacity,
			GameState.money - GameState.cart_total(),
		],
		entries,
		GameState.trunk_capacity,
		"不购物，直接回家" if GameState.shopping_cart.is_empty() else "结账并回家",
		true
	)


func _on_item_grid_item_selected(item_id: String) -> void:
	var action_type := str(pending_action.get("type", ""))
	if action_type == "shop_grid":
		var shelf_id := str(pending_action.get("shelf_id", ""))
		var error := GameState.try_add_shop_item(item_id)
		if not error.is_empty():
			hud.show_toast(error, 3.0)
		else:
			var item := GameState.shop_item(item_id)
			hud.show_toast("已放入购物篮：%s" % str(item.get("name", item_id)))
		_open_shop_shelf(shelf_id)
		_update_hud()
		return
	if action_type == "cart_grid":
		if GameState.remove_shop_item(item_id):
			var item := GameState.shop_item(item_id)
			hud.show_toast("已放回货架：%s" % str(item.get("name", item_id)))
		_open_checkout()
		_update_hud()
		return
	if action_type == "container_grid":
		var container_id := str(pending_action.get("container_id", ""))
		var error := GameState.try_take_from_container(container_id, item_id)
		if error.is_empty():
			var item := GameState.shop_item(item_id)
			hud.show_toast("已放入背包：%s" % str(item.get("name", item_id)))
		else:
			hud.show_toast(error, 3.0)
		_open_home_container(container_id)
		return
	if action_type == "inventory_grid":
		if GameState.return_inventory_item(item_id):
			var item := GameState.shop_item(item_id)
			hud.show_toast("已放回家中：%s" % str(item.get("name", item_id)))
		_open_personal_inventory()


func _on_item_grid_primary() -> void:
	if str(pending_action.get("type", "")) != "cart_grid":
		return
	hud.hide_item_grid()
	_finish_first_shopping()


func _on_item_grid_closed() -> void:
	pending_action.clear()
	_update_hud()


func _open_home_container(object_id: String) -> void:
	var storage: Dictionary = {}
	var title := "家庭储物"
	var subtitle := "这里存放着家中的物资。当前版本先测试图标与数量显示。"
	var capacity := 10
	match object_id:
		"fridge":
			storage = GameState.fridge_storage
			title = "冰箱"
			subtitle = "冷藏食品。购物回家后，牛奶和蔬菜会自动放到这里。"
			capacity = 12
		"pantry":
			storage = GameState.pantry_storage
			title = "食品柜"
			subtitle = "常温食品。米、面、罐头、水和零食会存放在这里。"
			capacity = 15
		"bathroom":
			storage = GameState.utility_storage
			title = "卫生 / 洗衣储物柜"
			subtitle = "卫生与清洁物资。电池、充电宝和常用药暂时也收在这个柜中。"
			capacity = 10
	subtitle += "\n点击物品可放入随身背包；大件仍会占用两格。"
	pending_action = {"type": "container_grid", "container_id": object_id}
	hud.show_item_grid(title, subtitle, _entries_from_storage(storage), capacity, "", true)


func _open_personal_inventory() -> void:
	pending_action = {"type": "inventory_grid"}
	hud.show_item_grid(
		"随身背包",
		"个人最多携带%d格，当前使用%d格。点击物品可自动放回对应的家庭储物位置。"
		% [GameState.personal_capacity, GameState.inventory_slots()],
		_entries_from_item_list(GameState.inventory),
		GameState.personal_capacity,
		"",
		true
	)


func _open_family_status() -> void:
	hud.show_family_status(GameState.family_status_entries(), GameState.household_status())


func _entries_from_item_list(item_ids: Array, removable: bool = false) -> Array:
	var counts: Dictionary = {}
	var order: Array[String] = []
	for raw_id in item_ids:
		var item_id := str(raw_id)
		if not counts.has(item_id):
			order.append(item_id)
		counts[item_id] = int(counts.get(item_id, 0)) + 1
	var entries: Array = []
	for item_id in order:
		var item := GameState.shop_item(item_id)
		var slots_per_item := int(item.get("slots", 1))
		var meta := _survival_item_meta(item)
		if removable:
			meta += " · 点击放回一件"
		entries.append(
			{
				"id": item_id,
				"name": str(item.get("name", item_id)),
				"count": int(counts[item_id]),
				"meta": meta,
				"span": int(counts[item_id]) * slots_per_item,
			}
		)
	return entries


func _entries_from_storage(storage: Dictionary) -> Array:
	var entries: Array = []
	for raw_id in storage:
		var item_id := str(raw_id)
		var count := int(storage[raw_id])
		if count <= 0:
			continue
		var item := GameState.shop_item(item_id)
		entries.append(
			{
				"id": item_id,
				"name": str(item.get("name", item_id)),
				"count": count,
				"meta": _survival_item_meta(item),
				"span": count * int(item.get("slots", 1)),
			}
		)
	return entries


func _survival_item_meta(item: Dictionary) -> String:
	var parts: Array[String] = ["%d格/件" % int(item.get("slots", 1))]
	if int(item.get("food", 0)) > 0:
		parts.append("%d份食物" % int(item.get("food", 0)))
	if float(item.get("water_liters", 0.0)) > 0.0:
		parts.append("%.0f升水" % float(item.get("water_liters", 0.0)))
	return " · ".join(parts)


func _open_store_exit() -> void:
	pending_action = {"type": "store_exit"}
	hud.show_dialogue("超市出口", "离开前需要到收银台确认。即使决定什么都不买，也从收银台结束这次购物。", ["返回"])


func _finish_first_shopping() -> void:
	hud.hide_item_grid()
	var spent := GameState.cart_total()
	if not GameState.complete_shopping():
		hud.show_toast("结账没有完成。")
		return
	var reactions := _apply_shopping_reactions()
	current_floor = 1
	GameState.phase_id = "pre_rain_day_3_after_first_shop"
	GameState.time_label = "上午11:45"
	GameState.time_segment = "daytime"
	GameState.weather_label = "阴 · 风声渐紧"
	world.build_floor(current_floor)
	player.global_position = Vector2(340.0, 735.0)
	_update_hud()
	pending_action = {"type": "return_summary"}
	hud.show_dialogue(
		"回到家",
		"你把东西从后备箱搬进家里。这次一共花了¥%d，剩余¥%d。\n\n%s"
		% [spent, GameState.money, reactions],
		["继续在家查看"]
	)


func _handle_time_action(object_id: String) -> void:
	match object_id:
		"day_planner":
			_open_day_planner()
		"master_bed":
			_open_master_bed()


func _open_day_planner() -> void:
	match GameState.phase_id:
		"pre_rain_day_2_clues":
			if not EventManager.is_available("d2_preparation"):
				pending_action = {"type": "close"}
				hud.show_dialogue(
					"餐桌上的便签",
					"目前的信息还太少。再检查收音机、阳台、住宅街或车库，至少获得三条线索后再决定。",
					["继续调查"]
				)
				return
			_open_database_event("d2_preparation")
			return
		"pre_rain_day_2_notices":
			_open_database_event("d2_school_notice")
			return
		"pre_rain_day_2_evening":
			_open_database_event("d2_evening_discussion")
			return
	if not GameState.has_flag("first_shopping_complete"):
		pending_action = {"type": "close"}
		hud.show_dialogue("餐桌", "购物清单还没有处理完，现在安排下午还太早。", ["离开"])
		return
	if GameState.phase_id != "pre_rain_day_3_after_first_shop":
		pending_action = {"type": "close"}
		hud.show_dialogue(
			"餐桌",
			"下午的安排已经确定：%s。" % GameState.afternoon_plan_label(),
			["离开"]
		)
		return
	pending_action = {"type": "afternoon_plan"}
	hud.show_dialogue(
		"午后的安排",
		"购物袋已经搬进屋。下午只能认真完成一件事，其他琐事由家人自行处理。",
		["分类整理物资", "复查排水与电路", "陪家人吃午饭"]
	)


func _handle_afternoon_plan_choice(index: int) -> void:
	var plan_ids := ["organize_supplies", "inspect_house", "family_time"]
	var safe_index := clampi(index, 0, plan_ids.size() - 1)
	var result := GameState.apply_afternoon_plan(plan_ids[safe_index])
	pending_action = {"type": "close"}
	hud.show_dialogue(
		"下午15:30",
		"%s\n\n时间向前推进了几个小时。窗外仍没下雨，但风吹动树叶的声音越来越密。"
		% result,
		["继续"]
	)
	_update_hud()


func _open_evening_forecast() -> void:
	var source_text := "你给收音机换上刚买的电池，沙沙声后终于出现清晰播报。"
	if not GameState.storage_has_any(["batteries"]):
		source_text = "收音机仍然没有电。就在这时，手机弹出了本地气象台的紧急更新。"
	pending_action = {"type": "evening_forecast"}
	hud.show_dialogue(
		"傍晚天气信息",
		"%s\n\n未来两天出现持续强降雨的概率上调。低洼住宅应检查排水设施，并留意后续预警。"
		% source_text,
		["提醒大家明早继续准备", "现在再检查一遍门窗", "先别让孩子紧张"]
	)


func _handle_evening_forecast_choice(index: int) -> void:
	var safe_index := clampi(index, 0, 2)
	var followups := [
		"伴侣把提醒记在了手机上，说明早先看看社区群里的消息。",
		"你逐个确认门窗。眼下没有问题，但阳台迎风一侧明显更凉。",
		"你压低声音关掉播报。小孩子没有听清内容，只觉得今晚风很大。",
	]
	var flags := ["prepare_tomorrow", "doors_checked", "shielded_child"]
	GameState.flags[flags[safe_index]] = true
	if safe_index == 0:
		GameState.relationships["partner"] = int(GameState.relationships["partner"]) + 1
	elif safe_index == 1:
		GameState.relationships["elder"] = int(GameState.relationships["elder"]) + 1
	else:
		GameState.relationships["child"] = int(GameState.relationships["child"]) + 1
	GameState.flags["evening_forecast_heard"] = true
	GameState.phase_id = "pre_rain_day_3_evening"
	GameState.time_label = "晚上19:10"
	GameState.time_segment = "evening"
	GameState.weather_label = "阴 · 远处偶有闷雷"
	pending_action = {"type": "close"}
	hud.show_dialogue("晚上19:10", followups[safe_index], ["结束对话"])
	_update_hud()


func _open_master_bed() -> void:
	if GameState.phase_id == "pre_rain_day_3_evening" and GameState.has_flag("evening_forecast_heard"):
		pending_action = {"type": "end_day"}
		hud.show_dialogue(
			"主卧",
			"今天的重要行动都已结束。睡觉会进行晚饭、供水、供电和家庭状态结算。",
			["结束今天", "再等等"]
		)
		return
	if GameState.phase_id == "pre_rain_day_2_bedtime":
		pending_action = {"type": "end_day_two"}
		hud.show_dialogue(
			"主卧",
			"第二天的重要准备已经结束。睡觉会结算今晚的食物、饮水、供电和家庭状态。",
			["结束今天", "再等等"]
		)
		return
	pending_action = {"type": "close"}
	var text := "现在还不准备休息。白天的重要事情需要先处理完。"
	if GameState.phase_id.begins_with("pre_rain_day_2"):
		text = "床铺还留着昨夜睡过的痕迹。新的一天已经开始。"
	hud.show_dialogue("主卧床铺", text, ["离开"])


func _show_night_summary() -> void:
	pending_day_transition = "day_two"
	GameState.time_label = "晚上22:35"
	GameState.time_segment = "night"
	var summary := GameState.settle_day_three()
	_update_hud()
	var rows := [
		{"name": "晚饭", "value": str(summary.get("meal", "已完成"))},
		{"name": "饮用水", "value": str(summary.get("water", "正常"))},
		{"name": "供电", "value": str(summary.get("power", "正常"))},
		{"name": "家庭状态", "value": str(summary.get("family", "平稳"))},
		{"name": "下午安排", "value": str(summary.get("plan", "没有特别安排"))},
	]
	hud.show_day_summary(
		"暴雨前第3天 · 夜间结算",
		"只有影响家庭生活的变化在这里结算；普通查看和对话不会消耗时间。",
		rows,
		str(summary.get("note", "夜里暂时平静。"))
	)


func _on_day_summary_confirmed() -> void:
	hud.hide_day_summary()
	if pending_day_transition == "day_one":
		hud.play_day_transition("暴雨前第1天", "上午07:00", "窗外终于开始落下零星雨点。")
	else:
		pending_day_transition = "day_two"
		hud.play_day_transition("暴雨前第2天", "上午07:10", "距离预报中的强降雨，还有两天。")


func _on_day_transition_blackout() -> void:
	if pending_day_transition == "day_one":
		GameState.begin_day_one()
	else:
		GameState.begin_day_two()
	current_floor = 1
	world.build_floor(current_floor)
	player.global_position = Vector2(790.0, 735.0)
	_update_hud()


func _on_day_transition_finished() -> void:
	if pending_day_transition == "day_one":
		var scheduled_event_id := EventManager.scheduled_event_for_phase(GameState.phase_id)
		pending_day_transition = ""
		if not scheduled_event_id.is_empty():
			_open_database_event(scheduled_event_id)
		else:
			pending_action = {"type": "close"}
			hud.show_dialogue(
				"暴雨前第1天",
				"窗外开始落下零星雨点。今天的接人路线与第二次购物将在v0.7继续。",
				["结束当前版本"]
			)
		return
	pending_day_transition = ""
	pending_action = {"type": "day_two_morning"}
	hud.show_dialogue(
		"第二天清晨",
		"夜里没有下雨。清晨的窗玻璃蒙着一层水汽，街道比昨天安静。客厅方向传来手机连续震动的声音。",
		["起床查看"]
	)


func _open_day_two_weather_event() -> void:
	_open_database_event("d2_weather_warning")


func _open_database_event(event_id: String, force: bool = false) -> void:
	var data: Dictionary = EventManager.event_data(event_id)
	if data.is_empty():
		hud.show_toast("找不到事件：%s" % event_id)
		return
	if not force and not EventManager.is_available(event_id):
		hud.show_toast("这个事件现在不能触发，或已经完成。")
		return
	pending_action = {"type": "database_event", "event_id": event_id, "force": force}
	hud.show_dialogue(
		str(data.get("title", event_id)),
		EventManager.resolved_text(event_id),
		EventManager.choice_labels(event_id)
	)


func _show_day_two_summary() -> void:
	pending_day_transition = "day_one"
	GameState.time_label = "晚上22:20"
	GameState.time_segment = "night"
	var summary := GameState.settle_day_two()
	_update_hud()
	var rows := [
		{"name": "晚饭", "value": str(summary.get("meal", "已完成"))},
		{"name": "饮用水", "value": str(summary.get("water", "正常"))},
		{"name": "供电", "value": str(summary.get("power", "正常"))},
		{"name": "家庭状态", "value": str(summary.get("family", "平稳"))},
		{"name": "重点准备", "value": str(summary.get("preparation", "无"))},
		{"name": "信息", "value": str(summary.get("clues", "0条线索"))},
	]
	hud.show_day_summary(
		"暴雨前第2天 · 夜间结算",
		"今天的选择会在明天接人、通信或供水事件中继续产生影响。",
		rows,
		str(summary.get("note", "夜里暂时平静。"))
	)


func _apply_shopping_reactions() -> String:
	if GameState.has_flag("shopping_reactions_applied"):
		return "家人已经各自收好了买回来的东西。"
	var lines: Array[String] = []
	if GameState.home_storage.is_empty():
		lines.append("伴侣看着空空的后备箱，没有追问，只把原来的购物清单折了起来。")
		lines.append("两个孩子各自回了房间。老人把没电的收音机重新放回桌上。")
	else:
		if GameState.storage_has_any(["rice", "vegetables", "toilet_paper", "cleaner"]):
			GameState.relationships["partner"] = int(GameState.relationships["partner"]) + 1
			lines.append("伴侣先把家里真正缺的东西收好，神情轻松了一点。")
		else:
			lines.append("伴侣翻了翻购物袋，没有说什么，只提醒晚饭前可能还得想办法。")
		if GameState.storage_has_any(["power_bank", "batteries", "noodles"]):
			GameState.relationships["teen"] = int(GameState.relationships["teen"]) + 1
			lines.append("大孩子找到了自己提过的东西，又提醒你下午留意手机。")
		else:
			lines.append("大孩子没在袋子里找到想要的东西，仍说下午会发消息。")
		if GameState.storage_has_any(["milk", "chocolate"]):
			GameState.relationships["child"] = int(GameState.relationships["child"]) + 1
			lines.append("小孩子抱着牛奶或巧克力，高兴了一阵，但影响不会改变当天的大事。")
		else:
			lines.append("小孩子看了一眼购物袋，很快又跑回玩具柜旁。")
		if GameState.storage_has_any(["canned_fish", "batteries", "bottled_water"]):
			GameState.relationships["elder"] = int(GameState.relationships["elder"]) + 1
			lines.append("老人把罐头、电池或水放到一边，说家里有点存货就好。")
		else:
			lines.append("老人没有埋怨，只又转了转没有声音的收音机旋钮。")
	GameState.flags["shopping_reactions_applied"] = true
	return "\n".join(lines)
