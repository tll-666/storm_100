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
	"car": ["玄关外出装备", "外出所需的钥匙、随手包和搬运清单都放在这里。真正出门会进入独立事件场景，不需要走进屋外。"],
	"garage_drain": ["入户门缝", "门槛和门缝附近暂时没有明显渗水。暴雨后这里会成为一楼最先需要确认的低处。"],
	"fridge": ["冰箱", "只剩少量肉、鸡蛋、牛奶和蔬菜，大约够一家人吃两天。"],
	"pantry": ["食品柜", "米缸快见底了，旁边还有几包方便面。这里将是家庭食品储存的主要位置。"],
	"radio": ["收音机", "旋钮转动时只有沙沙声。电池已经没什么电了。"],
	"bathroom": ["厕所 / 洗衣区", "卫生用品和清洁用品都快用完了。二楼厕所与这里共用一条上下水管线。"],
	"breaker": ["配电箱", "线路看起来很旧。连续潮湿以后，这里可能出现跳闸或短路。"],
	"front_door": ["大门", "门外是黑幕。通过门槛、门缝和声音判断外面的情况。"],
	"balcony_drain": ["窗边接水区", "接水桶放在封闭窗边，排水管和窗框都能在室内检查。外部区域不可进入，只保留声音和事件反馈。"],
	"balcony_view": ["封闭窗边", "窗外不再绘制可探索区域。这里用于听取雨声、接收信号和触发相关事件。"],
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
		"name": "瓶装水",
		"text": "瓶装水摆在货架旁边，没有人抢购。",
		"items": ["bottled_water"],
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
var processing_day_one_morning: bool = false
var _last_completed_event_id: String = ""
var _auto_chain_mode: bool = false
var current_room_id: String = ""

@onready var world: HouseWorld = $World
@onready var player: StormPlayer = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var hud: StormHUD = $HUD


func _ready() -> void:
	world.build_floor(current_floor)
	player.global_position = world.spawn_position(current_floor)
	player.movement_enabled = false
	camera.zoom = Vector2(1.65, 1.65)
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
	hud.survival_manual_requested.connect(_open_survival_manual)
	hud.debug_action_selected.connect(_on_debug_action_selected)
	hud.event_browser_preview_requested.connect(_on_event_browser_preview_requested)
	hud.event_browser_reset_requested.connect(_on_event_browser_reset_requested)
	_refresh_room_focus(true)
	_update_hud()


func _process(delta: float) -> void:
	if game_started and not _should_pause_continuous_clock():
		if GameState.advance_continuous_clock(delta):
			_update_hud()
	player.movement_enabled = game_started and not hud.is_blocking()
	_refresh_room_focus()
	if not game_started or hud.is_blocking():
		current_target = null
		world.get_nearest_interactable(Vector2(-10000.0, -10000.0), 1.0)
		hud.set_prompt("")
		return
	current_target = world.get_nearest_interactable(player.global_position)
	var prompt := current_target.prompt_text if current_target != null else ""
	if current_target != null and current_target.object_id == "garage_drain" and GameState.phase_id == "rain_day_3_garage":
		prompt = "查看入户门缝渗水"
	if current_target != null and current_target.object_id == "car" and _ready_for_store():
		prompt = "从玄关出发去社区超市"
	if current_target != null and current_target.object_id == "car" and GameState.phase_id == "pre_rain_day_1_dispatch":
		prompt = "从玄关出发接人"
	if current_target != null and current_target.object_id == "car" and GameState.phase_id == "pre_rain_day_1_after_pickup":
		prompt = "从玄关再次出发"
	if current_target != null and current_target.object_id == "car" and GameState.phase_id == "rain_day_1_dispatch":
		prompt = "从玄关冒雨出发"
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
		if GameState.phase_id in ["pre_rain_day_3_evening", "pre_rain_day_2_bedtime"] or GameState.phase_id.ends_with("_settlement"):
			prompt = "结束今天"
	hud.set_prompt(prompt)


func _refresh_room_focus(force: bool = false) -> void:
	if current_floor == 3:
		var store_changed := current_room_id != "store" or world.active_room_id != "store"
		current_room_id = "store"
		world.set_active_room(current_room_id)
		GameState.mark_room_explored(current_floor, current_room_id)
		if store_changed or force:
			_set_camera_zoom(Vector2(1.15, 1.15), force)
			_update_minimap()
		return
	var room_id := world.room_at_position(player.global_position)
	if room_id.is_empty():
		return
	var changed := force or room_id != current_room_id or world.active_room_id != room_id
	if not changed:
		return
	current_room_id = room_id
	world.set_active_room(current_room_id)
	GameState.mark_room_explored(current_floor, current_room_id)
	_set_camera_zoom(Vector2(1.65, 1.65), force)
	_update_minimap()
	if not force:
		_update_hud()


func _set_camera_zoom(target: Vector2, immediate: bool = false) -> void:
	if immediate:
		camera.zoom = target
		return
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "zoom", target, 0.28)


