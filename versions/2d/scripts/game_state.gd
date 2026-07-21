extends Node

const SAVE_PATH := "user://storm_100_checkpoint.json"

const SHOP_ITEMS := {
	"rice": {"name": "大米", "price": 42, "slots": 2, "food": 12},
	"noodles": {"name": "方便面", "price": 10, "slots": 1, "food": 2},
	"canned_fish": {"name": "鱼罐头", "price": 18, "slots": 1, "food": 2},
	"vegetables": {"name": "蔬菜", "price": 20, "slots": 1, "food": 3},
	"milk": {"name": "牛奶", "price": 16, "slots": 1, "food": 2},
	"chocolate": {"name": "巧克力", "price": 15, "slots": 1, "food": 1},
	"bottled_water": {"name": "瓶装水", "price": 14, "slots": 2, "water_liters": 6.0},
	"batteries": {"name": "电池", "price": 24, "slots": 1},
	"power_bank": {"name": "充电宝", "price": 65, "slots": 1},
	"basic_medicine": {"name": "常用药", "price": 32, "slots": 1},
	"alcohol": {"name": "白酒", "price": 35, "slots": 1, "morale": 1},
	"cigarettes": {"name": "香烟", "price": 30, "slots": 1},
	"meat": {"name": "少量肉", "price": 0, "slots": 1, "food": 3},
	"eggs": {"name": "鸡蛋", "price": 0, "slots": 1, "food": 1},
	"dry_biscuits": {"name": "干饼干", "price": 0, "slots": 1, "food": 2},
	"seeds": {"name": "蔬菜种子", "price": 20, "slots": 1},
	"shotgun": {"name": "老式猎枪", "price": 0, "slots": 2},
	"ammo": {"name": "猎枪子弹", "price": 0, "slots": 1},
}

const SECOND_SHOP_OVERRIDES := {
	"rice": {"price": 52},
	"vegetables": {"price": 28, "limit": 2},
	"milk": {"price": 22, "limit": 2},
	"bottled_water": {"price": 20, "limit": 2},
	"batteries": {"price": 32, "limit": 2},
	"power_bank": {"price": 85, "limit": 1},
	"chocolate": {"available": false},
	"canned_fish": {"price": 24, "limit": 3},
}

const THIRD_SHOP_OVERRIDES := {
	"rice": {"price": 68, "limit": 1},
	"vegetables": {"available": false},
	"milk": {"available": false},
	"chocolate": {"available": false},
	"bottled_water": {"price": 30, "limit": 1},
	"batteries": {"price": 42, "limit": 1},
	"power_bank": {"available": false},
	"canned_fish": {"price": 32, "limit": 2},
	"noodles": {"price": 16, "limit": 3},
	"basic_medicine": {"price": 45, "limit": 1},
}

const FAMILY_ORDER := ["player", "partner", "teen", "child", "elder"]
const FAMILY_NAMES := {
	"player": "玩家",
	"partner": "伴侣",
	"teen": "大孩子",
	"child": "小孩子",
	"elder": "老人",
}

var phase_id: String = "pre_rain_day_3"
var day_label: String = "暴雨前第3天"
var time_label: String = "上午8:05"
var weather_label: String = "阴 · 尚未下雨"
var time_segment: String = "morning"
var continuous_clock_enabled: bool = false
var clock_minutes: float = 485.0
var clock_rate: float = 0.8
var clock_end_minutes: float = 1200.0
var money: int = 220
var personal_capacity: int = 6
var trunk_capacity: int = 10

var dialogue_choices: Dictionary = {}
var flags: Dictionary = {}
var talked_to: Dictionary = {}
var inspected: Dictionary = {}
var environment_states: Dictionary = {"kitchen_faucet": "normal"}
var inspection_knowledge: Dictionary = {}
var inventory: Array[String] = []
var home_storage: Dictionary = {}
var shopping_cart: Array[String] = []
var fridge_storage: Dictionary = {"meat": 1, "eggs": 4, "milk": 1, "vegetables": 1}
var pantry_storage: Dictionary = {"rice": 1, "noodles": 2}
var utility_storage: Dictionary = {}
var afternoon_plan: String = ""
var last_night_summary: Dictionary = {}
var water_supply_state: String = "normal"
var power_supply_state: String = "normal"
var loose_water_liters: float = 0.0
var family_states: Dictionary = {}
var prepared_power_units: int = 0
var completed_events: Dictionary = {}
var event_choices: Dictionary = {}
var clues: Dictionary = {}
var scheduled_events: Array = []
var event_log: Array = []
var day_two_preparation: String = ""
var last_day_two_summary: Dictionary = {}
var last_day_one_summary: Dictionary = {}
var last_rain_day_one_summary: Dictionary = {}
var last_rain_day_two_summary: Dictionary = {}
var last_rain_day_three_summary: Dictionary = {}
var last_rain_day_four_summary: Dictionary = {}
var last_rain_day_five_summary: Dictionary = {}
var last_rain_day_six_summary: Dictionary = {}
var last_rain_day_seven_summary: Dictionary = {}
var last_experiment_summary: Dictionary = {}
var experiment_start_snapshot: Dictionary = {}


func reset_prologue() -> void:
	phase_id = "pre_rain_day_3"
	day_label = "暴雨前第3天"
	time_label = "上午8:05"
	weather_label = "阴 · 尚未下雨"
	time_segment = "morning"
	continuous_clock_enabled = false
	clock_minutes = 485.0
	clock_rate = 0.8
	clock_end_minutes = 1200.0
	money = 220
	dialogue_choices.clear()
	flags.clear()
	talked_to.clear()
	inspected.clear()
	environment_states = {"kitchen_faucet": "normal"}
	inspection_knowledge.clear()
	inventory.clear()
	home_storage.clear()
	shopping_cart.clear()
	fridge_storage = {"meat": 1, "eggs": 4, "milk": 1, "vegetables": 1}
	pantry_storage = {"rice": 1, "noodles": 2}
	utility_storage = {}
	afternoon_plan = ""
	last_night_summary.clear()
	water_supply_state = "normal"
	power_supply_state = "normal"
	loose_water_liters = 0.0
	family_states = _default_family_states()
	prepared_power_units = 0
	completed_events.clear()
	event_choices.clear()
	clues.clear()
	scheduled_events.clear()
	event_log.clear()
	day_two_preparation = ""
	last_day_two_summary.clear()
	last_day_one_summary.clear()
	last_rain_day_one_summary.clear()
	last_rain_day_two_summary.clear()
	last_rain_day_three_summary.clear()
	last_rain_day_four_summary.clear()
	last_rain_day_five_summary.clear()
	last_rain_day_six_summary.clear()
	last_rain_day_seven_summary.clear()
	last_experiment_summary.clear()
	experiment_start_snapshot.clear()


