extends Node

const SAVE_PATH := "user://storm_100_checkpoint.json"

const SHOP_ITEMS := {
	"rice": {"name": "大米", "price": 42, "slots": 2},
	"noodles": {"name": "方便面", "price": 10, "slots": 1},
	"canned_fish": {"name": "鱼罐头", "price": 18, "slots": 1},
	"vegetables": {"name": "蔬菜", "price": 20, "slots": 1},
	"milk": {"name": "牛奶", "price": 16, "slots": 1},
	"chocolate": {"name": "巧克力", "price": 15, "slots": 1},
	"toilet_paper": {"name": "卫生纸", "price": 28, "slots": 2},
	"cleaner": {"name": "清洁用品", "price": 22, "slots": 1},
	"bottled_water": {"name": "瓶装水", "price": 14, "slots": 2},
	"batteries": {"name": "电池", "price": 24, "slots": 1},
	"power_bank": {"name": "充电宝", "price": 65, "slots": 1},
	"basic_medicine": {"name": "常用药", "price": 32, "slots": 1},
}

var phase_id: String = "pre_rain_day_3"
var day_label: String = "暴雨前第3天"
var time_label: String = "上午8:05"
var weather_label: String = "阴 · 尚未下雨"
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


func reset_prologue() -> void:
	phase_id = "pre_rain_day_3"
	day_label = "暴雨前第3天"
	time_label = "上午8:05"
	weather_label = "阴 · 尚未下雨"
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
	return SHOP_ITEMS.get(item_id, {})


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
	shopping_cart.clear()
	flags["first_shopping_complete"] = true
	return true


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
		"money": money,
		"dialogue_choices": dialogue_choices,
		"flags": flags,
		"relationships": relationships,
		"talked_to": talked_to,
		"inspected": inspected,
		"inventory": inventory,
		"home_storage": home_storage,
		"shopping_cart": shopping_cart,
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
	money = int(payload.get("money", money))
	dialogue_choices = payload.get("dialogue_choices", {})
	flags = payload.get("flags", {})
	relationships = payload.get("relationships", relationships)
	talked_to = payload.get("talked_to", {})
	inspected = payload.get("inspected", {})
	inventory.assign(payload.get("inventory", []))
	home_storage = payload.get("home_storage", {})
	shopping_cart.assign(payload.get("shopping_cart", []))
	return payload