func _update_minimap() -> void:
	if hud == null or world == null:
		return
	var room_label := world.room_name(current_room_id)
	hud.set_minimap(current_floor, current_room_id, room_label, world.minimap_rooms())


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
	if event.keycode == KEY_J and game_started and not hud.is_blocking():
		_open_survival_manual()
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
	if object_id == "kitchen_faucet":
		_inspect_kitchen_faucet()
		return
	if object_id == "radio" and GameState.phase_id == "pre_rain_day_3_afternoon":
		_open_evening_forecast()
		return
	if object_id == "radio" and GameState.phase_id == "pre_rain_day_2_morning":
		_open_day_two_weather_event()
		return
	if object_id == "car" and GameState.phase_id == "pre_rain_day_1_dispatch":
		_open_database_event("d1_dispatch")
		return
	if object_id == "garage_drain" and GameState.phase_id == "rain_day_3_garage":
		_open_database_event("r3_garage_flood")
		return
	if object_id == "car" and GameState.phase_id == "pre_rain_day_1_after_pickup":
		pending_action = {"type": "travel_to_second_store"}
		hud.show_dialogue(
			"玄关外出装备",
			"外出装备已经整理好，还能再完成一趟独立外出事件。超市还没关门，但雨天商品可能开始限购或缺货。要再去一次吗？",
			["开车去超市", "今天不再出门"]
		)
		return
	if object_id == "car" and GameState.phase_id == "rain_day_1_dispatch":
		pending_action = {"type": "travel_to_third_store"}
		hud.show_dialogue(
			"玄关外出装备",
			"雨还在下，但短暂减弱了一些。外出行动仍有风险，超市可能已经缺货大半。",
			["冒雨去超市", "还是不出门了"]
		)
		return
	if GameState.phase_id == "pre_rain_day_2_clues":
		var clue_events := {
			"radio": "d2_clue_radio",
			"balcony_view": "d2_clue_balcony",
			"front_door": "d2_clue_street",
			"garage_drain": "d2_clue_garage",
		}
		if clue_events.has(object_id) and EventManager.is_available(str(clue_events[object_id])):
			_open_database_event(str(clue_events[object_id]))
			return
	if object_id == "car" and _ready_for_store():
		pending_action = {"type": "travel_to_store"}
		hud.show_dialogue(
			"玄关外出装备",
			"需求已经记得差不多了。现在可以从玄关进入社区超市事件，回来后再处理下午的安排。",
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
		info = ["玄关外出装备", "第一次购物已经搬回家。外出装备仍然放在原处，下午是否再次出门还需要考虑。"]
	GameState.record_inspection(object_id)
	pending_action = {"type": "close"}
	hud.show_dialogue(str(info[0]), str(info[1]), ["记下了"])
	_update_hud()


func _inspect_kitchen_faucet() -> void:
	if not GameState.has_flag("inspection_prototype_active"):
		var supply_to_faucet := {
			"normal": "normal",
			"low": "low",
			"unsafe": "cloudy",
			"off": "off",
		}
		GameState.set_environment_state(
			"kitchen_faucet",
			str(supply_to_faucet.get(GameState.water_supply_state, "normal")),
			false
		)
	var state_id := GameState.environment_state("kitchen_faucet", "normal")
	var summaries := {
		"normal": "水流稳定，颜色清澈，没有明显异味。当前检查没有发现异常。",
		"low": "水流比平时细，水色仍然清澈。供水可能正在变得不稳定。",
		"cloudy": "水带着浅黄色，杯底能看到细小沉淀，并有轻微异味。不宜直接饮用。",
		"off": "打开龙头后只有管道声，没有水流出来。当前处于停水状态。",
	}
	var summary := str(summaries.get(state_id, "目前无法判断厨房供水状态。"))
	GameState.record_environment_inspection("kitchen_faucet", "厨房水龙头", summary)
	pending_action = {"type": "close"}
	hud.show_dialogue("厨房水龙头", summary, ["记录并关闭水龙头"])
	_update_hud()


func _on_choice_selected(index: int) -> void:
	var action_type := str(pending_action.get("type", "close"))
	if action_type == "close":
		hud.hide_dialogue()
		pending_action.clear()
		if processing_day_one_morning:
			_process_day_one_morning_queue()
		else:
			_check_phase_scheduled_event()
		if _auto_chain_mode:
			_auto_trigger_phase_event()
		return
	if action_type == "travel_to_store":
		hud.hide_dialogue()
		pending_action.clear()
		if index == 0:
			_enter_supermarket()
		return
	if action_type == "travel_to_second_store":
		hud.hide_dialogue()
		pending_action.clear()
		if index == 0:
			_enter_second_supermarket()
		else:
			_skip_second_shopping()
		return
	if action_type == "travel_to_third_store":
		hud.hide_dialogue()
		pending_action.clear()
		if index == 0:
			_enter_third_supermarket()
		else:
			_skip_third_shopping()
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
		_last_completed_event_id = event_id
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
	if action_type == "end_day_one":
		hud.hide_dialogue()
		pending_action.clear()
		if index == 0:
			_show_day_one_summary()
		return
	if action_type == "end_rain_day_one":
		hud.hide_dialogue()
		pending_action.clear()
		if index == 0:
			_show_rain_day_one_summary()
		return
	if action_type == "end_rain_day_two":
		hud.hide_dialogue()
		pending_action.clear()
		if index == 0:
			_show_rain_day_two_summary()
		return
	if action_type == "end_rain_day_three":
		hud.hide_dialogue()
		pending_action.clear()
		if index == 0:
			_show_rain_day_three_summary()
		return
	if action_type == "end_rain_day_four":
		hud.hide_dialogue()
		pending_action.clear()
		if index == 0:
			_show_rain_day_four_summary()
		return
	if action_type == "end_rain_day_five":
		hud.hide_dialogue()
		pending_action.clear()
		if index == 0:
			_show_rain_day_five_summary()
		return
	if action_type == "end_rain_day_six":
		hud.hide_dialogue()
		pending_action.clear()
		if index == 0:
			_show_rain_day_six_summary()
		return
	if action_type == "end_rain_day_seven":
		hud.hide_dialogue()
		pending_action.clear()
		if index == 0:
			_show_rain_day_seven_summary()
		return
	if action_type == "end_experiment_day":
		hud.hide_dialogue()
		var day := int(pending_action.get("day", 8))
		pending_action.clear()
		if index == 0:
			_show_experiment_day_summary(day)
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
	hud.show_toast("来到二楼窗边和家庭活动区。" if current_floor == 2 else "回到一楼。")
	_update_hud()


func _on_quick_travel_selected(location_id: String) -> void:
	if current_floor == 3:
		hud.show_toast("正在超市购物，先从出口或收银台回家。")
		return
	var destinations := {
		"living_room": {"floor": 1, "position": Vector2(825.0, 605.0), "name": "一楼客厅"},
		"entry": {"floor": 1, "position": Vector2(610.0, 745.0), "name": "一楼玄关"},
		"master_bedroom": {"floor": 2, "position": Vector2(650.0, 275.0), "name": "二楼主卧"},
		"balcony": {"floor": 2, "position": Vector2(610.0, 700.0), "name": "二楼窗边"},
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
	if action_id != "faucet_prototype":
		GameState.disable_continuous_clock()
		GameState.flags.erase("inspection_prototype_active")
		_auto_chain_mode = false
		_last_completed_event_id = ""
	match action_id:
		"unlock_car":
			_debug_unlock_car()
			hud.show_toast("测试：前置调查已完成，现在可以从玄关出发。", 3.2)
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
		"day_one":
			_debug_skip_to_day_one()
			hud.show_toast("测试：已跳到暴雨前第1天清晨。")
		"rain_day_one":
			_debug_skip_to_rain_day_one()
			hud.show_toast("测试：已跳到暴雨第1天。")
		"rain_day_two":
			_debug_skip_to_rain_day_two()
			hud.show_toast("测试：已跳到暴雨第2天。")
		"rain_day_three":
			_debug_skip_to_rain_day_three()
			hud.show_toast("测试：已跳到暴雨第3天。")
		"rain_day_four":
			_debug_skip_to_rain_day_four()
			hud.show_toast("测试：已跳到暴雨第4天。")
		"rain_day_five":
			_debug_skip_to_rain_day_five()
			hud.show_toast("测试：已跳到暴雨第5天。")
		"rain_day_six":
			_debug_skip_to_rain_day_six()
			hud.show_toast("测试：已跳到暴雨第6天。")
		"rain_day_seven":
			_debug_skip_to_rain_day_seven()
			hud.show_toast("测试：已跳到暴雨第7天。")
		"rain_day_eight", "rain_day_nine", "rain_day_ten", "rain_day_eleven", "rain_day_twelve", "rain_day_thirteen", "rain_day_fourteen", "rain_day_fifteen":
			var words := {"eight": 8, "nine": 9, "ten": 10, "eleven": 11, "twelve": 12, "thirteen": 13, "fourteen": 14, "fifteen": 15}
			var day := int(words.get(action_id.trim_prefix("rain_day_"), 8))
			_debug_skip_to_experiment_day(day)
			hud.show_toast("测试：已跳到暴雨第%d天。" % day)
		"faucet_prototype":
			_debug_cycle_faucet_prototype()
		"event_browser":
			hud.show_event_browser(EventManager.debug_entries(), EventManager.validation_errors)
		"reset":
			_debug_reset_run()


func _on_event_browser_preview_requested(event_id: String) -> void:
	_open_database_event(event_id, true)


func _on_event_browser_reset_requested(event_id: String) -> void:
	EventManager.debug_reset_event(event_id)
	hud.show_event_browser(EventManager.debug_entries(), EventManager.validation_errors)
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


func _debug_skip_to_day_one() -> void:
	_debug_skip_after_shop()
	GameState.flags["day_three_settled"] = true
	GameState.flags["day_two_settled"] = true
	GameState.begin_day_one()
	GameState.flags["prep_water"] = true
	GameState.schedule_event("d1_water_prepared", "pre_rain_day_1_morning")
	current_floor = 1
	world.build_floor(current_floor)
	player.global_position = Vector2(790.0, 735.0)
	pending_action.clear()
	processing_day_one_morning = true
	_update_hud()
	_process_day_one_morning_queue()


func _debug_skip_to_rain_day_one() -> void:
	_debug_skip_to_day_one()
	EventManager.apply_choice("d1_morning_start", 0, true)
	EventManager.apply_choice("d1_dispatch", 0, true)
	EventManager.apply_choice("d1_first_route", 0, true)
	EventManager.apply_choice("d1_first_arrival", 0, true)
	EventManager.apply_choice("d1_second_route", 0, true)
	EventManager.apply_choice("d1_second_arrival", 0, true)
	GameState.flags["second_shopping_complete"] = true
	GameState.settle_day_one()
	GameState.begin_rain_day_one()
	current_floor = 1
	world.build_floor(current_floor)
	player.global_position = Vector2(790.0, 735.0)
	pending_action.clear()
	_update_hud()
	_open_database_event("r1_morning_start", true)


func _debug_skip_to_rain_day_two() -> void:
	_debug_skip_to_rain_day_one()
	EventManager.apply_choice("r1_morning_start", 0, true)
	GameState.flags["third_shopping_complete"] = true
	GameState.settle_rain_day_one()
	GameState.phase_id = "rain_day_2_morning"
	GameState.day_label = "暴雨第2天"
	GameState.time_label = "上午07:00"
	GameState.time_segment = "morning"
	GameState.weather_label = "暴雨 · 水压偏低"
	GameState.flags["rain_day_two_started"] = true
	current_floor = 1
	world.build_floor(current_floor)
	player.global_position = Vector2(790.0, 735.0)
	pending_action.clear()
	_update_hud()
	_open_database_event("r2_morning_start", true)


func _debug_skip_to_rain_day_three() -> void:
	_debug_skip_to_rain_day_two()
	EventManager.apply_choice("r2_morning_start", 0, true)
	EventManager.apply_choice("r2_power_outage", 0, true)
	GameState.settle_rain_day_two()
	GameState.phase_id = "rain_day_3_morning"
	GameState.day_label = "暴雨第3天"
	GameState.time_label = "上午07:00"
	GameState.time_segment = "morning"
	GameState.weather_label = "暴雨 · 水质异常"
	GameState.flags["rain_day_three_started"] = true
	current_floor = 1
	world.build_floor(current_floor)
	player.global_position = Vector2(790.0, 735.0)
	current_target = null
	pending_action.clear()
	processing_day_one_morning = false
	_update_hud()
	_open_database_event("r3_morning_start", true)


func _debug_skip_to_rain_day_four() -> void:
	_debug_skip_to_rain_day_three()
	EventManager.apply_choice("r3_morning_start", 0, true)
	EventManager.apply_choice("r3_garage_flood", 0, true)
	GameState.settle_rain_day_three()
	GameState.phase_id = "rain_day_4_morning"
	GameState.day_label = "暴雨第4天"
	GameState.time_label = "上午07:00"
	GameState.time_segment = "morning"
	GameState.weather_label = "暴雨 · 持续中"
	GameState.flags["rain_day_four_started"] = true
	current_floor = 1
	world.build_floor(current_floor)
	player.global_position = Vector2(790.0, 735.0)
	current_target = null
	pending_action.clear()
	processing_day_one_morning = false
	_auto_chain_mode = true
	_last_completed_event_id = ""
	_update_hud()
	_open_database_event("r4_morning_start", true)


func _debug_skip_to_rain_day_five() -> void:
	_debug_skip_to_rain_day_four()
	EventManager.apply_choice("r4_morning_start", 0, true)
	EventManager.apply_choice("r4_water_sputter", 0, true)
	EventManager.apply_choice("r4_move_upstairs", 0, true)
	EventManager.apply_choice("r4_evening_dinner", 0, true)
	GameState.settle_rain_day_four()
	GameState.phase_id = "rain_day_5_morning"
	GameState.day_label = "暴雨第5天"
	GameState.time_label = "上午07:00"
	GameState.time_segment = "morning"
	GameState.weather_label = "暴雨 · 一楼已进水"
	GameState.flags["rain_day_five_started"] = true
	current_floor = 2
	world.build_floor(current_floor)
	player.global_position = Vector2(650.0, 735.0)
	current_target = null
	pending_action.clear()
	processing_day_one_morning = false
	_auto_chain_mode = true
	_last_completed_event_id = ""
	_update_hud()
	_open_database_event("r5_morning", true)


func _debug_skip_to_rain_day_six() -> void:
	_debug_skip_to_rain_day_five()
	EventManager.apply_choice("r5_morning", 0, true)
	EventManager.apply_choice("r5_child_drawing", 0, true)
	EventManager.apply_choice("r5_elder_cough", 0, true)
	EventManager.apply_choice("r5_teen_phone", 0, true)
	EventManager.apply_choice("r5_evening_hub", 0, true)
	GameState.settle_rain_day_five()
	GameState.phase_id = "rain_day_6_morning"
	GameState.day_label = "暴雨第6天"
	GameState.time_label = "上午07:00"
	GameState.time_segment = "morning"
	GameState.weather_label = "暴雨 · 全楼断电"
	GameState.flags["rain_day_six_started"] = true
	current_floor = 2
	world.build_floor(current_floor)
	player.global_position = Vector2(650.0, 735.0)
	current_target = null
	pending_action.clear()
	processing_day_one_morning = false
	_auto_chain_mode = true
	_last_completed_event_id = ""
	_update_hud()
	_open_database_event("r6_morning_dark", true)


func _debug_skip_to_rain_day_seven() -> void:
	_debug_skip_to_rain_day_six()
	EventManager.apply_choice("r6_morning_dark", 0, true)
	EventManager.apply_choice("r6_food_count", 0, true)
	EventManager.apply_choice("r6_partner_despair", 0, true)
	EventManager.apply_choice("r6_evening_close", 0, true)
	GameState.settle_rain_day_six()
	GameState.phase_id = "rain_day_7_morning"
	GameState.day_label = "暴雨第7天"
	GameState.time_label = "上午07:00"
	GameState.time_segment = "morning"
	GameState.weather_label = "暴雨 · 第一周结束"
	GameState.flags["rain_day_seven_started"] = true
	current_floor = 2
	world.build_floor(current_floor)
	player.global_position = Vector2(650.0, 735.0)
	current_target = null
	pending_action.clear()
	processing_day_one_morning = false
	_auto_chain_mode = true
	_last_completed_event_id = ""
	_update_hud()
	_open_database_event("r7_radio_surprise", true)


func _debug_skip_to_experiment_day(day: int) -> void:
	_debug_skip_to_rain_day_seven()
	EventManager.apply_choice("r7_radio_surprise", 0, true)
	EventManager.apply_choice("r7_neighbor_zhang", 0, true)
	EventManager.apply_choice("r7_evening_decision", 0, true)
	GameState.settle_rain_day_seven()
	GameState.begin_experiment_day(day)
	current_floor = 2
	world.build_floor(current_floor)
	player.global_position = Vector2(650.0, 735.0)
	current_target = null
	pending_action.clear()
	processing_day_one_morning = false
	_auto_chain_mode = true
	_last_completed_event_id = ""
	_update_hud()
	var scheduled_id := EventManager.scheduled_event_for_phase(GameState.phase_id)
	if not scheduled_id.is_empty():
		_open_database_event(scheduled_id)
	else:
		_auto_trigger_phase_event()


func _debug_cycle_faucet_prototype() -> void:
	var states := ["normal", "low", "cloudy", "off"]
	var state_names := ["正常", "低压", "浑浊", "停水"]
	var next_index := (int(GameState.flags.get("faucet_debug_index", -1)) + 1) % states.size()
	GameState.flags["faucet_debug_index"] = next_index
	GameState.flags["inspection_prototype_active"] = true
	GameState.set_environment_state("kitchen_faucet", str(states[next_index]), true)
	GameState.enable_continuous_clock(480.0)
	current_floor = 1
	world.build_floor(current_floor)
	player.global_position = Vector2(790.0, 220.0)
	current_target = null
	pending_action.clear()
	_update_hud()
	hud.show_toast("检查原型：水龙头真实状态已设为%s；请到厨房水槽检查。" % state_names[next_index], 4.0)


func _debug_reset_run() -> void:
	hud.hide_dialogue()
	hud.hide_item_grid()
	hud.hide_family_status()
	hud.hide_quick_travel()
	hud.hide_debug_menu()
	hud.hide_event_browser()
	GameState.reset_prologue()
	_auto_chain_mode = false
	_last_completed_event_id = ""
	processing_day_one_morning = false
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
	_auto_chain_mode = false
	_last_completed_event_id = ""
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
	world.reposition_npcs(GameState.phase_id)
	if world.active_room_id.is_empty():
		_refresh_room_focus(true)
	if current_floor == 3:
		var shop_objective := "在220元和10格后备箱限制下购物，最后到收银台确认。"
		if GameState.is_third_shopping():
			shop_objective = "暴雨中最后一次采购。大量商品缺货，剩余商品限购严格。到收银台确认。"
		elif GameState.is_second_shopping():
			shop_objective = "雨天部分商品限购或缺货。预算和后备箱仍有限制，到收银台确认。"
		hud.set_context(
			"%s · %s" % [GameState.day_label, GameState.time_label],
			GameState.weather_label,
			"社区超市",
			shop_objective
		)
		hud.set_progress_text(
			"预算 ¥%d · 后备箱 %d/%d格 · 购物篮 ¥%d"
			% [GameState.money, GameState.cart_slots(), GameState.trunk_capacity, GameState.cart_total()]
		)
		_update_minimap()
		return
	var room_label := world.room_name(current_room_id)
	var place := "家 · %d楼 · %s" % [current_floor, room_label]
	var talked_count := GameState.talked_to.size()
	var inspected_count := GameState.inspected.size()
	var objective := "与四位家人交谈，检查房屋关键位置。"
	if talked_count >= 4:
		objective = "家人的需求已经记下。继续检查玄关、厨房和二楼窗边。"
	if talked_count >= 4 and inspected_count >= 5:
		objective = "需求已经记下：到玄关进入社区超市外出事件。"
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
				objective = "从收音机、二楼窗边、入户门或门缝取得至少两条额外线索。"
			"pre_rain_day_2_notices":
				objective = "重点准备已完成：到客厅餐桌查看学校和社区通知。"
			"pre_rain_day_2_evening":
				objective = "通知已经确认：到客厅餐桌和家人讨论明天。"
			"pre_rain_day_2_bedtime":
				objective = "今天的准备已经结束：到二楼主卧睡觉。"
			"pre_rain_day_1_morning":
				objective = "清晨：家人分散在学校和社区，先确认昨天的准备是否到位。"
			"pre_rain_day_1_dispatch":
				objective = "到玄关准备出发接人：先接伴侣还是先接大孩子。"
			"pre_rain_day_1_first_route":
				objective = "选择外出方案：稳妥路线或低洼近路。"
			"pre_rain_day_1_en_route":
				objective = "前往第一个接人点。"
			"pre_rain_day_1_second_route":
				objective = "前往第二个接人点。"
			"pre_rain_day_1_second_arrival":
				objective = "接上第二个人，回家。"
			"pre_rain_day_1_after_pickup":
				objective = "接人完成：可以从玄关进入超市外出事件，或到主卧等待晚上。"
			"pre_rain_day_1_evening":
				objective = "今天的接人和购物已经结束：到二楼主卧睡觉。"
			"rain_day_1_morning":
				objective = "暴雨第1天：到玄关决定是否冒雨进入购物事件。"
			"rain_day_1_dispatch":
				objective = "雨有短暂减弱。到玄关进入社区超市事件。"
			"rain_day_1_home":
				objective = "有人敲门。去玄关看看。"
			"rain_day_1_noise":
				objective = "客厅天花板有滴水声。去看看。"
			"rain_day_1_family":
				objective = "小孩子情绪不好。去客厅。"
			"rain_day_1_evening":
				objective = "今天的行动已经结束：到二楼主卧睡觉，进行暴雨第1夜结算。"
			"rain_day_2_morning":
				objective = "暴雨第2天：供电不稳定，收音机需要电池。"
			"rain_day_2_ready":
				objective = "停电发生了：决定如何使用有限的备用电力。"
			"rain_day_2_evening":
				objective = "今天的行动已经结束：到二楼主卧睡觉，进行暴雨第2夜结算。"
			"rain_day_3_morning":
				objective = "暴雨第3天：一楼门缝方向传来不妙的声音。去一楼检查。"
			"rain_day_3_garage":
				objective = "入户门缝开始渗水：选择封堵、排水、转移物资或暂不处理。"
			"rain_day_3_evening":
				objective = "今天的行动已经结束：到二楼主卧睡觉，进行暴雨第3夜结算。"
			"rain_day_4_morning":
				objective = "暴雨第4天：下楼看看一楼的情况。"
			"rain_day_4_afternoon":
				objective = "厨房水管有异响。去一楼厨房检查水管。"
			"rain_day_4_moving":
				objective = "一楼地面开始渗水：决定是否搬上二楼。"
			"rain_day_4_evening":
				objective = "晚饭时间：五个人在二楼吃更少的饭。"
			"rain_day_4_settlement":
				objective = "今天的行动已经结束：到二楼主卧睡觉，进行暴雨第4夜结算。"
			"rain_day_5_morning":
				objective = "暴雨第5天：水漫过楼梯。上楼看家人。"
			"rain_day_5_midday":
				objective = "二楼每人在不同角落。和孩子、老人、大孩子谈谈。"
			"r5_family_hub":
				objective = "傍晚：结束第5天。"
			"rain_day_5_settlement":
				objective = "今天的行动已经结束：到二楼主卧睡觉，进行暴雨第5夜结算。"
			"rain_day_6_morning":
				objective = "暴雨第6天：停电第三天。开始新的一天。"
			"rain_day_6_midday":
				objective = "清点食物：五人分的东西越来越少。"
			"rain_day_6_tension":
				objective = "伴侣一个人在阳台。去看看。"
			"rain_day_6_evening":
				objective = "第六夜：结束这一天。"
			"rain_day_6_settlement":
				objective = "今天的行动已经结束：到二楼主卧睡觉，进行暴雨第6夜结算。"
			"rain_day_7_morning":
				objective = "暴雨第7天：收音机突然响了。去阳台看看。"
			"rain_day_7_midday":
				objective = "老张在隔壁屋顶。从阳台看看他要说什么。"
			"r7_family_hub":
				objective = "收音机和邻居说了不同的事。今晚做决定。"
			"rain_day_7_settlement":
				objective = "今天的行动已经结束：到二楼主卧睡觉，进行暴雨第7夜结算。"
		if GameState.phase_id.begins_with("rain_day_"):
			var experiment_day := _phase_day_number()
			if experiment_day >= 8:
				objective = _experiment_objective(experiment_day)
	if GameState.has_flag("inspection_prototype_active"):
		objective = "检查原型：到一楼厨房水槽旁，主动检查水龙头并把结果记入手册。"
	hud.set_context(
		"%s · %s" % [GameState.day_label, GameState.time_label],
		GameState.weather_label,
		place,
		objective
	)
	if GameState.has_flag("inspection_prototype_active"):
		var known_text := "尚未检查"
		if GameState.inspection_knowledge.has("kitchen_faucet"):
			known_text = "已有检查记录"
		hud.set_progress_text("厨房供水：%s · J打开生存手册" % known_text)
	elif _phase_day_number() >= 8:
		var household := GameState.household_status()
		hud.set_progress_text("食物 %s · 储备水 %s · 可用房间 %d/%d · J生存手册" % [str(household.get("food", "0份")), str(household.get("water_reserve", "0升")), GameState.usable_room_count(), GameState.ROOM_ORDER.size()])
	elif GameState.has_flag("first_shopping_complete"):
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
	_update_minimap()


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


func _enter_second_supermarket() -> void:
	current_floor = 3
	GameState.flags["second_shopping_active"] = true
	GameState.phase_id = "pre_rain_day_1_second_shop"
	GameState.time_label = "上午09:40"
	GameState.time_segment = "daytime"
	GameState.weather_label = "中雨 · 货架开始空"
	world.build_floor(current_floor)
	player.global_position = world.spawn_position(current_floor)
	hud.show_toast("社区超市：部分商品开始限购或缺货，瓶装水和电池最明显。", 3.2)
	_update_hud()


func _skip_second_shopping() -> void:
	GameState.phase_id = "pre_rain_day_1_evening"
	GameState.time_label = "下午16:30"
	GameState.time_segment = "evening"
	GameState.weather_label = "中雨 · 雨势持续"
	hud.show_toast("今天不再出门。")
	_update_hud()


func _enter_third_supermarket() -> void:
	current_floor = 3
	GameState.flags["third_shopping_active"] = true
	GameState.phase_id = "rain_day_1_third_shop"
	GameState.time_label = "上午08:00"
	GameState.time_segment = "daytime"
	GameState.weather_label = "暴雨 · 货架空了大半"
	world.build_floor(current_floor)
	player.global_position = world.spawn_position(current_floor)
	hud.show_toast("社区超市：大量商品缺货，剩余商品限购严格。这是最后一次相对安全的采购。", 3.2)
	_update_hud()


func _skip_third_shopping() -> void:
	GameState.phase_id = "rain_day_1_evening"
	GameState.time_label = "下午17:00"
	GameState.time_segment = "evening"
	GameState.weather_label = "暴雨 · 持续中"
	GameState.flags["rain_day_one_stayed_home"] = true
	hud.show_toast("今天不再出门。")
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
		if not bool(item.get("available", true)):
			continue
		var meta := "¥%d · %s" % [int(item.get("price", 0)), _survival_item_meta(item)]
		var limit := int(item.get("limit", 0))
		if limit > 0:
			meta += " · 限购%d件" % limit
		entries.append(
			{
				"id": item_id,
				"name": str(item.get("name", item_id)),
				"count": 1,
				"meta": meta,
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
	if GameState.is_third_shopping():
		_finish_third_shopping()
	elif GameState.is_second_shopping():
		_finish_second_shopping()
	else:
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


func _open_survival_manual() -> void:
	hud.show_survival_manual(hud.current_objective_text(), GameState.inspection_manual_entries())


func _should_pause_continuous_clock() -> bool:
	if not GameState.continuous_clock_enabled:
		return true
	if str(pending_action.get("type", "")) == "container_grid" and hud.is_item_grid_open():
		return false
	return hud.is_blocking()


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


func _finish_second_shopping() -> void:
	var spent := GameState.cart_total()
	if not GameState.complete_shopping():
		hud.show_toast("结账没有完成。")
		return
	current_floor = 1
	GameState.phase_id = "pre_rain_day_1_evening"
	GameState.time_label = "下午16:30"
	GameState.time_segment = "evening"
	GameState.weather_label = "中雨 · 雨势持续"
	GameState.flags["second_shopping_complete"] = true
	GameState.flags.erase("second_shopping_active")
	world.build_floor(current_floor)
	player.global_position = Vector2(340.0, 735.0)
	_update_hud()
	pending_action = {"type": "close"}
	hud.show_dialogue(
		"回到家",
		"雨比来时更大。你把东西搬进屋，这次花了¥%d，剩余¥%d。油箱基本空了，今天不适合再出门。"
		% [spent, GameState.money],
		["继续"]
	)


func _finish_third_shopping() -> void:
	var spent := GameState.cart_total()
	if not GameState.complete_shopping():
		hud.show_toast("结账没有完成。")
		return
	current_floor = 1
	GameState.phase_id = "rain_day_1_evening"
	GameState.time_label = "下午15:00"
	GameState.time_segment = "daytime"
	GameState.weather_label = "暴雨 · 雨势加剧"
	GameState.flags["third_shopping_complete"] = true
	GameState.flags.erase("third_shopping_active")
	world.build_floor(current_floor)
	player.global_position = Vector2(340.0, 735.0)
	_update_hud()
	pending_action = {"type": "close"}
	hud.show_dialogue(
		"冒雨回家",
		"回程的路已经很难走，低洼处积水漫过车轮。你把东西搬进屋，这次花了¥%d，剩余¥%d。油箱彻底空了，之后不可能再开车出门。\n\n这是最后一次外出购物。"
		% [spent, GameState.money],
		["继续"]
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
					"目前的信息还太少。再检查收音机、二楼窗边、入户门或门缝，至少获得三条线索后再决定。",
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
	var experiment_day := _phase_day_number()
	if experiment_day >= 8 and experiment_day <= 15 and GameState.phase_id.ends_with("_settlement"):
		pending_action = {"type": "end_experiment_day", "day": experiment_day}
		hud.show_dialogue(
			"主卧",
			"暴雨第%d天的室内事项已经处理完。睡觉会结算食物、饮水、身体和房间变化。" % experiment_day,
			["结束今天", "再等等"]
		)
		return
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
	if GameState.phase_id == "pre_rain_day_1_evening":
		pending_action = {"type": "end_day_one"}
		hud.show_dialogue(
			"主卧",
			"今天的接人和购物已经结束。雨还在下。睡觉会进行夜间结算，进入暴雨第1天。",
			["结束今天", "再等等"]
		)
		return
	if GameState.phase_id == "rain_day_1_evening":
		pending_action = {"type": "end_rain_day_one"}
		hud.show_dialogue(
			"主卧",
			"暴雨第1天的行动已经结束。睡觉会进行暴雨第1夜结算——供水和供电可能开始变化。",
			["结束今天", "再等等"]
		)
		return
	if GameState.phase_id == "rain_day_2_evening":
		pending_action = {"type": "end_rain_day_two"}
		hud.show_dialogue(
			"主卧",
			"暴雨第2天的行动已经结束。睡觉会进行暴雨第2夜结算——供水和供电可能继续恶化。",
			["结束今天", "再等等"]
		)
		return
	if GameState.phase_id == "rain_day_3_evening":
		pending_action = {"type": "end_rain_day_three"}
		hud.show_dialogue(
			"主卧",
			"暴雨第3天的行动已经结束。睡觉会进行暴雨第3夜结算——一楼低处的状况会在明天显现。",
			["结束今天", "再等等"]
		)
		return
	if GameState.phase_id == "rain_day_4_settlement":
		pending_action = {"type": "end_rain_day_four"}
		hud.show_dialogue(
			"主卧",
			"暴雨第4天的行动已经结束。睡觉会进行暴雨第4夜结算。",
			["结束今天", "再等等"]
		)
		return
	if GameState.phase_id == "rain_day_5_settlement":
		pending_action = {"type": "end_rain_day_five"}
		hud.show_dialogue(
			"主卧",
			"暴雨第5天的行动已经结束。睡觉会进行暴雨第5夜结算。",
			["结束今天", "再等等"]
		)
		return
	if GameState.phase_id == "rain_day_6_settlement":
		pending_action = {"type": "end_rain_day_six"}
		hud.show_dialogue(
			"主卧",
			"暴雨第6天的行动已经结束。睡觉会进行暴雨第6夜结算。",
			["结束今天", "再等等"]
		)
		return
	if GameState.phase_id == "rain_day_7_settlement":
		pending_action = {"type": "end_rain_day_seven"}
		hud.show_dialogue(
			"主卧",
			"暴雨第7天的行动已经结束。睡觉会进行暴雨第7夜结算。",
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
	elif pending_day_transition == "rain_day_one":
		hud.play_day_transition("暴雨第1天", "上午07:00", "持续的暴雨正式开始。窗外一片灰白，排水河方向传来连续的水声。")
	elif pending_day_transition == "rain_day_two":
		hud.play_day_transition("暴雨第2天", "上午07:00", "雨没有停。水压偏低，电力不稳定。")
	elif pending_day_transition == "rain_day_three":
		hud.play_day_transition("暴雨第3天", "上午07:00", "雨还在下。水质出现异常。一楼门缝方向传来不妙的声音。")
	elif pending_day_transition == "rain_day_four":
		hud.play_day_transition("暴雨第4天", "上午07:00", "雨还在下。一楼低处渗水的结果已经显现。")
	elif pending_day_transition == "rain_day_five":
		hud.play_day_transition("暴雨第5天", "上午07:00", "第五天。水漫过第一级楼梯。手机只剩一格信号。")
	elif pending_day_transition == "rain_day_six":
		hud.play_day_transition("暴雨第6天", "上午07:00", "第六天。停电第三天。屋里已经不习惯有光了。")
	elif pending_day_transition == "rain_day_seven":
		hud.play_day_transition("暴雨第7天", "上午07:00", "第七天。收音机突然响了。一周过去了，雨没有停。")
	elif pending_day_transition.begins_with("rain_day_") and pending_day_transition.trim_prefix("rain_day_").is_valid_int():
		var day := int(pending_day_transition.trim_prefix("rain_day_"))
		hud.play_day_transition("暴雨第%d天" % day, "上午07:00", GameState.experiment_change_label(day) + "。雨仍在继续。")
	elif pending_day_transition == "chapter_complete":
		hud.play_day_transition("室内生存实验结束", "暴雨第15天夜", "这一段提出的室内问题已经得到结果。")
	elif pending_day_transition == "end_of_week":
		hud.play_day_transition("第一周结束", "上午07:00", "第一周结束。救援没有来。雨还在下。五个人还在。")
	else:
		pending_day_transition = "day_two"
		hud.play_day_transition("暴雨前第2天", "上午07:10", "距离预报中的强降雨，还有两天。")


func _on_day_transition_blackout() -> void:
	if pending_day_transition == "day_one":
		GameState.begin_day_one()
	elif pending_day_transition == "rain_day_one":
		GameState.begin_rain_day_one()
	elif pending_day_transition == "rain_day_two":
		GameState.phase_id = "rain_day_2_morning"
		GameState.day_label = "暴雨第2天"
		GameState.time_label = "上午07:00"
		GameState.time_segment = "morning"
		GameState.weather_label = "暴雨 · 水压偏低"
		GameState.flags["rain_day_two_started"] = true
	elif pending_day_transition == "rain_day_three":
		GameState.phase_id = "rain_day_3_morning"
		GameState.day_label = "暴雨第3天"
		GameState.time_label = "上午07:00"
		GameState.time_segment = "morning"
		GameState.weather_label = "暴雨 · 水质异常"
		GameState.flags["rain_day_three_started"] = true
	elif pending_day_transition == "rain_day_four":
		GameState.phase_id = "rain_day_4_morning"
		GameState.day_label = "暴雨第4天"
		GameState.time_label = "上午07:00"
		GameState.time_segment = "morning"
		GameState.weather_label = "暴雨 · 持续中"
		GameState.flags["rain_day_four_started"] = true
	elif pending_day_transition == "rain_day_five":
		GameState.phase_id = "rain_day_5_morning"
		GameState.day_label = "暴雨第5天"
		GameState.time_label = "上午07:00"
		GameState.time_segment = "morning"
		GameState.weather_label = "暴雨 · 一楼已进水"
		GameState.flags["rain_day_five_started"] = true
	elif pending_day_transition == "rain_day_six":
		GameState.phase_id = "rain_day_6_morning"
		GameState.day_label = "暴雨第6天"
		GameState.time_label = "上午07:00"
		GameState.time_segment = "morning"
		GameState.weather_label = "暴雨 · 全楼断电"
		GameState.flags["rain_day_six_started"] = true
	elif pending_day_transition == "rain_day_seven":
		GameState.phase_id = "rain_day_7_morning"
		GameState.day_label = "暴雨第7天"
		GameState.time_label = "上午07:00"
		GameState.time_segment = "morning"
		GameState.weather_label = "暴雨 · 第一周结束"
		GameState.flags["rain_day_seven_started"] = true
	elif pending_day_transition.begins_with("rain_day_") and pending_day_transition.trim_prefix("rain_day_").is_valid_int():
		GameState.begin_experiment_day(int(pending_day_transition.trim_prefix("rain_day_")))
	elif pending_day_transition == "chapter_complete":
		GameState.disable_continuous_clock()
	else:
		GameState.begin_day_two()
	current_floor = 2 if pending_day_transition.begins_with("rain_day_five") or pending_day_transition.begins_with("rain_day_six") or pending_day_transition.begins_with("rain_day_seven") or (pending_day_transition.begins_with("rain_day_") and pending_day_transition.trim_prefix("rain_day_").is_valid_int()) else 1
	world.build_floor(current_floor)
	player.global_position = Vector2(650.0, 735.0) if current_floor == 2 else Vector2(790.0, 735.0)
	_update_hud()


func _on_day_transition_finished() -> void:
	if pending_day_transition == "day_one":
		pending_day_transition = ""
		processing_day_one_morning = true
		_process_day_one_morning_queue()
		return
	if pending_day_transition == "rain_day_one":
		pending_day_transition = ""
		_open_database_event("r1_morning_start", true)
		return
	if pending_day_transition == "rain_day_two":
		pending_day_transition = ""
		_open_database_event("r2_morning_start", true)
		return
	if pending_day_transition == "rain_day_three":
		pending_day_transition = ""
		_open_database_event("r3_morning_start", true)
		return
	if pending_day_transition == "rain_day_four":
		pending_day_transition = ""
		processing_day_one_morning = false
		_auto_chain_mode = true
		_last_completed_event_id = ""
		var scheduled_id := EventManager.scheduled_event_for_phase(GameState.phase_id)
		if not scheduled_id.is_empty():
			_open_database_event(scheduled_id)
		else:
			_open_database_event("r4_morning_start", true)
		return
	if pending_day_transition == "rain_day_five":
		pending_day_transition = ""
		processing_day_one_morning = false
		_auto_chain_mode = true
		_last_completed_event_id = ""
		var scheduled_id := EventManager.scheduled_event_for_phase(GameState.phase_id)
		if not scheduled_id.is_empty():
			_open_database_event(scheduled_id)
		else:
			_open_database_event("r5_morning", true)
		return
	if pending_day_transition == "rain_day_six":
		pending_day_transition = ""
		processing_day_one_morning = false
		_auto_chain_mode = true
		_last_completed_event_id = ""
		_open_database_event("r6_morning_dark", true)
		return
	if pending_day_transition == "rain_day_seven":
		pending_day_transition = ""
		processing_day_one_morning = false
		_auto_chain_mode = true
		_last_completed_event_id = ""
		_open_database_event("r7_radio_surprise", true)
		return
	if pending_day_transition.begins_with("rain_day_") and pending_day_transition.trim_prefix("rain_day_").is_valid_int():
		pending_day_transition = ""
		processing_day_one_morning = false
		_auto_chain_mode = true
		_last_completed_event_id = ""
		var scheduled_id := EventManager.scheduled_event_for_phase(GameState.phase_id)
		if not scheduled_id.is_empty():
			_open_database_event(scheduled_id)
		else:
			_auto_trigger_phase_event()
		return
	if pending_day_transition == "chapter_complete":
		pending_day_transition = ""
		_auto_chain_mode = false
		processing_day_one_morning = false
		pending_action = {"type": "close"}
		hud.show_dialogue(
			"暴雨第15天 · 实验收束",
			"你把第八天到今天的变化写在纸上。广播是否可靠、房间还能不能用、剩余水粮够不够，都已经有了眼前的答案。\n\n暴雨还会继续，但本次约15天可玩性实验到此结束。后续章节尚未制作。",
			["结束当前版本"]
		)
		return
	if pending_day_transition == "end_of_week":
		pending_day_transition = ""
		_auto_chain_mode = false
		processing_day_one_morning = false
		pending_action = {"type": "close"}
		hud.show_dialogue(
			"暴雨第7天 · 第一周结束",
			"第一周已经过去。雨还没有停。收音机说救援在来，邻居说没有看到。你把最后一点食物分了五份，每份都不够。\n\n五个人还在。这已经是第一周的胜利。\n\n当前版本到此结束，后续内容将在下个版本继续。",
			["结束当前版本"]
		)
		return
	pending_day_transition = ""
	pending_action = {"type": "day_two_morning"}
	hud.show_dialogue(
		"第二天清晨",
		"夜里没有下雨。清晨的窗玻璃蒙着一层水汽，门口比昨天安静。客厅方向传来手机连续震动的声音。",
		["起床查看"]
	)


func _process_day_one_morning_queue() -> void:
	var scheduled_event_id := EventManager.scheduled_event_for_phase(GameState.phase_id)
	if not scheduled_event_id.is_empty():
		_open_database_event(scheduled_event_id)
		return
	processing_day_one_morning = false
	_open_database_event("d1_morning_start", true)


func _auto_trigger_phase_event() -> void:
	if not _auto_chain_mode:
		return
	var scheduled_id := EventManager.scheduled_event_for_phase(GameState.phase_id)
	if not scheduled_id.is_empty():
		_open_database_event(scheduled_id)
		return
	var phase := GameState.phase_id
	var all_entries: Array = EventManager.debug_entries()
	for entry in all_entries:
		var event_id := str(entry.get("id", ""))
		if EventManager.is_available(event_id):
			_open_database_event(event_id)
			return
	if not _last_completed_event_id.is_empty():
		var data := EventManager.event_data(_last_completed_event_id)
		var merge_phase := str(data.get("merge", ""))
		if not merge_phase.is_empty() and merge_phase != phase:
			GameState.phase_id = merge_phase
			_last_completed_event_id = ""
			_update_hud()
			_auto_trigger_phase_event()


func _check_phase_scheduled_event() -> void:
	var scheduled_event_id := EventManager.scheduled_event_for_phase(GameState.phase_id)
	if not scheduled_event_id.is_empty():
		_open_database_event(scheduled_event_id)


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


func _show_day_one_summary() -> void:
	pending_day_transition = "rain_day_one"
	GameState.time_label = "晚上22:45"
	GameState.time_segment = "night"
	var summary := GameState.settle_day_one()
	_update_hud()
	var rows := [
		{"name": "晚饭", "value": str(summary.get("meal", "已完成"))},
		{"name": "饮用水", "value": str(summary.get("water", "正常"))},
		{"name": "供电", "value": str(summary.get("power", "正常"))},
		{"name": "家庭状态", "value": str(summary.get("family", "平稳"))},
		{"name": "接人", "value": str(summary.get("pickup", "未明确"))},
	]
	hud.show_day_summary(
		"暴雨前第1天 · 夜间结算",
		"今天的选择会在暴雨正式开始后继续产生影响。",
		rows,
		str(summary.get("note", "夜里雨没有停。"))
	)


func _show_rain_day_one_summary() -> void:
	pending_day_transition = "rain_day_two"
	GameState.time_label = "晚上23:10"
	GameState.time_segment = "night"
	var summary := GameState.settle_rain_day_one()
	_update_hud()
	var rows := [
		{"name": "晚饭", "value": str(summary.get("meal", "已完成"))},
		{"name": "饮用水", "value": str(summary.get("water", "未知"))},
		{"name": "供电", "value": str(summary.get("power", "未知"))},
		{"name": "家庭状态", "value": str(summary.get("family", "平稳"))},
		{"name": "设施变化", "value": str(summary.get("changes", "无"))},
	]
	hud.show_day_summary(
		"暴雨第1天 · 夜间结算",
		"供水和供电开始出现问题。后续几天情况可能继续恶化。",
		rows,
		str(summary.get("note", "夜里暴雨没有停。"))
	)


func _show_rain_day_two_summary() -> void:
	pending_day_transition = "rain_day_three"
	GameState.time_label = "晚上23:20"
	GameState.time_segment = "night"
	var summary := GameState.settle_rain_day_two()
	_update_hud()
	var rows := [
		{"name": "晚饭", "value": str(summary.get("meal", "已完成"))},
		{"name": "饮用水", "value": str(summary.get("water", "未知"))},
		{"name": "供电", "value": str(summary.get("power", "未知"))},
		{"name": "家庭状态", "value": str(summary.get("family", "平稳"))},
		{"name": "设施变化", "value": str(summary.get("changes", "无"))},
	]
	hud.show_day_summary(
		"暴雨第2天 · 夜间结算",
		"水质出现异常，停电后恢复但不稳定。一楼低处渗水可能在明天发生。",
		rows,
		str(summary.get("note", "夜里暴雨没有停。"))
	)


func _show_rain_day_three_summary() -> void:
	pending_day_transition = "rain_day_four"
	GameState.time_label = "晚上23:30"
	GameState.time_segment = "night"
	var summary := GameState.settle_rain_day_three()
	_update_hud()
	var rows := [
		{"name": "晚饭", "value": str(summary.get("meal", "已完成"))},
		{"name": "饮用水", "value": str(summary.get("water", "未知"))},
		{"name": "供电", "value": str(summary.get("power", "未知"))},
		{"name": "家庭状态", "value": str(summary.get("family", "平稳"))},
		{"name": "一楼低处", "value": str(summary.get("garage", "未知"))},
	]
	hud.show_day_summary(
		"暴雨第3天 · 夜间结算",
		"一楼低处渗水的结果将在明天显现。",
		rows,
		str(summary.get("note", "夜里暴雨没有停。")),
		{
			"rooms": str(summary.get("rooms", "")),
			"audio_hint": str(summary.get("audio_hint", "")),
		}
	)


func _show_rain_day_four_summary() -> void:
	pending_day_transition = "rain_day_five"
	GameState.time_label = "晚上23:40"
	GameState.time_segment = "night"
	var summary := GameState.settle_rain_day_four()
	_update_hud()
	var rows := [
		{"name": "晚饭", "value": str(summary.get("meal", "已完成"))},
		{"name": "饮用水", "value": str(summary.get("water", "未知"))},
		{"name": "供电", "value": str(summary.get("power", "未知"))},
		{"name": "家庭状态", "value": str(summary.get("family", "平稳"))},
		{"name": "一楼", "value": str(summary.get("onef", "未知"))},
		{"name": "食物分配", "value": str(summary.get("rationing", "自动平均分配"))},
		{"name": "设施变化", "value": str(summary.get("changes", "无"))},
	]
	hud.show_day_summary(
		"暴雨第4天 · 夜间结算",
		"正式停电，水质异常。一楼已无法正常居住。",
		rows,
		str(summary.get("note", "夜里暴雨没有停。")),
		{
			"rooms": str(summary.get("rooms", "")),
			"audio_hint": str(summary.get("audio_hint", "")),
		}
	)


func _show_rain_day_five_summary() -> void:
	pending_day_transition = "rain_day_six"
	GameState.time_label = "晚上23:50"
	GameState.time_segment = "night"
	var summary := GameState.settle_rain_day_five()
	_update_hud()
	var rows := [
		{"name": "晚饭", "value": str(summary.get("meal", "已完成"))},
		{"name": "饮用水", "value": str(summary.get("water", "未知"))},
		{"name": "供电", "value": str(summary.get("power", "未知"))},
		{"name": "家庭状态", "value": str(summary.get("family", "平稳"))},
		{"name": "食物分配", "value": str(summary.get("rationing", "自动平均分配"))},
		{"name": "设施变化", "value": str(summary.get("changes", "无"))},
	]
	hud.show_day_summary(
		"暴雨第5天 · 夜间结算",
		"停水停电持续。老人的健康开始出问题。通信彻底中断。",
		rows,
		str(summary.get("note", "夜里暴雨没有停。")),
		{
			"rooms": str(summary.get("rooms", "")),
			"audio_hint": str(summary.get("audio_hint", "")),
		}
	)


func _show_rain_day_six_summary() -> void:
	pending_day_transition = "rain_day_seven"
	GameState.time_label = "晚上23:55"
	GameState.time_segment = "night"
	var summary := GameState.settle_rain_day_six()
	_update_hud()
	var rows := [
		{"name": "晚饭", "value": str(summary.get("meal", "已完成"))},
		{"name": "饮用水", "value": str(summary.get("water", "未知"))},
		{"name": "供电", "value": str(summary.get("power", "未知"))},
		{"name": "家庭状态", "value": str(summary.get("family", "平稳"))},
		{"name": "食物分配", "value": str(summary.get("rationing", "自动平均分配"))},
		{"name": "设施变化", "value": str(summary.get("changes", "无"))},
	]
	hud.show_day_summary(
		"暴雨第6天 · 夜间结算",
		"食物即将见底。全楼彻底停电停水。伴侣的承受力接近极限。",
		rows,
		str(summary.get("note", "夜里暴雨没有停。")),
		{
			"rooms": str(summary.get("rooms", "")),
			"audio_hint": str(summary.get("audio_hint", "")),
		}
	)


func _show_rain_day_seven_summary() -> void:
	pending_day_transition = "rain_day_8"
	GameState.time_label = "晚上24:00"
	GameState.time_segment = "night"
	var summary := GameState.settle_rain_day_seven()
	_update_hud()
	var rows := [
		{"name": "晚饭", "value": str(summary.get("meal", "已完成"))},
		{"name": "饮用水", "value": str(summary.get("water", "未知"))},
		{"name": "供电", "value": str(summary.get("power", "未知"))},
		{"name": "家庭状态", "value": str(summary.get("family", "平稳"))},
		{"name": "食物分配", "value": str(summary.get("rationing", "自动平均分配"))},
		{"name": "设施变化", "value": str(summary.get("changes", "无"))},
	]
	hud.show_day_summary(
		"暴雨第7天 · 夜间结算",
		"第一周结束。救援没有来。收音机和邻居说了相反的话。食物几乎耗尽。",
		rows,
		str(summary.get("note", "夜里暴雨没有停。")),
		{
			"rooms": str(summary.get("rooms", "")),
			"audio_hint": str(summary.get("audio_hint", "")),
		}
	)


func _show_experiment_day_summary(day: int) -> void:
	pending_day_transition = "chapter_complete" if day >= 15 else "rain_day_%d" % (day + 1)
	GameState.disable_continuous_clock()
	GameState.time_label = "晚上22:30"
	GameState.time_segment = "night"
	var summary := GameState.settle_experiment_day(day)
	_update_hud()
	var rows := [
		{"name": "晚饭", "value": str(summary.get("meal", "没有完整的一顿饭"))},
		{"name": "饮用水", "value": str(summary.get("water", "未知"))},
		{"name": "家庭身体", "value": str(summary.get("family", "未知"))},
		{"name": "今日变化", "value": str(summary.get("changes", "环境继续变化"))},
	]
	if day == 15:
		rows.append({"name": "阶段对比", "value": GameState.experiment_delta_summary()})
	hud.show_day_summary(
		"暴雨第%d天 · 夜间结算" % day,
		"第二周室内生存实验：选择改变资源、身体与可用空间。",
		rows,
		str(summary.get("note", "夜里雨没有停。")),
		{"rooms": str(summary.get("rooms", "")), "audio_hint": str(summary.get("audio_hint", ""))}
	)


func _phase_day_number() -> int:
	var parts := GameState.phase_id.split("_")
	if parts.size() >= 3 and str(parts[2]).is_valid_int():
		return int(parts[2])
	return 0


func _experiment_objective(day: int) -> String:
	if GameState.phase_id.ends_with("_settlement"):
		return "前往二楼主卧，结束暴雨第%d天并查看结算。" % day
	var objectives := {
		8: "去一楼冰箱确认停电后的食物；决定抢救还是丢弃。",
		9: "检查厕所与管道异响；决定是否提前封堵。",
		10: "检查二楼卧室的漏水点；保护最后的干燥床铺。",
		11: "整理阳台接到的雨水；在储量和卫生风险间取舍。",
		12: "趁雨势较弱重新划分二楼生活区。",
		13: "处理污水反灌；避免污染继续进入二楼。",
		14: "去阳台确认广播与邻居消息的结果。",
		15: "完成最终盘点，确认这段实验留下了什么。",
	}
	return str(objectives.get(day, "处理今天最紧急的室内问题。"))


func _apply_shopping_reactions() -> String:
	if GameState.has_flag("shopping_reactions_applied"):
		return "家人已经各自收好了买回来的东西。"
	var lines: Array[String] = []
	if GameState.home_storage.is_empty():
		lines.append("伴侣看着空空的后备箱，没有追问，只把原来的购物清单折了起来。")
		lines.append("两个孩子各自回了房间。老人把没电的收音机重新放回桌上。")
	else:
		if GameState.storage_has_any(["rice", "vegetables"]):
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