func enable_continuous_clock(start_minutes: float = 480.0) -> void:
	continuous_clock_enabled = true
	clock_minutes = clampf(start_minutes, 0.0, clock_end_minutes)
	_update_clock_label()


func disable_continuous_clock() -> void:
	continuous_clock_enabled = false


func advance_continuous_clock(delta: float) -> bool:
	if not continuous_clock_enabled or delta <= 0.0 or clock_minutes >= clock_end_minutes:
		return false
	var previous_minute := int(clock_minutes)
	clock_minutes = minf(clock_end_minutes, clock_minutes + delta * clock_rate)
	if int(clock_minutes) == previous_minute:
		return false
	_update_clock_label()
	return true


func set_environment_state(object_id: String, state_id: String, forget_previous: bool = true) -> void:
	environment_states[object_id] = state_id
	if forget_previous:
		inspection_knowledge.erase(object_id)


func environment_state(object_id: String, fallback: String = "unknown") -> String:
	return str(environment_states.get(object_id, fallback))


func record_environment_inspection(object_id: String, display_name: String, summary: String) -> void:
	inspected[object_id] = true
	inspection_knowledge[object_id] = {
		"name": display_name,
		"state": environment_state(object_id),
		"summary": summary,
		"checked_at": "%s · %s" % [day_label, time_label],
	}


func inspection_manual_entries() -> Array:
	var entries: Array = []
	for object_id in inspection_knowledge:
		var knowledge: Dictionary = inspection_knowledge[object_id]
		entries.append(
			{
				"id": str(object_id),
				"name": str(knowledge.get("name", object_id)),
				"summary": str(knowledge.get("summary", "状态未知")),
				"checked_at": str(knowledge.get("checked_at", "尚未检查")),
			}
		)
	entries.sort_custom(
		func(left: Dictionary, right: Dictionary) -> bool:
			return str(left.get("name", "")) < str(right.get("name", ""))
	)
	return entries


func _update_clock_label() -> void:
	var total_minutes := clampi(int(clock_minutes), 0, 1439)
	var hour := int(total_minutes / 60)
	var minute := total_minutes % 60
	if total_minutes < 720:
		time_segment = "morning"
		time_label = "上午%02d:%02d" % [hour, minute]
	elif total_minutes < 1080:
		time_segment = "daytime"
		time_label = "下午%02d:%02d" % [hour, minute]
	elif total_minutes < 1200:
		time_segment = "evening"
		time_label = "傍晚%02d:%02d" % [hour, minute]
	else:
		time_segment = "night"
		time_label = "晚上%02d:%02d" % [hour, minute]


func apply_afternoon_plan(plan_id: String) -> String:
	if not afternoon_plan.is_empty():
		return "下午的安排已经完成。"
	afternoon_plan = plan_id
	phase_id = "pre_rain_day_3_afternoon"
	time_label = "下午15:30"
	time_segment = "daytime"
	weather_label = "阴 · 阵风增多"
	match plan_id:
		"organize_supplies":
			flags["supplies_organized"] = true
			_adjust_member_stat("partner", "morale", 4)
			return "你和伴侣把冷藏、常温和日用品分别归位，又在柜门内侧贴了简短清单。"
		"inspect_house":
			flags["house_rechecked"] = true
			_adjust_member_stat("elder", "morale", 4)
			return "你重新清理了车库和阳台排水口，也确认配电箱附近没有渗水痕迹。"
		"family_time":
			flags["family_afternoon"] = true
			for member_id in FAMILY_ORDER:
				_adjust_member_stat(member_id, "morale", 5)
			return "你没有继续忙碌，而是陪家人吃了顿迟来的午饭。两个孩子都放松了一些。"
		_:
			return "下午在整理和交谈中慢慢过去。"


func afternoon_plan_label() -> String:
	match afternoon_plan:
		"organize_supplies":
			return "物资已经分类归位"
		"inspect_house":
			return "排水与电路已经复查"
		"family_time":
			return "家人得到陪伴"
	return "没有特别安排"


func settle_day_three() -> Dictionary:
	if has_flag("day_three_settled"):
		return last_night_summary
	var meal_parts: Array[String] = []
	var nutrition_gain := 12
	if _consume_item_anywhere("vegetables", 1) > 0:
		meal_parts.append("蔬菜")
		nutrition_gain += 8
	if _consume_item_anywhere("eggs", 2) > 0:
		meal_parts.append("鸡蛋")
		nutrition_gain += 7
	elif _consume_item_anywhere("meat", 1) > 0:
		meal_parts.append("少量肉")
		nutrition_gain += 10
	if meal_parts.is_empty() and _consume_item_anywhere("noodles", 1) > 0:
		meal_parts.append("方便面")
		nutrition_gain = 18
	var meal_text := "、".join(meal_parts) if not meal_parts.is_empty() else "简单处理了家中剩余食物"
	var water_result := _settle_family_needs(nutrition_gain)
	last_night_summary = {
		"meal": "晚饭使用：%s" % meal_text,
		"water": str(water_result.get("water_text", "供水状态未知")),
		"power": power_state_label(),
		"family": "五人平均：饱腹%d · 水分%d · 精神%d" % [
			average_member_stat("hunger"), average_member_stat("thirst"), average_member_stat("morale")
		],
		"plan": afternoon_plan_label(),
		"note": "风比早晨更大。气象台把未来两天的强降雨概率再次调高。",
	}
	flags["day_three_settled"] = true
	return last_night_summary


func begin_day_two() -> void:
	phase_id = "pre_rain_day_2_morning"
	day_label = "暴雨前第2天"
	time_label = "上午07:10"
	time_segment = "morning"
	weather_label = "阴 · 空气潮湿"
	flags["day_two_started"] = true


func day_two_preparation_label() -> String:
	match day_two_preparation:
		"water":
			return "提前储水"
		"power":
			return "设备充电"
		"route":
			return "车辆与路线检查"
	return "没有完成重点准备"


func settle_day_two() -> Dictionary:
	if has_flag("day_two_settled"):
		return last_day_two_summary
	var meal_parts: Array[String] = []
	var nutrition_gain := 16
	if _consume_item_anywhere("vegetables", 1) > 0:
		meal_parts.append("蔬菜")
		nutrition_gain += 6
	if _consume_item_anywhere("eggs", 2) > 0:
		meal_parts.append("鸡蛋")
		nutrition_gain += 7
	elif _consume_item_anywhere("noodles", 1) > 0:
		meal_parts.append("方便面")
		nutrition_gain += 4
	var meal_text := "、".join(meal_parts) if not meal_parts.is_empty() else "家中剩余的简单食物"
	var water_result := _settle_family_needs(nutrition_gain)
	var note := "夜里仍没有正式下雨，但远处的雷声比昨天更密。"
	match day_two_preparation:
		"water":
			note = "储水容器沿墙摆好。夜里水压正常，但这份准备会留到真正需要的时候。"
		"power":
			note = "备用设备保持满电。天气提醒整夜都在更新，通信暂时没有中断。"
		"route":
			note = "汽车和路线已经检查过。真正的路况仍要等明天出发时判断。"
	last_day_two_summary = {
		"meal": "晚饭使用：%s" % meal_text,
		"water": str(water_result.get("water_text", "供水状态未知")),
		"power": power_state_label(),
		"family": "五人平均：饱腹%d · 水分%d · 精神%d" % [
			average_member_stat("hunger"), average_member_stat("thirst"), average_member_stat("morale")
		],
		"preparation": day_two_preparation_label(),
		"clues": "今日获得%d条线索" % clues.size(),
		"note": note,
	}
	flags["day_two_settled"] = true
	return last_day_two_summary


