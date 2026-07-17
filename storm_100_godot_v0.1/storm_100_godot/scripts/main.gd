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

var current_floor: int = 1
var current_target: InteractionObject
var pending_action: Dictionary = {}
var game_started: bool = false

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
	_update_hud()


func _process(_delta: float) -> void:
	player.movement_enabled = game_started and not hud.is_blocking()
	if not game_started or hud.is_blocking():
		current_target = null
		world.get_nearest_interactable(Vector2(-10000.0, -10000.0), 1.0)
		hud.set_prompt("")
		return
	current_target = world.get_nearest_interactable(player.global_position)
	hud.set_prompt(current_target.prompt_text if current_target != null else "")


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		hud.close_top_overlay()
		pending_action.clear()
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
	if not INSPECTIONS.has(object_id):
		return
	var info: Array = INSPECTIONS[object_id]
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


func _on_intro_started() -> void:
	game_started = true
	hud.show_toast("先确认房屋比例与动线。靠近人物或家具后按E互动。", 3.2)


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
	var place := "家 · 一楼 / 前院" if current_floor == 1 else "家 · 二楼 / 公共阳台"
	var talked_count := GameState.talked_to.size()
	var inspected_count := GameState.inspected.size()
	var objective := "与四位家人交谈，检查房屋关键位置。"
	if talked_count >= 4:
		objective = "家人的需求已经记下。继续检查车库、厨房和阳台。"
	if talked_count >= 4 and inspected_count >= 5:
		objective = "灰盒自由探索完成：下一阶段将接入普通购物。"
	hud.set_context(
		"%s · %s" % [GameState.day_label, GameState.time_label],
		GameState.weather_label,
		place,
		objective
	)
	hud.set_progress(talked_count, inspected_count)
