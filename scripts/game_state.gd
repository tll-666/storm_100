extends Node

const SAVE_PATH := "user://storm_100_checkpoint.json"

const SHOP_ITEMS := {
	"rice": {"name": "大米", "price": 42, "slots": 2, "food": 12},
	"noodles": {"name": "方便面", "price": 10, "slots": 1, "food": 2},
	"canned_fish": {"name": "鱼罐头", "price": 18, "slots": 1, "food": 2},
	"vegetables": {"name": "蔬菜", "price": 20, "slots": 1, "food": 3},
	"milk": {"name": "牛奶", "price": 16, "slots": 1, "food": 2},
	"chocolate": {"name": "巧克力", "price": 15, "slots": 1, "food": 1},
	"toilet_paper": {"name": "卫生纸", "price": 28, "slots": 2},
	"cleaner": {"name": "清洁用品", "price": 22, "slots": 1},
	"bottled_water": {"name": "瓶装水", "price": 14, "slots": 2, "water_liters": 6.0},
	"batteries": {"name": "电池", "price": 24, "slots": 1},
	"power_bank": {"name": "充电宝", "price": 65, "slots": 1},
	"basic_medicine": {"name": "常用药", "price": 32, "slots": 1},
	"meat": {"name": "少量肉", "price": 0, "slots": 1, "food": 3},
	"eggs": {"name": "鸡蛋", "price": 0, "slots": 1, "food": 1},
}

const SECOND_SHOP_OVERRIDES := {
	"rice": {"price": 52},
	"vegetables": {"price": 28, "limit": 2},
	"milk": {"price": 22, "limit": 2},
	"bottled_water": {"price": 20, "limit": 2},
	"batteries": {"price": 32, "limit": 2},
	"power_bank": {"price": 85, "limit": 1},
	"toilet_paper": {"price": 35},
	"chocolate": {"available": false},
	"canned_fish": {"price": 24, "limit": 3},
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
var money: int = 220
var personal_capacity: int = 6
var trunk_capacity: int = 10

var dialogue_choices: Dictionary = {}
var flags: Dictionary = {}
var relationships: Dictionary = {
	"partner": 0,
	"teen": 0,
	"child": 0,
	"elder": 0,
}
var talked_to: Dictionary = {}
var inspected: Dictionary = {}
var inventory: Array[String] = []
var home_storage: Dictionary = {}
var shopping_cart: Array[String] = []
var fridge_storage: Dictionary = {"meat": 1, "eggs": 4, "milk": 1, "vegetables": 1}
var pantry_storage: Dictionary = {"rice": 1, "noodles": 2}
var utility_storage: Dictionary = {"toilet_paper": 1, "cleaner": 1}
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


func reset_prologue() -> void:
	phase_id = "pre_rain_day_3"
	day_label = "暴雨前第3天"
	time_label = "上午8:05"
	weather_label = "阴 · 尚未下雨"
	time_segment = "morning"
	money = 220
	dialogue_choices.clear()
	flags.clear()
	relationships = {
		"partner": 0,
		"teen": 0,
		"child": 0,
		"elder": 0,
	}
	talked_to.clear()
	inspected.clear()
	inventory.clear()
	home_storage.clear()
	shopping_cart.clear()
	fridge_storage = {"meat": 1, "eggs": 4, "milk": 1, "vegetables": 1}
	pantry_storage = {"rice": 1, "noodles": 2}
	utility_storage = {"toilet_paper": 1, "cleaner": 1}
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
			relationships["partner"] = int(relationships["partner"]) + 1
			_adjust_member_stat("partner", "morale", 4)
			return "你和伴侣把冷藏、常温和日用品分别归位，又在柜门内侧贴了简短清单。"
		"inspect_house":
			flags["house_rechecked"] = true
			relationships["elder"] = int(relationships["elder"]) + 1
			_adjust_member_stat("elder", "morale", 4)
			return "你重新清理了车库和阳台排水口，也确认配电箱附近没有渗水痕迹。"
		"family_time":
			flags["family_afternoon"] = true
			relationships["teen"] = int(relationships["teen"]) + 1
			relationships["child"] = int(relationships["child"]) + 1
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


func begin_day_one() -> void:
	phase_id = "pre_rain_day_1_morning"
	day_label = "暴雨前第1天"
	time_label = "上午07:00"
	time_segment = "morning"
	weather_label = "零星小雨 · 风势增强"
	flags["day_one_started"] = true


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
		_adjust_member_stat(member_id, "hunger", -22 + nutrition_gain)
		_adjust_member_stat(member_id, "thirst", -26 + hydration_gain)
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
	character_id: String, choice_index: int, relation_delta: int, flag_id: String
) -> void:
	dialogue_choices[character_id] = choice_index
	talked_to[character_id] = true
	if relationships.has(character_id):
		relationships[character_id] = int(relationships[character_id]) + relation_delta
	if not flag_id.is_empty():
		flags[flag_id] = true


func record_inspection(object_id: String) -> void:
	inspected[object_id] = true


func has_flag(flag_id: String) -> bool:
	return bool(flags.get(flag_id, false))


func shop_item(item_id: String) -> Dictionary:
	var base: Dictionary = SHOP_ITEMS.get(item_id, {})
	if base.is_empty() or not is_second_shopping():
		return base
	var override: Dictionary = SECOND_SHOP_OVERRIDES.get(item_id, {})
	if override.is_empty():
		return base
	var merged: Dictionary = base.duplicate()
	for key in override:
		merged[key] = override[key]
	return merged


func is_second_shopping() -> bool:
	return has_flag("second_shopping_active")


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
	elif item_id in ["rice", "noodles", "canned_fish", "chocolate", "bottled_water"]:
		pantry_storage[item_id] = int(pantry_storage.get(item_id, 0)) + 1
	else:
		utility_storage[item_id] = int(utility_storage.get(item_id, 0)) + 1


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
		"money": money,
		"dialogue_choices": dialogue_choices,
		"flags": flags,
		"relationships": relationships,
		"talked_to": talked_to,
		"inspected": inspected,
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
	money = int(payload.get("money", money))
	dialogue_choices = payload.get("dialogue_choices", {})
	flags = payload.get("flags", {})
	relationships = payload.get("relationships", relationships)
	talked_to = payload.get("talked_to", {})
	inspected = payload.get("inspected", {})
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
	_ensure_family_states()
	return payload