func settle_day_one() -> Dictionary:
	if has_flag("day_one_settled"):
		return last_day_one_summary
	var meal_parts: Array[String] = []
	var nutrition_gain := 18
	if _consume_item_anywhere("vegetables", 1) > 0:
		meal_parts.append("蔬菜")
		nutrition_gain += 6
	if _consume_item_anywhere("eggs", 2) > 0:
		meal_parts.append("鸡蛋")
		nutrition_gain += 7
	elif _consume_item_anywhere("noodles", 1) > 0:
		meal_parts.append("方便面")
		nutrition_gain += 4
	if meal_parts.is_empty() and _consume_item_anywhere("canned_fish", 1) > 0:
		meal_parts.append("鱼罐头")
		nutrition_gain += 8
	var meal_text := "、".join(meal_parts) if not meal_parts.is_empty() else "家中剩余的简单食物"
	var water_result := _settle_family_needs(nutrition_gain)
	var note := "雨整夜没停。凌晨时雨声变得更密，远处能听见排水河方向的水声。"
	if has_flag("second_shopping_complete"):
		note += "买回来的东西已经归位，但雨势让窗外的能见度越来越差。"
	last_day_one_summary = {
		"meal": "晚饭使用：%s" % meal_text,
		"water": str(water_result.get("water_text", "供水状态未知")),
		"power": power_state_label(),
		"family": "五人平均：饱腹%d · 水分%d · 精神%d" % [
			average_member_stat("hunger"), average_member_stat("thirst"), average_member_stat("morale")
		],
		"note": note,
	}
	flags["day_one_settled"] = true
	return last_day_one_summary


func begin_day_one() -> void:
	phase_id = "pre_rain_day_1_morning"
	day_label = "暴雨前第1天"
	time_label = "上午07:00"
	time_segment = "morning"
	weather_label = "零星小雨 · 风势增强"
	flags["day_one_started"] = true


func begin_rain_day_one() -> void:
	phase_id = "rain_day_1_morning"
	day_label = "暴雨第1天"
	time_label = "上午07:00"
	time_segment = "morning"
	weather_label = "暴雨 · 红色预警"
	flags["rain_day_one_started"] = true


func settle_rain_day_one() -> Dictionary:
	if has_flag("rain_day_one_settled"):
		return last_rain_day_one_summary
	var meal_parts: Array[String] = []
	var nutrition_gain := 16
	if _consume_item_anywhere("rice", 1) > 0:
		meal_parts.append("大米")
		nutrition_gain += 10
	if _consume_item_anywhere("canned_fish", 1) > 0:
		meal_parts.append("鱼罐头")
		nutrition_gain += 6
	elif _consume_item_anywhere("noodles", 1) > 0:
		meal_parts.append("方便面")
		nutrition_gain += 4
	if meal_parts.is_empty() and _consume_item_anywhere("vegetables", 1) > 0:
		meal_parts.append("蔬菜")
		nutrition_gain += 6
	var meal_text := "、".join(meal_parts) if not meal_parts.is_empty() else "家中剩余的简单食物"
	water_supply_state = "low"
	var water_result := _settle_family_needs(nutrition_gain)
	power_supply_state = "unstable"
	for member_id in FAMILY_ORDER:
		_adjust_member_stat(member_id, "morale", -2)
	var note := "暴雨整夜没停。凌晨时分水压开始下降，电力也出现短暂闪烁。这只是开始。"
	if has_flag("rain_day_one_stayed_home"):
		note = "暴雨整夜没停。你庆幸今天没有出门，但物资消耗比预期更快。水压开始下降，电力出现闪烁。"
	last_rain_day_one_summary = {
		"meal": "晚饭使用：%s" % meal_text,
		"water": str(water_result.get("water_text", "供水状态未知")),
		"power": power_state_label(),
		"family": "五人平均：饱腹%d · 水分%d · 精神%d" % [
			average_member_stat("hunger"), average_member_stat("thirst"), average_member_stat("morale")
		],
		"changes": "供水降至水压偏低 · 供电出现不稳定",
		"note": note,
	}
	flags["rain_day_one_settled"] = true
	return last_rain_day_one_summary


func settle_rain_day_two() -> Dictionary:
	if has_flag("rain_day_two_settled"):
		return last_rain_day_two_summary
	var meal_parts: Array[String] = []
	var nutrition_gain := 14
	if _consume_item_anywhere("rice", 1) > 0:
		meal_parts.append("大米")
		nutrition_gain += 8
	if _consume_item_anywhere("canned_fish", 1) > 0:
		meal_parts.append("鱼罐头")
		nutrition_gain += 5
	elif _consume_item_anywhere("noodles", 1) > 0:
		meal_parts.append("方便面")
		nutrition_gain += 4
	var meal_text := "、".join(meal_parts) if not meal_parts.is_empty() else "家中剩余的简单食物"
	water_supply_state = "unsafe"
	var water_result := _settle_family_needs(nutrition_gain)
	if has_flag("used_radio_during_outage"):
		_adjust_member_stat("elder", "morale", 2)
	if has_flag("used_phone_during_outage"):
		_adjust_member_stat("teen", "morale", 1)
	var note := "雨整夜没停。停电持续了大约四小时后恢复，但电压明显不稳。水质开始出现问题，龙头放出来的水带着异味。"
	if has_flag("saved_power_during_outage"):
		note = "雨整夜没停。停电持续了大约四小时。因为白天没有开收音机或手机，家里在黑暗和沉默中度过了最长的几个小时。水质也开始出现问题。"
	last_rain_day_two_summary = {
		"meal": "晚饭使用：%s" % meal_text,
		"water": str(water_result.get("water_text", "供水状态未知")),
		"power": power_state_label(),
		"family": "五人平均：饱腹%d · 水分%d · 精神%d" % [
			average_member_stat("hunger"), average_member_stat("thirst"), average_member_stat("morale")
		],
		"changes": "供水降至水质异常 · 停电后恢复但仍不稳定",
		"note": note,
	}
	flags["rain_day_two_settled"] = true
	return last_rain_day_two_summary


func settle_rain_day_three() -> Dictionary:
	if has_flag("rain_day_three_settled"):
		return last_rain_day_three_summary
	var meal_parts: Array[String] = []
	var nutrition_gain := 12
	if _consume_item_anywhere("rice", 1) > 0:
		meal_parts.append("大米")
		nutrition_gain += 6
	if _consume_item_anywhere("noodles", 1) > 0:
		meal_parts.append("方便面")
		nutrition_gain += 4
	elif _consume_item_anywhere("canned_fish", 1) > 0:
		meal_parts.append("鱼罐头")
		nutrition_gain += 5
	var meal_text := "、".join(meal_parts) if not meal_parts.is_empty() else "家中剩余的简单食物"
	var water_result := _settle_family_needs(nutrition_gain)
	var garage_status := "车库有少量积水"
	if has_flag("garage_ignored"):
		garage_status = "车库积水严重，部分物资受损"
	elif has_flag("garage_moved_supplies"):
		garage_status = "车库积水但物资已转移"
	elif has_flag("garage_sealed_door"):
		garage_status = "车库进水被延缓但仍在上涨"
	elif has_flag("garage_bailed_water"):
		garage_status = "车库水位暂时控制"
	var note := "雨整夜没停。车库的水又涨了一些。一楼的味道开始变得潮湿。"
	if has_flag("garage_ignored"):
		note = "雨整夜没停。今早车库的水已经没过脚踝，受潮的工具和物资散发出霉味。"
	last_rain_day_three_summary = {
		"meal": "晚饭使用：%s" % meal_text,
		"water": str(water_result.get("water_text", "供水状态未知")),
		"power": power_state_label(),
		"family": "五人平均：饱腹%d · 水分%d · 精神%d" % [
			average_member_stat("hunger"), average_member_stat("thirst"), average_member_stat("morale")
		],
		"garage": garage_status,
		"note": note,
	}
	flags["rain_day_three_settled"] = true
	last_rain_day_three_summary["audio_hint"] = "雨声持续 · 车库方向微弱流水声"
	return last_rain_day_three_summary


func settle_rain_day_four() -> Dictionary:
	if has_flag("rain_day_four_settled"):
		return last_rain_day_four_summary
	var meal_parts: Array[String] = []
	var nutrition_gain := 10
	if _consume_item_anywhere("rice", 1) > 0:
		meal_parts.append("大米")
		nutrition_gain += 5
	if _consume_item_anywhere("noodles", 1) > 0:
		meal_parts.append("方便面")
		nutrition_gain += 3
	elif _consume_item_anywhere("canned_fish", 1) > 0:
		meal_parts.append("鱼罐头")
		nutrition_gain += 4
	var meal_text := "、".join(meal_parts) if not meal_parts.is_empty() else "越来越少的存粮"
	water_supply_state = "unsafe"
	power_supply_state = "off"
	var water_result := _settle_family_needs(nutrition_gain)
	for member_id in FAMILY_ORDER:
		_adjust_member_stat(member_id, "morale", -2)
	if has_flag("moved_to_second_floor"):
		_adjust_member_stat("partner", "morale", 1)
	var move_status := "一楼已无法正常生活"
	if has_flag("moved_to_second_floor"):
		move_status = "全家搬到二楼，物资安全"
	elif has_flag("partial_move_upstairs"):
		move_status = "只搬了电器和药物，被褥仍湿了一楼"
	elif has_flag("shelved_move_decision"):
		move_status = "没有搬家，一楼被褥和电器受损"
	var note := "雨整夜没停。一楼地面的水又深了一层，已经是名副其实的内涝。全家挤在二楼度过了一夜。"
	if has_flag("rationing_started"):
		note += " 今晚第一次正式定量分配食物。"
	elif has_flag("rationing_delayed"):
		note += " 还没有开始定量——但你知道这只是时间问题。"
	last_rain_day_four_summary = {
		"meal": "晚饭使用：%s" % meal_text,
		"water": str(water_result.get("water_text", "供水状态未知")),
		"power": power_state_label(),
		"family": "五人平均：饱腹%d · 水分%d · 精神%d" % [
			average_member_stat("hunger"), average_member_stat("thirst"), average_member_stat("morale")
		],
		"onef": move_status,
		"changes": "正式停电 · 水质异常",
		"note": note,
	}
	flags["rain_day_four_settled"] = true
	last_rain_day_four_summary["audio_hint"] = "持续暴雨 · 管道闷响 · 间歇滴水声"
	return last_rain_day_four_summary


func settle_rain_day_five() -> Dictionary:
	if has_flag("rain_day_five_settled"):
		return last_rain_day_five_summary
	var meal_parts: Array[String] = []
	var nutrition_gain := 8
	if _consume_item_anywhere("rice", 1) > 0:
		meal_parts.append("大米")
		nutrition_gain += 4
	if _consume_item_anywhere("noodles", 1) > 0:
		meal_parts.append("方便面")
		nutrition_gain += 3
	elif _consume_item_anywhere("canned_fish", 1) > 0:
		meal_parts.append("鱼罐头")
		nutrition_gain += 3
	var meal_text := "、".join(meal_parts) if not meal_parts.is_empty() else "越来越少的存粮"
	water_supply_state = "off"
	power_supply_state = "off"
	var water_result := _settle_family_needs(nutrition_gain)
	for member_id in FAMILY_ORDER:
		_adjust_member_stat(member_id, "morale", -1)
	if has_flag("elder_got_medicine_day5"):
		_adjust_member_stat("elder", "health", 3)
	var note := "第五夜。一楼的水又涨了。老人咳了一晚上。大孩子的手机彻底没电了。小孩子把蜡笔收进盒子的时候，把盒子放在了离枕头最近的地方。"
	if has_flag("rationing_started"):
		note += " 定量分配已经变成习惯——每个人知道自己的份在哪里，在哪里结束。"
	last_rain_day_five_summary = {
		"meal": "晚饭使用：%s" % meal_text,
		"water": str(water_result.get("water_text", "供水状态未知")),
		"power": power_state_label(),
		"family": "五人平均：饱腹%d · 水分%d · 精神%d" % [
			average_member_stat("hunger"), average_member_stat("thirst"), average_member_stat("morale")
		],
		"changes": "正式停水 · 持续停电",
		"note": note,
	}
	flags["rain_day_five_settled"] = true
	last_rain_day_five_summary["audio_hint"] = "持续暴雨 · 老人咳嗽声 · 雨打屋顶"
	return last_rain_day_five_summary


func settle_rain_day_six() -> Dictionary:
	if has_flag("rain_day_six_settled"):
		return last_rain_day_six_summary
	var meal_parts: Array[String] = []
	var nutrition_gain := 6
	if _consume_item_anywhere("rice", 1) > 0:
		meal_parts.append("大米")
		nutrition_gain += 3
	if _consume_item_anywhere("noodles", 1) > 0:
		meal_parts.append("方便面")
		nutrition_gain += 2
	elif _consume_item_anywhere("canned_fish", 1) > 0:
		meal_parts.append("鱼罐头")
		nutrition_gain += 3
	var meal_text := "、".join(meal_parts) if not meal_parts.is_empty() else "几乎见底的存粮"
	water_supply_state = "off"
	power_supply_state = "off"
	var water_result := _settle_family_needs(nutrition_gain)
	for member_id in FAMILY_ORDER:
		_adjust_member_stat(member_id, "morale", -3)
	if has_flag("adult_sacrifice_day6"):
		for member_id in ["player", "partner", "elder"]:
			_adjust_member_stat(member_id, "hunger", -3)
		_adjust_member_stat("child", "morale", 1)
		_adjust_member_stat("teen", "morale", 2)
	elif has_flag("tight_rationing_day6"):
		_adjust_member_stat("child", "morale", -2)
	var note := "第六夜。全楼已经彻底停电停水。黑暗里只剩手电筒的光斑在天花板上慢慢移动。每个人都在默默算着自己还剩什么。"
	if has_flag("partner_shared_moment"):
		note += " 伴侣靠着你的肩膀——自从雨开始以来，这是第一次谁也没说话但不需要说话。"
	last_rain_day_six_summary = {
		"meal": "晚饭使用：%s" % meal_text,
		"water": str(water_result.get("water_text", "供水状态未知")),
		"power": power_state_label(),
		"family": "五人平均：饱腹%d · 水分%d · 精神%d" % [
			average_member_stat("hunger"), average_member_stat("thirst"), average_member_stat("morale")
		],
		"changes": "正式停水 · 持续停电 · 食物即将见底",
		"note": note,
	}
	flags["rain_day_six_settled"] = true
	last_rain_day_six_summary["audio_hint"] = "狂风 · 间歇雷声 · 水滴从天花板滴落"
	return last_rain_day_six_summary


func settle_rain_day_seven() -> Dictionary:
	if has_flag("rain_day_seven_settled"):
		return last_rain_day_seven_summary
	var meal_parts: Array[String] = []
	var nutrition_gain := 5
	if _consume_item_anywhere("rice", 1) > 0:
		meal_parts.append("大米")
		nutrition_gain += 2
	if _consume_item_anywhere("noodles", 1) > 0:
		meal_parts.append("方便面")
		nutrition_gain += 2
	elif _consume_item_anywhere("canned_fish", 1) > 0:
		meal_parts.append("鱼罐头")
		nutrition_gain += 2
	var meal_text := "、".join(meal_parts) if not meal_parts.is_empty() else "几乎见底的存粮"
	water_supply_state = "off"
	power_supply_state = "off"
	var water_result := _settle_family_needs(nutrition_gain)
	for member_id in FAMILY_ORDER:
		_adjust_member_stat(member_id, "morale", -2)
	if has_flag("trusted_radio_evacuation"):
		for member_id in FAMILY_ORDER:
			_adjust_member_stat(member_id, "morale", 1)
	if has_flag("hedged_bets_day7"):
		_adjust_member_stat("elder", "morale", 2)
	var note := "第七夜。第一周过去了。雨没有停，救援没有来。收音机和老张说了相反的话。你合上家里最后一包方便面的时候，指尖的塑料包装纸把指尖划了一下——不是疼，是指甲又剪了一次。"
	if has_flag("trusted_zhang_over_radio"):
		note += " 你相信邻居亲眼看到的。也许他是对的。也许不是。"
	elif has_flag("trusted_radio_over_zhang"):
		note += " 官方播报也许有它的道理。但你会在之后发现答案。"
	last_rain_day_seven_summary = {
		"meal": "晚饭使用：%s" % meal_text,
		"water": str(water_result.get("water_text", "供水状态未知")),
		"power": power_state_label(),
		"family": "五人平均：饱腹%d · 水分%d · 精神%d" % [
			average_member_stat("hunger"), average_member_stat("thirst"), average_member_stat("morale")
		],
		"changes": "第一周结束 · 供水停电持续 · 食物接近耗尽",
		"note": note,
	}
	flags["rain_day_seven_settled"] = true
	last_rain_day_seven_summary["audio_hint"] = "持续的雨声 · 远处偶尔闷雷 · 屋顶偶尔传来的材料摩擦声"
	return last_rain_day_seven_summary


func begin_experiment_day(day: int) -> void:
	var safe_day := clampi(day, 8, 15)
	phase_id = "rain_day_%d_morning" % safe_day
	day_label = "暴雨第%d天" % safe_day
	time_label = "上午07:00"
	time_segment = "morning"
	weather_label = experiment_weather(safe_day)
	flags["rain_day_%d_started" % safe_day] = true
	water_supply_state = "off"
	power_supply_state = "off"
	set_environment_state("kitchen_faucet", "off")
	enable_continuous_clock(420.0)
	if experiment_start_snapshot.is_empty():
		experiment_start_snapshot = resource_snapshot()


func experiment_weather(day: int) -> String:
	var weather := {
		8: "中雨 · 第二周开始", 9: "暴雨 · 下水道水位上升", 10: "暴雨 · 屋顶持续受压",
		11: "中雨 · 风势减弱", 12: "小雨转中雨 · 短暂亮天", 13: "暴雨 · 污水反灌",
		14: "中雨 · 能见度改善", 15: "小雨 · 云层出现裂口",
	}
	return str(weather.get(day, "暴雨 · 持续中"))


func settle_experiment_day(day: int) -> Dictionary:
	var settle_flag := "rain_day_%d_settled" % day
	if has_flag(settle_flag) and int(last_experiment_summary.get("day", 0)) == day:
		return last_experiment_summary
	var meal_parts: Array[String] = []
	var nutrition_gain := 4
	for item_id in ["rice", "noodles", "canned_fish", "dry_biscuits"]:
		if _consume_item_anywhere(item_id, 1) > 0:
			meal_parts.append(str(shop_item(item_id).get("name", item_id)))
			nutrition_gain += int(shop_item(item_id).get("food", 1))
			if meal_parts.size() >= 2:
				break
	var needs := _settle_family_needs(nutrition_gain)
	var note := "夜里继续下雨。五个人把能用的地方又缩小了一圈。"
	if day == 12:
		note = "雨短暂变小，屋内第一次能听清彼此说话。没人把这当成结束，只把它当作整理房间的窗口。"
	elif day == 14:
		note = "第七天留下的信息在今天有了答案。等待没有结束，但这次不再只靠猜。"
	elif day == 15:
		note = "这段生存实验结束了。暴雨仍会继续，但第二周内提出的问题已经得到回应。"
	last_experiment_summary = {
		"day": day,
		"meal": "、".join(meal_parts) if not meal_parts.is_empty() else "没有完整的一顿饭",
		"water": str(needs.get("water_text", "储备水状态未知")),
		"family": "平均：健康%d · 饱腹%d · 水分%d" % [average_member_stat("health"), average_member_stat("hunger"), average_member_stat("thirst")],
		"changes": experiment_change_label(day),
		"audio_hint": experiment_audio_hint(day),
		"note": note,
	}
	flags[settle_flag] = true
	return last_experiment_summary


func experiment_change_label(day: int) -> String:
	var labels := {
		8: "冰箱保鲜失效", 9: "排水系统发出预警", 10: "二楼出现漏水",
		11: "储水成为主要矛盾", 12: "可用生活区重新划分", 13: "污水反灌",
		14: "广播与目击信息得到验证", 15: "第二周盘点完成",
	}
	return str(labels.get(day, "环境继续恶化"))


func experiment_audio_hint(day: int) -> String:
	if day == 12 or day == 15:
		return "较轻的雨声 · 桶底滴水 · 远处偶尔有人声"
	if day == 9 or day == 13:
		return "暴雨 · 管道咕噜声 · 楼下水流声"
	return "持续雨声 · 屋顶滴水 · 风吹塑料布"


func resource_snapshot() -> Dictionary:
	return {
		"food": total_food_portions(),
		"water": total_water_reserve_liters(),
		"healthy": average_member_stat("health"),
	}


func experiment_delta_summary() -> String:
	var start := experiment_start_snapshot if not experiment_start_snapshot.is_empty() else resource_snapshot()
	var current := resource_snapshot()
	return "食物 %d→%d份；储备水 %.1f→%.1f升；平均健康 %d→%d；可用房间 %d→%d。" % [
		int(start.get("food", 0)), int(current.get("food", 0)),
		float(start.get("water", 0.0)), float(current.get("water", 0.0)),
		int(start.get("healthy", 0)), int(current.get("healthy", 0)),
		int(start.get("usable_rooms", 0)), int(current.get("usable_rooms", 0)),
	]


func add_item_to_storage(item_id: String, amount: int = 1, storage_id: String = "pantry") -> void:
	if item_id.is_empty() or amount <= 0 or shop_item(item_id).is_empty():
		return
	var storage := _container_storage(storage_id)
	storage[item_id] = int(storage.get(item_id, 0)) + amount
	_set_container_storage(storage_id, storage)


func consume_item(item_id: String, amount: int = 1) -> int:
	return _consume_item_anywhere(item_id, amount)


func _consume_from(storage: Dictionary, item_id: String, requested: int) -> int:
	var available := int(storage.get(item_id, 0))
	var consumed := mini(available, requested)
	if consumed <= 0:
		return 0
	storage[item_id] = available - consumed
	if int(storage[item_id]) <= 0:
		storage.erase(item_id)
	return consumed


func inventory_slots() -> int:
	var used := 0
	for item_id in inventory:
		used += int(shop_item(item_id).get("slots", 1))
	return used


func try_take_from_container(container_id: String, item_id: String) -> String:
	var item := shop_item(item_id)
	if item.is_empty():
		return "这个物品暂时不能携带。"
	if inventory_slots() + int(item.get("slots", 1)) > personal_capacity:
		return "随身背包放不下了。"
	var storage := _container_storage(container_id)
	if int(storage.get(item_id, 0)) <= 0:
		return "这里已经没有这件物品。"
	storage[item_id] = int(storage[item_id]) - 1
	if int(storage[item_id]) <= 0:
		storage.erase(item_id)
	_set_container_storage(container_id, storage)
	inventory.append(item_id)
	return ""


func return_inventory_item(item_id: String) -> bool:
	var index := inventory.find(item_id)
	if index < 0:
		return false
	inventory.remove_at(index)
	_store_purchased_item(item_id)
	return true


func total_food_portions() -> int:
	var total := 0
	for storage in [fridge_storage, pantry_storage, utility_storage]:
		for raw_id in storage:
			var item_id := str(raw_id)
			total += int(storage[raw_id]) * int(shop_item(item_id).get("food", 0))
	for item_id in inventory:
		total += int(shop_item(item_id).get("food", 0))
	return total


func total_water_reserve_liters() -> float:
	var bottle_count := int(pantry_storage.get("bottled_water", 0))
	for item_id in inventory:
		if item_id == "bottled_water":
			bottle_count += 1
	return loose_water_liters + float(bottle_count) * 6.0


func backup_power_units() -> int:
	var total := prepared_power_units + int(utility_storage.get("batteries", 0)) * 4
	total += int(utility_storage.get("power_bank", 0)) * 20
	for item_id in inventory:
		if item_id == "batteries":
			total += 4
		elif item_id == "power_bank":
			total += 20
	return total


func family_status_entries() -> Array:
	_ensure_family_states()
	var entries: Array = []
	for member_id in FAMILY_ORDER:
		var state: Dictionary = family_states[member_id]
		entries.append(
			{
				"id": member_id,
				"name": FAMILY_NAMES[member_id],
				"health": int(state.get("health", 100)),
				"hunger": int(state.get("hunger", 80)),
				"thirst": int(state.get("thirst", 80)),
				"morale": int(state.get("morale", 70)),
			}
		)
	return entries


func household_status() -> Dictionary:
	return {
		"water": water_state_label(),
		"power": power_state_label(),
		"food": "%d份" % total_food_portions(),
		"water_reserve": "%.1f升" % total_water_reserve_liters(),
		"backup_power": "%d格" % backup_power_units(),
		"bag": "%d/%d格" % [inventory_slots(), personal_capacity],
	}


func average_member_stat(stat_id: String) -> int:
	_ensure_family_states()
	var total := 0
	for member_id in FAMILY_ORDER:
		total += int((family_states[member_id] as Dictionary).get(stat_id, 0))
	return roundi(float(total) / float(FAMILY_ORDER.size()))


func water_state_label() -> String:
	match water_supply_state:
		"low":
			return "水压偏低"
		"unsafe":
			return "水质异常"
		"off":
			return "已经停水"
	return "自来水正常"


func power_state_label() -> String:
	match power_supply_state:
		"unstable":
			return "市电不稳定"
		"off":
			return "已经停电"
	return "市电正常"


func _settle_family_needs(nutrition_gain: int) -> Dictionary:
	_ensure_family_states()
	var hydration_gain := 28
	var water_text := "自来水正常 · 暂不消耗储备水"
	match water_supply_state:
		"low":
			hydration_gain = 17
			water_text = "水压偏低 · 五人饮水略有不足"
		"unsafe", "off":
			var served := _consume_water_reserve(10.0)
			hydration_gain = roundi(28.0 * served / 10.0)
			water_text = "%s · 使用储备水%.1f升" % [water_state_label(), served]
	for member_id in FAMILY_ORDER:
		var hunger_delta := -22 + nutrition_gain
		var thirst_delta := -26 + hydration_gain
		_adjust_member_stat(member_id, "hunger", hunger_delta)
		_adjust_member_stat(member_id, "thirst", thirst_delta)
		if power_supply_state == "unstable":
			_adjust_member_stat(member_id, "morale", -1)
		elif power_supply_state == "off":
			_adjust_member_stat(member_id, "morale", -3)
		var state: Dictionary = family_states[member_id]
		var health_loss := 0
		if int(state.get("hunger", 100)) < 40:
			health_loss += 3
		if int(state.get("thirst", 100)) < 40:
			health_loss += 5
		if int(state.get("thirst", 100)) < 20:
			health_loss += 6
		if health_loss > 0:
			_adjust_member_stat(member_id, "health", -health_loss)
	return {"water_text": water_text}


func _consume_water_reserve(requested_liters: float) -> float:
	while loose_water_liters < requested_liters:
		if _consume_item_anywhere("bottled_water", 1) <= 0:
			break
		loose_water_liters += 6.0
	var served := minf(loose_water_liters, requested_liters)
	loose_water_liters -= served
	return served


func _consume_item_anywhere(item_id: String, requested: int) -> int:
	var remaining := requested
	for storage in [fridge_storage, pantry_storage, utility_storage]:
		var consumed := _consume_from(storage, item_id, remaining)
		remaining -= consumed
		if remaining <= 0:
			return requested
	while remaining > 0:
		var index := inventory.find(item_id)
		if index < 0:
			break
		inventory.remove_at(index)
		remaining -= 1
	return requested - remaining


func _container_storage(container_id: String) -> Dictionary:
	match container_id:
		"fridge":
			return fridge_storage
		"pantry":
			return pantry_storage
		"bathroom":
			return utility_storage
	return {}


func _set_container_storage(container_id: String, storage: Dictionary) -> void:
	match container_id:
		"fridge":
			fridge_storage = storage
		"pantry":
			pantry_storage = storage
		"bathroom":
			utility_storage = storage


func _default_family_states() -> Dictionary:
	return {
		"player": {"health": 100, "hunger": 82, "thirst": 80, "morale": 70},
		"partner": {"health": 100, "hunger": 80, "thirst": 78, "morale": 72},
		"teen": {"health": 98, "hunger": 84, "thirst": 82, "morale": 68},
		"child": {"health": 96, "hunger": 86, "thirst": 84, "morale": 76},
		"elder": {"health": 84, "hunger": 78, "thirst": 76, "morale": 66},
	}


func _ensure_family_states() -> void:
	if family_states.is_empty():
		family_states = _default_family_states()


func _adjust_member_stat(member_id: String, stat_id: String, delta: int) -> void:
	_ensure_family_states()
	if not family_states.has(member_id):
		return
	var state: Dictionary = family_states[member_id]
	state[stat_id] = clampi(int(state.get(stat_id, 0)) + delta, 0, 100)
	family_states[member_id] = state


func adjust_member_stat(member_id: String, stat_id: String, delta: int) -> void:
	_adjust_member_stat(member_id, stat_id, delta)


func schedule_event(event_id: String, trigger_phase: String) -> void:
	if event_id.is_empty() or trigger_phase.is_empty():
		return
	for raw_entry in scheduled_events:
		if raw_entry is Dictionary and str(raw_entry.get("event_id", "")) == event_id:
			return
	scheduled_events.append({"event_id": event_id, "trigger_phase": trigger_phase})


func remove_scheduled_event(event_id: String) -> void:
	for index in range(scheduled_events.size() - 1, -1, -1):
		var raw_entry: Variant = scheduled_events[index]
		if raw_entry is Dictionary and str(raw_entry.get("event_id", "")) == event_id:
			scheduled_events.remove_at(index)


func record_dialogue_choice(
	character_id: String, choice_index: int, _relation_delta: int, flag_id: String
) -> void:
	dialogue_choices[character_id] = choice_index
	talked_to[character_id] = true
	if not flag_id.is_empty():
		flags[flag_id] = true


func record_inspection(object_id: String) -> void:
	inspected[object_id] = true


func has_flag(flag_id: String) -> bool:
	return bool(flags.get(flag_id, false))


func shop_item(item_id: String) -> Dictionary:
	var base: Dictionary = SHOP_ITEMS.get(item_id, {})
	if base.is_empty():
		return base
	var override: Dictionary = {}
	if is_third_shopping():
		override = THIRD_SHOP_OVERRIDES.get(item_id, {})
	elif is_second_shopping():
		override = SECOND_SHOP_OVERRIDES.get(item_id, {})
	else:
		return base
	if override.is_empty():
		return base
	var merged: Dictionary = base.duplicate()
	for key in override:
		merged[key] = override[key]
	return merged


func is_second_shopping() -> bool:
	return has_flag("second_shopping_active")


func is_third_shopping() -> bool:
	return has_flag("third_shopping_active")


func item_available(item_id: String) -> bool:
	var item := shop_item(item_id)
	if item.is_empty():
		return false
	return bool(item.get("available", true))


func cart_item_count(item_id: String) -> int:
	var count := 0
	for raw_id in shopping_cart:
		if str(raw_id) == item_id:
			count += 1
	return count


func cart_total() -> int:
	var total := 0
	for item_id in shopping_cart:
		total += int(shop_item(item_id).get("price", 0))
	return total


func cart_slots() -> int:
	var used := 0
	for item_id in shopping_cart:
		used += int(shop_item(item_id).get("slots", 1))
	return used


func try_add_shop_item(item_id: String) -> String:
	var item := shop_item(item_id)
	if item.is_empty():
		return "这个商品暂时无法购买。"
	if not bool(item.get("available", true)):
		return "这个商品今天缺货。"
	var limit := int(item.get("limit", 0))
	if limit > 0 and cart_item_count(item_id) >= limit:
		return "这件商品今天限购%d件。" % limit
	var required_slots := int(item.get("slots", 1))
	if cart_slots() + required_slots > trunk_capacity:
		return "后备箱放不下了。可以去收银台拿出最后一件商品。"
	var price := int(item.get("price", 0))
	if cart_total() + price > money:
		return "按现在的购物篮计算，钱不够。"
	shopping_cart.append(item_id)
	return ""


func remove_last_shop_item() -> String:
	if shopping_cart.is_empty():
		return ""
	return shopping_cart.pop_back()


func remove_shop_item(item_id: String) -> bool:
	var index := shopping_cart.find(item_id)
	if index < 0:
		return false
	shopping_cart.remove_at(index)
	return true


func cart_summary() -> String:
	if shopping_cart.is_empty():
		return "购物篮还是空的。"
	var counts: Dictionary = {}
	for item_id in shopping_cart:
		counts[item_id] = int(counts.get(item_id, 0)) + 1
	var parts: Array[String] = []
	for item_id in counts:
		var item := shop_item(str(item_id))
		var suffix := "×%d" % int(counts[item_id]) if int(counts[item_id]) > 1 else ""
		parts.append("%s%s" % [str(item.get("name", item_id)), suffix])
	return "、".join(parts)


func complete_shopping() -> bool:
	var total := cart_total()
	if total > money:
		return false
	money -= total
	for item_id in shopping_cart:
		home_storage[item_id] = int(home_storage.get(item_id, 0)) + 1
		_store_purchased_item(item_id)
	shopping_cart.clear()
	flags["first_shopping_complete"] = true
	return true


func _store_purchased_item(item_id: String) -> void:
	if item_id in ["vegetables", "milk", "meat", "eggs"]:
		fridge_storage[item_id] = int(fridge_storage.get(item_id, 0)) + 1
	elif item_id in ["batteries", "power_bank", "basic_medicine"]:
		utility_storage[item_id] = int(utility_storage.get(item_id, 0)) + 1
	else:
		pantry_storage[item_id] = int(pantry_storage.get(item_id, 0)) + 1


func storage_has_any(item_ids: Array) -> bool:
	for item_id in item_ids:
		if int(home_storage.get(item_id, 0)) > 0:
			return true
	return false


func save_checkpoint(player_position: Vector2, current_floor: int) -> bool:
	var payload := {
		"phase_id": phase_id,
		"day_label": day_label,
		"time_label": time_label,
		"weather_label": weather_label,
		"time_segment": time_segment,
		"continuous_clock_enabled": continuous_clock_enabled,
		"clock_minutes": clock_minutes,
		"clock_rate": clock_rate,
		"clock_end_minutes": clock_end_minutes,
		"money": money,
		"dialogue_choices": dialogue_choices,
		"flags": flags,
		"talked_to": talked_to,
		"inspected": inspected,
		"environment_states": environment_states,
		"inspection_knowledge": inspection_knowledge,
		"inventory": inventory,
		"home_storage": home_storage,
		"shopping_cart": shopping_cart,
		"fridge_storage": fridge_storage,
		"pantry_storage": pantry_storage,
		"utility_storage": utility_storage,
		"afternoon_plan": afternoon_plan,
		"last_night_summary": last_night_summary,
		"water_supply_state": water_supply_state,
		"power_supply_state": power_supply_state,
		"loose_water_liters": loose_water_liters,
		"family_states": family_states,
		"prepared_power_units": prepared_power_units,
		"completed_events": completed_events,
		"event_choices": event_choices,
		"clues": clues,
		"scheduled_events": scheduled_events,
		"event_log": event_log,
		"day_two_preparation": day_two_preparation,
		"last_day_two_summary": last_day_two_summary,
		"last_day_one_summary": last_day_one_summary,
		"last_rain_day_one_summary": last_rain_day_one_summary,
		"last_rain_day_two_summary": last_rain_day_two_summary,
		"last_rain_day_three_summary": last_rain_day_three_summary,
		"last_rain_day_four_summary": last_rain_day_four_summary,
		"last_rain_day_five_summary": last_rain_day_five_summary,
		"last_rain_day_six_summary": last_rain_day_six_summary,
		"last_rain_day_seven_summary": last_rain_day_seven_summary,
		"last_experiment_summary": last_experiment_summary,
		"experiment_start_snapshot": experiment_start_snapshot,
		"player_x": player_position.x,
		"player_y": player_position.y,
		"current_floor": current_floor,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	return true


func load_checkpoint() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return {}
	var payload: Dictionary = parsed
	phase_id = str(payload.get("phase_id", phase_id))
	day_label = str(payload.get("day_label", day_label))
	time_label = str(payload.get("time_label", time_label))
	weather_label = str(payload.get("weather_label", weather_label))
	time_segment = str(payload.get("time_segment", time_segment))
	continuous_clock_enabled = bool(payload.get("continuous_clock_enabled", false))
	clock_minutes = float(payload.get("clock_minutes", clock_minutes))
	clock_rate = float(payload.get("clock_rate", clock_rate))
	clock_end_minutes = float(payload.get("clock_end_minutes", clock_end_minutes))
	money = int(payload.get("money", money))
	dialogue_choices = payload.get("dialogue_choices", {})
	flags = payload.get("flags", {})
	talked_to = payload.get("talked_to", {})
	inspected = payload.get("inspected", {})
	environment_states = payload.get("environment_states", {"kitchen_faucet": "normal"})
	inspection_knowledge = payload.get("inspection_knowledge", {})
	inventory.assign(payload.get("inventory", []))
	home_storage = payload.get("home_storage", {})
	shopping_cart.assign(payload.get("shopping_cart", []))
	fridge_storage = payload.get("fridge_storage", fridge_storage)
	pantry_storage = payload.get("pantry_storage", pantry_storage)
	utility_storage = payload.get("utility_storage", utility_storage)
	afternoon_plan = str(payload.get("afternoon_plan", afternoon_plan))
	last_night_summary = payload.get("last_night_summary", last_night_summary)
	water_supply_state = str(payload.get("water_supply_state", water_supply_state))
	power_supply_state = str(payload.get("power_supply_state", power_supply_state))
	loose_water_liters = float(payload.get("loose_water_liters", loose_water_liters))
	family_states = payload.get("family_states", family_states)
	prepared_power_units = int(payload.get("prepared_power_units", prepared_power_units))
	completed_events = payload.get("completed_events", {})
	event_choices = payload.get("event_choices", {})
	clues = payload.get("clues", {})
	scheduled_events.assign(payload.get("scheduled_events", []))
	event_log.assign(payload.get("event_log", []))
	day_two_preparation = str(payload.get("day_two_preparation", day_two_preparation))
	last_day_two_summary = payload.get("last_day_two_summary", last_day_two_summary)
	last_day_one_summary = payload.get("last_day_one_summary", last_day_one_summary)
	last_rain_day_one_summary = payload.get("last_rain_day_one_summary", last_rain_day_one_summary)
	last_rain_day_two_summary = payload.get("last_rain_day_two_summary", last_rain_day_two_summary)
	last_rain_day_three_summary = payload.get("last_rain_day_three_summary", last_rain_day_three_summary)
	last_rain_day_four_summary = payload.get("last_rain_day_four_summary", last_rain_day_four_summary)
	last_rain_day_five_summary = payload.get("last_rain_day_five_summary", last_rain_day_five_summary)
	last_rain_day_six_summary = payload.get("last_rain_day_six_summary", last_rain_day_six_summary)
	last_rain_day_seven_summary = payload.get("last_rain_day_seven_summary", last_rain_day_seven_summary)
	last_experiment_summary = payload.get("last_experiment_summary", last_experiment_summary)
	experiment_start_snapshot = payload.get("experiment_start_snapshot", experiment_start_snapshot)
	_ensure_family_states()
	return payload
