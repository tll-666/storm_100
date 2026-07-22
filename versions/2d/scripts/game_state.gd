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
	"alcohol": {"name": "酒", "price": 35, "slots": 1, "uses": 4},
	"cigarettes": {"name": "香烟", "price": 30, "slots": 1, "uses": 5},
	"meat": {"name": "少量肉", "price": 0, "slots": 1, "food": 3},
	"eggs": {"name": "鸡蛋", "price": 0, "slots": 1, "food": 1},
	"dry_biscuits": {"name": "干饼干", "price": 0, "slots": 1, "food": 2},
	"seeds": {"name": "蔬菜种子", "price": 20, "slots": 1},
	"water_container": {"name": "水桶", "price": 12, "slots": 1, "capacity_liters": 15.0},
	"duct_tape": {"name": "胶带", "price": 8, "slots": 1},
	"basic_toolkit": {"name": "基础工具箱", "price": 48, "slots": 2},
	"portable_purifier": {"name": "便携式手压净水器", "price": 0, "slots": 1},
	"gravity_purifier": {"name": "多级重力净水器", "price": 0, "slots": 3},
	"portable_filter": {"name": "便携滤芯", "price": 0, "slots": 1},
	"gravity_filter": {"name": "多级滤芯组", "price": 0, "slots": 2},
	"shotgun": {"name": "老式猎枪", "price": 0, "slots": 2},
	"ammo": {"name": "猎枪子弹", "price": 0, "slots": 1},
	"empty_bottle": {"name": "空瓶", "price": 0, "slots": 1},
}

const FAMILY_ORDER := ["player", "partner", "teen", "child", "elder"]
const FAMILY_NAMES := {
	"player": "玩家",
	"partner": "伴侣",
	"teen": "大孩子",
	"child": "小孩子",
	"elder": "老人",
}

const FOOD_RULES := {
	"rice": {"servings": 12, "hunger": 24, "morale": 1, "thirst": 0, "shelf_life": -1},
	"noodles": {"servings": 2, "hunger": 26, "morale": 2, "thirst": 0, "shelf_life": -1},
	"canned_fish": {"servings": 2, "hunger": 22, "morale": 3, "thirst": 0, "shelf_life": -1},
	"vegetables": {"servings": 3, "hunger": 14, "morale": 2, "thirst": 5, "shelf_life": 3},
	"milk": {"servings": 2, "hunger": 12, "morale": 3, "thirst": 10, "shelf_life": 2, "morale_over_80": true},
	"chocolate": {"servings": 1, "hunger": 10, "morale": 8, "thirst": 0, "shelf_life": -1, "morale_over_80": true},
	"meat": {"servings": 3, "hunger": 30, "morale": 4, "thirst": 0, "shelf_life": 2},
	"eggs": {"servings": 1, "hunger": 16, "morale": 2, "thirst": 0, "shelf_life": 6},
	"dry_biscuits": {"servings": 2, "hunger": 18, "morale": 2, "thirst": 0, "shelf_life": -1},
}

const SUBSTANCE_RULES := {
	"alcohol": {
		"uses": 4, "hunger": 5, "thirst": 5, "morale": 12, "health": -6,
		"allowed": ["player", "partner", "elder"]
	},
	"cigarettes": {
		"uses": 5, "hunger": 0, "thirst": 0, "morale": 10, "health": -4,
		"allowed": ["player", "elder"]
	},
}

const TOILET_MULTIPLIERS := {
	"player": 1.0,
	"partner": 1.0,
	"teen": 0.9,
	"child": 1.15,
	"elder": 1.25,
}

const PERISHABLE_FOOD_IDS := ["meat", "milk", "vegetables", "eggs"]
const POTABLE_WATER := "potable"
const TAP_RAW_WATER := "tap_raw"
const RAIN_WATER := "rainwater"
const PRETREATED_RAIN_WATER := "pretreated_rain"

var phase_id: String = "pre_rain_day_3"
var day_label: String = "第0天"
var time_label: String = "上午8:05"
var weather_label: String = "阴 · 尚未下雨"
var time_segment: String = "morning"
var continuous_clock_enabled: bool = false
var clock_minutes: float = 485.0
var clock_rate: float = 2.0
var clock_end_minutes: float = 1380.0
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
var pantry_storage: Dictionary = {"rice": 1, "noodles": 2, "water_container": 1}
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
var survival_day: int = 0
var gas_supply_state: String = "normal"
var food_batches: Array = []
var next_food_batch_id: int = 1
var water_containers: Array = []
var next_water_container_id: int = 1
var purifier_states: Dictionary = {}
var daily_purifier_usage: Dictionary = {"portable": 0.0, "gravity": 0.0}
var daily_assignments: Dictionary = {}
var daily_intake_log: Dictionary = {}
var daily_ration_confirmed: bool = false
var daily_ration_day: int = -1
var daily_substance_users: Dictionary = {}
var consumable_uses: Dictionary = {}
var toilet_needs: Dictionary = {}
var toilet_tank_liters: float = 12.0
var toilet_unflushed_uses: int = 0
var toilet_state: String = "normal"
var toilet_occupied_by: String = ""
var toilet_occupied_floor: int = 2
var toilet_visit_end_minute: float = -1.0
var toilet_queue: Array[String] = []
var npc_activities: Dictionary = {}
var daily_consequences: Array[String] = []
var daily_settlement_changes: Array[String] = []
var pending_consequences: Array = []
var room_function_states: Dictionary = {}
var hidden_event_states: Dictionary = {}
var ending_progress: Dictionary = {}


func reset_prologue() -> void:
	phase_id = "pre_rain_day_3"
	day_label = "第0天"
	time_label = "上午8:05"
	weather_label = "阴 · 尚未下雨"
	time_segment = "morning"
	continuous_clock_enabled = false
	clock_minutes = 485.0
	clock_rate = 2.0
	clock_end_minutes = 1380.0
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
	pantry_storage = {"rice": 1, "noodles": 2, "water_container": 1}
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
	_reset_survival_state()


func _ready() -> void:
	_ensure_survival_state()


func _reset_survival_state() -> void:
	survival_day = 0
	gas_supply_state = "normal"
	food_batches.clear()
	next_food_batch_id = 1
	_add_food_batch("meat", 1, "fridge", false)
	_add_food_batch("eggs", 4, "fridge", false)
	_add_food_batch("milk", 1, "fridge", false)
	_add_food_batch("vegetables", 1, "fridge", false)
	_add_food_batch("rice", 1, "pantry", false)
	_add_food_batch("noodles", 2, "pantry", false)
	water_containers.clear()
	next_water_container_id = 1
	_add_water_container("water_container", 15.0, 0.0, "empty", "pantry", false)
	purifier_states.clear()
	daily_purifier_usage = {"portable": 0.0, "gravity": 0.0}
	daily_assignments.clear()
	daily_intake_log.clear()
	daily_ration_confirmed = false
	daily_ration_day = -1
	daily_substance_users.clear()
	consumable_uses.clear()
	toilet_needs.clear()
	for member_id in FAMILY_ORDER:
		toilet_needs[member_id] = 0.0
	toilet_tank_liters = 12.0
	toilet_unflushed_uses = 0
	toilet_state = "normal"
	toilet_occupied_by = ""
	toilet_occupied_floor = 2
	toilet_visit_end_minute = -1.0
	toilet_queue.clear()
	npc_activities.clear()
	daily_consequences.clear()
	daily_settlement_changes.clear()
	pending_consequences.clear()
	room_function_states = {"living_room": "normal", "radio": "available", "fridge_power": "normal"}
	hidden_event_states.clear()
	ending_progress = {
		"military_information": false,
		"military_seat_conflict": false,
		"boat_tools": false,
		"boat_guide": false,
		"boat_materials": 0,
		"boat_built": false,
		"survived_days": 0,
	}


func _ensure_survival_state() -> void:
	_ensure_family_states()
	if food_batches.is_empty():
		for storage_id in ["fridge", "pantry"]:
			var storage := _container_storage(storage_id)
			for raw_id in storage:
				var item_id := str(raw_id)
				if FOOD_RULES.has(item_id):
					_add_food_batch(item_id, int(storage[raw_id]), storage_id, false)
	if water_containers.is_empty():
		var bucket_count := int(pantry_storage.get("water_container", 0))
		if bucket_count <= 0:
			bucket_count = 1
			pantry_storage["water_container"] = 1
		for _index in range(bucket_count):
			_add_water_container("water_container", 15.0, 0.0, "empty", "pantry", false)
		var bottled_count := int(pantry_storage.get("bottled_water", 0))
		for _index in range(bottled_count):
			_add_water_container("bottled_water", 6.0, 6.0, POTABLE_WATER, "pantry", false)
		if loose_water_liters > 0.0:
			_add_water_container(
				"legacy_reserve", loose_water_liters, loose_water_liters, POTABLE_WATER, "pantry", false
			)
			loose_water_liters = 0.0
	if toilet_needs.is_empty():
		for member_id in FAMILY_ORDER:
			toilet_needs[member_id] = 0.0
	if room_function_states.is_empty():
		room_function_states = {"living_room": "normal", "radio": "available", "fridge_power": "normal"}
	elif not room_function_states.has("fridge_power"):
		room_function_states["fridge_power"] = "normal"
	if ending_progress.is_empty():
		ending_progress = {
			"military_information": false,
			"military_seat_conflict": false,
			"boat_tools": false,
			"boat_guide": false,
			"boat_materials": 0,
			"boat_built": false,
			"survived_days": 0,
		}
	for item_id in SUBSTANCE_RULES:
		if consumable_uses.has(item_id):
			continue
		var item_count := inventory.count(item_id)
		for storage in [fridge_storage, pantry_storage, utility_storage]:
			item_count += int(storage.get(item_id, 0))
		if item_count > 0:
			register_consumable_uses(item_id, item_count)
	if purifier_states.is_empty():
		if storage_has_any(["portable_purifier"]):
			register_purifier("portable_purifier")
		if storage_has_any(["gravity_purifier"]):
			register_purifier("gravity_purifier")


func start_survival_day(day: int) -> void:
	_ensure_survival_state()
	survival_day = maxi(0, day)
	ending_progress["survived_days"] = maxi(int(ending_progress.get("survived_days", 0)), survival_day)
	update_utilities_for_day(survival_day)
	daily_assignments.clear()
	for member_id in FAMILY_ORDER:
		daily_assignments[member_id] = {"food": "", "water": false}
	daily_intake_log.clear()
	daily_ration_confirmed = false
	daily_ration_day = survival_day
	daily_substance_users.clear()
	daily_purifier_usage = {"portable": 0.0, "gravity": 0.0}
	daily_consequences.clear()
	daily_settlement_changes.clear()
	_apply_due_consequences()
	if survival_day in [2, 3] and not has_flag("breaker_repaired"):
		room_function_states["fridge_power"] = "tripped"
		if survival_day == 2:
			hidden_event_states["r2_breaker_trip"] = {
				"occurred": true, "discovered": false, "resolved": false, "day": 2
			}
	elif survival_day < 4:
		room_function_states["fridge_power"] = "normal"
	else:
		room_function_states["fridge_power"] = "grid_off"
	clock_rate = 2.0
	clock_end_minutes = 1380.0
	enable_continuous_clock(420.0)
	if survival_day == 1:
		hidden_event_states["r1_window_leak"] = {
			"occurred": true, "discovered": false, "resolved": false, "day": 1
		}


func current_survival_day() -> int:
	if survival_day > 0:
		return survival_day
	if phase_id.begins_with("rain_day_"):
		var suffix := phase_id.trim_prefix("rain_day_").get_slice("_", 0)
		if suffix.is_valid_int():
			return int(suffix)
	return 0


func should_open_midday_ration() -> bool:
	return (
		current_survival_day() >= 1
		and continuous_clock_enabled
		and clock_minutes >= 720.0
		and not daily_ration_confirmed
		and daily_ration_day == current_survival_day()
	)


func food_rule(item_id: String) -> Dictionary:
	return FOOD_RULES.get(item_id, {})


func is_food_item(item_id: String) -> bool:
	return FOOD_RULES.has(item_id)


func _add_food_batch(
	item_id: String, package_count: int, storage_id: String, update_legacy: bool = true
) -> void:
	var rule := food_rule(item_id)
	if rule.is_empty() or package_count <= 0:
		return
	food_batches.append({
		"batch_id": next_food_batch_id,
		"item_id": item_id,
		"servings": int(rule.get("servings", 1)) * package_count,
		"package_count": package_count,
		"storage": storage_id,
		"fresh_days": int(rule.get("shelf_life", -1)),
		"spoiled_days": 0,
	})
	next_food_batch_id += 1
	if update_legacy:
		_sync_food_legacy_storage()


func _sync_food_legacy_storage() -> void:
	for storage_id in ["fridge", "pantry", "bathroom"]:
		var storage := _container_storage(storage_id)
		for item_id in FOOD_RULES:
			storage.erase(item_id)
		_set_container_storage(storage_id, storage)
	for raw_batch in food_batches:
		if not (raw_batch is Dictionary):
			continue
		var batch: Dictionary = raw_batch
		var servings := int(batch.get("servings", 0))
		if servings <= 0:
			continue
		var item_id := str(batch.get("item_id", ""))
		var per_package := maxi(1, int(food_rule(item_id).get("servings", 1)))
		var package_count := int(ceil(float(servings) / float(per_package)))
		var storage_id := str(batch.get("storage", "pantry"))
		if storage_id == "inventory":
			continue
		var storage := _container_storage(storage_id)
		storage[item_id] = int(storage.get(item_id, 0)) + package_count
		_set_container_storage(storage_id, storage)


func available_food_servings(item_id: String) -> int:
	var total := 0
	for raw_batch in food_batches:
		if raw_batch is Dictionary and str(raw_batch.get("item_id", "")) == item_id:
			total += int(raw_batch.get("servings", 0))
	return total


func food_storage_entries(storage_id: String) -> Array:
	var entries: Array = []
	for raw_batch in food_batches:
		if not (raw_batch is Dictionary):
			continue
		var batch: Dictionary = raw_batch
		if str(batch.get("storage", "")) != storage_id or int(batch.get("servings", 0)) <= 0:
			continue
		var item_id := str(batch.get("item_id", ""))
		var item := shop_item(item_id)
		var fresh_text := food_batch_freshness_text(batch)
		entries.append({
			"id": item_id,
			"name": str(item.get("name", item_id)),
			"count": int(batch.get("servings", 0)),
			"meta": "%d份 · %s" % [int(batch.get("servings", 0)), fresh_text],
			"span": maxi(1, int(batch.get("package_count", 1))) * int(item.get("slots", 1)),
		})
	return entries


func food_batch_freshness_text(batch: Dictionary) -> String:
	var item_id := str(batch.get("item_id", ""))
	var shelf_life := int(food_rule(item_id).get("shelf_life", -1))
	if shelf_life < 0:
		return "常温耐放"
	var spoiled_days := int(batch.get("spoiled_days", 0))
	if spoiled_days > 0:
		return "已变质%d天 · 食用有风险" % spoiled_days
	var storage_id := str(batch.get("storage", "fridge"))
	var fridge_powered := power_supply_state != "off" and str(room_function_states.get("fridge_power", "normal")) == "normal"
	if storage_id == "fridge" and fridge_powered:
		return "新鲜 · 冷藏中，暂不倒计时"
	var fresh_days := int(batch.get("fresh_days", shelf_life))
	if fresh_days <= 1:
		return "临期 · 今晚结算后变质"
	return "新鲜 · 还有%d天变质" % fresh_days


func _consume_food_serving(item_id: String) -> Dictionary:
	var selected_index := -1
	var selected_freshness := 9999
	for index in range(food_batches.size()):
		var raw_batch: Variant = food_batches[index]
		if not (raw_batch is Dictionary):
			continue
		var batch: Dictionary = raw_batch
		if str(batch.get("item_id", "")) != item_id or int(batch.get("servings", 0)) <= 0:
			continue
		var freshness := int(batch.get("fresh_days", 9999))
		if int(batch.get("spoiled_days", 0)) > 0:
			freshness = -int(batch.get("spoiled_days", 0))
		if selected_index < 0 or freshness < selected_freshness:
			selected_index = index
			selected_freshness = freshness
	if selected_index < 0:
		return {}
	var consumed: Dictionary = (food_batches[selected_index] as Dictionary).duplicate(true)
	var batch: Dictionary = food_batches[selected_index]
	batch["servings"] = int(batch.get("servings", 0)) - 1
	food_batches[selected_index] = batch
	if int(batch.get("servings", 0)) <= 0:
		food_batches.remove_at(selected_index)
	_sync_food_legacy_storage()
	return consumed


func age_food_batches() -> Array[String]:
	var changes: Array[String] = []
	for index in range(food_batches.size() - 1, -1, -1):
		var batch: Dictionary = food_batches[index]
		var item_id := str(batch.get("item_id", ""))
		var shelf_life := int(food_rule(item_id).get("shelf_life", -1))
		if shelf_life < 0:
			continue
		var fridge_powered := power_supply_state != "off" and str(room_function_states.get("fridge_power", "normal")) == "normal"
		var unchilled := str(batch.get("storage", "fridge")) != "fridge" or not fridge_powered
		if not unchilled:
			continue
		var was_spoiled := int(batch.get("spoiled_days", 0)) > 0
		if not was_spoiled:
			batch["fresh_days"] = int(batch.get("fresh_days", shelf_life)) - 1
			if int(batch.get("fresh_days", 0)) <= 0:
				batch["spoiled_days"] = 1
				changes.append("%s开始变质" % str(shop_item(item_id).get("name", item_id)))
		else:
			batch["spoiled_days"] = int(batch.get("spoiled_days", 0)) + 1
			batch["servings"] = maxi(0, int(batch.get("servings", 0)) - 1)
			changes.append("%s因持续变质损失1份" % str(shop_item(item_id).get("name", item_id)))
		food_batches[index] = batch
		if int(batch.get("servings", 0)) <= 0:
			food_batches.remove_at(index)
	_sync_food_legacy_storage()
	return changes


func _reserved_food_count(item_id: String, excluding_member: String = "") -> int:
	var count := 0
	for member_id in daily_assignments:
		if str(member_id) == excluding_member:
			continue
		var assignment: Dictionary = daily_assignments[member_id]
		if str(assignment.get("food", "")) == item_id:
			count += 1
	return count


func cycle_member_food(member_id: String, direction: int = 1) -> void:
	if daily_ration_confirmed or not daily_assignments.has(member_id):
		return
	var options: Array[String] = [""]
	for item_id in FOOD_RULES:
		if available_food_servings(str(item_id)) > _reserved_food_count(str(item_id), member_id):
			options.append(str(item_id))
	options.sort_custom(func(left: String, right: String) -> bool: return left < right)
	if options.size() <= 1:
		return
	var current := str((daily_assignments[member_id] as Dictionary).get("food", ""))
	var current_index := options.find(current)
	if current_index < 0:
		current_index = 0
	var next_index := posmod(current_index + (1 if direction >= 0 else -1), options.size())
	var assignment: Dictionary = daily_assignments[member_id]
	assignment["food"] = options[next_index]
	daily_assignments[member_id] = assignment


func toggle_member_water(member_id: String) -> bool:
	if daily_ration_confirmed or not daily_assignments.has(member_id):
		return false
	var assignment: Dictionary = daily_assignments[member_id]
	var currently := bool(assignment.get("water", false))
	if not currently:
		var reserved := 0
		for raw_assignment in daily_assignments.values():
			if raw_assignment is Dictionary and bool(raw_assignment.get("water", false)):
				reserved += 1
		if total_water_by_quality(POTABLE_WATER) < float(reserved + 1):
			return false
	assignment["water"] = not currently
	daily_assignments[member_id] = assignment
	return true


func rationing_rows() -> Array:
	var rows: Array = []
	for member_id in FAMILY_ORDER:
		var assignment: Dictionary = daily_assignments.get(member_id, {"food": "", "water": false})
		var food_id := str(assignment.get("food", ""))
		var food_label := "不进食"
		if not food_id.is_empty():
			food_label = "%s（%s）" % [
				str(shop_item(food_id).get("name", food_id)),
				next_food_serving_status(food_id),
			]
		rows.append({
			"id": member_id,
			"name": FAMILY_NAMES[member_id],
			"food": food_label,
			"water": "饮用1L" if bool(assignment.get("water", false)) else "不饮水",
		})
	return rows


func next_food_serving_status(item_id: String) -> String:
	var selected: Dictionary = {}
	var selected_freshness := 9999
	for raw_batch in food_batches:
		if not (raw_batch is Dictionary):
			continue
		var batch: Dictionary = raw_batch
		if str(batch.get("item_id", "")) != item_id or int(batch.get("servings", 0)) <= 0:
			continue
		var freshness := int(batch.get("fresh_days", 9999))
		if int(batch.get("spoiled_days", 0)) > 0:
			freshness = -int(batch.get("spoiled_days", 0))
		if selected.is_empty() or freshness < selected_freshness:
			selected = batch
			selected_freshness = freshness
	return food_batch_freshness_text(selected) if not selected.is_empty() else "已经没有了"


func confirm_daily_rations() -> Dictionary:
	if daily_ration_confirmed:
		return {"ok": false, "error": "今天已经完成分配。"}
	var water_needed := 0
	for raw_assignment in daily_assignments.values():
		if raw_assignment is Dictionary and bool(raw_assignment.get("water", false)):
			water_needed += 1
	if total_water_by_quality(POTABLE_WATER) + 0.001 < float(water_needed):
		return {"ok": false, "error": "直饮水不足，请减少饮水分配。"}
	for item_id in FOOD_RULES:
		if _reserved_food_count(str(item_id)) > available_food_servings(str(item_id)):
			return {"ok": false, "error": "%s的剩余份数不足。" % str(shop_item(str(item_id)).get("name", item_id))}
	daily_intake_log.clear()
	for member_id in FAMILY_ORDER:
		var multiplier := float(TOILET_MULTIPLIERS.get(member_id, 1.0))
		toilet_needs[member_id] = float(toilet_needs.get(member_id, 0.0)) + 15.0 * multiplier
		var assignment: Dictionary = daily_assignments.get(member_id, {"food": "", "water": false})
		var food_id := str(assignment.get("food", ""))
		var food_text := "未进食"
		if not food_id.is_empty():
			var consumed := _consume_food_serving(food_id)
			if consumed.is_empty():
				return {"ok": false, "error": "分配的食物已经不足，请重新选择。"}
			_apply_food_serving(member_id, food_id, consumed)
			toilet_needs[member_id] = float(toilet_needs[member_id]) + 35.0 * multiplier
			food_text = str(shop_item(food_id).get("name", food_id))
		var water_text := "未饮水"
		if bool(assignment.get("water", false)):
			var served := consume_water_by_quality(POTABLE_WATER, 1.0)
			if served < 0.999:
				return {"ok": false, "error": "分配过程中直饮水不足。"}
			_adjust_member_stat(member_id, "thirst", 30)
			toilet_needs[member_id] = float(toilet_needs[member_id]) + 45.0 * multiplier
			water_text = "直饮水1L"
		daily_intake_log[member_id] = {"food": food_text, "water": water_text}
	daily_ration_confirmed = true
	_queue_toilet_visits()
	return {"ok": true, "summary": daily_ration_summary()}


func _apply_food_serving(member_id: String, item_id: String, batch: Dictionary) -> void:
	var rule := food_rule(item_id)
	var spoiled_days := int(batch.get("spoiled_days", 0))
	if spoiled_days <= 0:
		_adjust_member_stat(member_id, "hunger", int(rule.get("hunger", 0)))
		_adjust_member_stat(member_id, "thirst", int(rule.get("thirst", 0)))
		_restore_morale(member_id, int(rule.get("morale", 0)), bool(rule.get("morale_over_80", false)))
		return
	var factor := 0.7 if spoiled_days <= 1 else 0.4
	_adjust_member_stat(member_id, "hunger", roundi(float(rule.get("hunger", 0)) * factor))
	_adjust_member_stat(member_id, "thirst", roundi(float(rule.get("thirst", 0)) * factor))
	_adjust_member_stat(member_id, "health", -4 if spoiled_days <= 1 else -10)
	_adjust_member_stat(member_id, "morale", -3 if spoiled_days <= 1 else -6)


func _restore_morale(member_id: String, amount: int, can_exceed_eighty: bool) -> void:
	if amount <= 0 or not family_states.has(member_id):
		return
	var state: Dictionary = family_states[member_id]
	var current := int(state.get("morale", 100))
	var limit := 100 if can_exceed_eighty else 80
	if current >= limit:
		return
	state["morale"] = mini(limit, current + amount)
	family_states[member_id] = state


func daily_ration_summary() -> String:
	var parts: Array[String] = []
	for member_id in FAMILY_ORDER:
		var intake: Dictionary = daily_intake_log.get(member_id, {"food": "未进食", "water": "未饮水"})
		parts.append("%s：%s、%s" % [FAMILY_NAMES[member_id], str(intake.get("food", "未进食")), str(intake.get("water", "未饮水"))])
	return "；".join(parts)


func _add_water_container(
	kind: String,
	capacity: float,
	amount: float,
	quality: String,
	storage_id: String,
	update_legacy: bool = true
) -> void:
	water_containers.append({
		"container_id": next_water_container_id,
		"kind": kind,
		"capacity": maxf(0.0, capacity),
		"amount": clampf(amount, 0.0, maxf(0.0, capacity)),
		"quality": quality,
		"storage": storage_id,
	})
	next_water_container_id += 1
	if update_legacy:
		_sync_water_legacy_storage()


func _sync_water_legacy_storage() -> void:
	for storage_id in ["fridge", "pantry", "bathroom"]:
		var storage := _container_storage(storage_id)
		for item_id in ["water_container", "bottled_water", "empty_bottle"]:
			storage.erase(item_id)
		_set_container_storage(storage_id, storage)
	for raw_container in water_containers:
		if not (raw_container is Dictionary):
			continue
		var container: Dictionary = raw_container
		var kind := str(container.get("kind", ""))
		if kind not in ["water_container", "bottled_water", "empty_bottle"]:
			continue
		var storage_id := str(container.get("storage", "pantry"))
		if storage_id == "inventory":
			continue
		var storage := _container_storage(storage_id)
		storage[kind] = int(storage.get(kind, 0)) + 1
		_set_container_storage(storage_id, storage)


func total_water_by_quality(quality: String) -> float:
	_ensure_survival_state()
	var total := 0.0
	for raw_container in water_containers:
		if raw_container is Dictionary and str(raw_container.get("quality", "")) == quality:
			total += float(raw_container.get("amount", 0.0))
	return total


func total_raw_water_liters() -> float:
	return (
		total_water_by_quality(TAP_RAW_WATER)
		+ total_water_by_quality(RAIN_WATER)
		+ total_water_by_quality(PRETREATED_RAIN_WATER)
	)


func add_potable_water(amount: float) -> void:
	if amount <= 0.001:
		return
	_add_water_container("emergency_reserve", amount, amount, POTABLE_WATER, "pantry", false)


func consume_water_by_quality(quality: String, requested: float) -> float:
	var remaining := maxf(0.0, requested)
	for index in range(water_containers.size()):
		if remaining <= 0.001:
			break
		var container: Dictionary = water_containers[index]
		if str(container.get("quality", "")) != quality:
			continue
		var available := float(container.get("amount", 0.0))
		var consumed := minf(available, remaining)
		container["amount"] = available - consumed
		remaining -= consumed
		if float(container.get("amount", 0.0)) <= 0.001:
			container["amount"] = 0.0
			container["quality"] = "empty"
			if str(container.get("kind", "")) == "bottled_water":
				container["kind"] = "empty_bottle"
				# 瓶装水按一组6L容器建模，喝完后仍保留相同总容积。
				container["capacity"] = 6.0
		water_containers[index] = container
	_sync_water_legacy_storage()
	return requested - remaining


func water_storage_entries(storage_id: String) -> Array:
	var entries: Array = []
	for raw_container in water_containers:
		if not (raw_container is Dictionary):
			continue
		var container: Dictionary = raw_container
		if str(container.get("storage", "")) != storage_id:
			continue
		var kind := str(container.get("kind", ""))
		var name := str(shop_item(kind).get("name", kind))
		var amount := float(container.get("amount", 0.0))
		var capacity := float(container.get("capacity", 0.0))
		var quality := str(container.get("quality", "empty"))
		entries.append({
			"id": "water:%d" % int(container.get("container_id", -1)),
			"icon_id": kind,
			"name": name,
			"count": 1,
			"meta": "%.1f/%.1fL · %s" % [amount, capacity, water_quality_label(quality)],
			"span": int(shop_item(kind).get("slots", 1)),
		})
	return entries


func empty_water_container(container_id: int) -> String:
	for index in range(water_containers.size()):
		var container: Dictionary = water_containers[index]
		if int(container.get("container_id", -1)) != container_id:
			continue
		var amount := float(container.get("amount", 0.0))
		if amount <= 0.001:
			return "这个容器已经是空的。"
		var old_quality := water_quality_label(str(container.get("quality", "empty")))
		container["amount"] = 0.0
		container["quality"] = "empty"
		if str(container.get("kind", "")) == "bottled_water":
			container["kind"] = "empty_bottle"
			container["capacity"] = 6.0
		water_containers[index] = container
		_sync_water_legacy_storage()
		return "倒掉了%.1fL%s，容器现在可以重新使用。" % [amount, old_quality]
	return "找不到这个水容器。"


func water_quality_label(quality: String) -> String:
	match quality:
		POTABLE_WATER:
			return "直饮水"
		TAP_RAW_WATER:
			return "自来水原水"
		RAIN_WATER:
			return "未处理雨水"
		PRETREATED_RAIN_WATER:
			return "已预处理雨水"
	return "空容器"


func fill_container_at_faucet() -> String:
	_ensure_survival_state()
	if water_supply_state == "off":
		return "停水了，水龙头拧不出水。"
	var selected_index := -1
	for index in range(water_containers.size()):
		var container: Dictionary = water_containers[index]
		if float(container.get("amount", 0.0)) <= 0.001 and str(container.get("kind", "")) in ["water_container", "empty_bottle"]:
			selected_index = index
			if str(container.get("kind", "")) == "water_container":
				break
	if selected_index < 0:
		return "没有空容器。先喝掉、倒掉或增加新的水桶和空瓶。"
	var selected: Dictionary = water_containers[selected_index]
	selected["amount"] = float(selected.get("capacity", 0.0))
	selected["quality"] = POTABLE_WATER if water_supply_state in ["normal", "low"] else TAP_RAW_WATER
	water_containers[selected_index] = selected
	_sync_water_legacy_storage()
	return "接满了一个%s：%.0fL%s。" % [
		str(shop_item(str(selected.get("kind", "water_container"))).get("name", "容器")),
		float(selected.get("amount", 0.0)),
		"直饮水" if str(selected.get("quality", "")) == POTABLE_WATER else "需要烧开或简单净化的自来水原水",
	]


func collect_rainwater() -> String:
	if current_survival_day() < 1:
		return "暴雨还没有开始，窗边接水区目前收不到雨水。"
	var selected_index := -1
	for index in range(water_containers.size()):
		var container: Dictionary = water_containers[index]
		if str(container.get("kind", "")) == "water_container" and float(container.get("amount", 0.0)) <= 0.001:
			selected_index = index
			break
	if selected_index < 0:
		return "没有空水桶，雨水无处储存。"
	var selected: Dictionary = water_containers[selected_index]
	selected["amount"] = float(selected.get("capacity", 15.0))
	selected["quality"] = RAIN_WATER
	water_containers[selected_index] = selected
	_sync_water_legacy_storage()
	return "雨水装满了一个15L水桶。必须经过专门净化后才能饮用。"


func pretreat_rainwater() -> String:
	for index in range(water_containers.size()):
		var container: Dictionary = water_containers[index]
		if str(container.get("quality", "")) == RAIN_WATER and float(container.get("amount", 0.0)) > 0.0:
			container["quality"] = PRETREATED_RAIN_WATER
			water_containers[index] = container
			return "雨水已经静置并完成布滤预处理，可以交给便携净水器。"
	return "没有可预处理的雨水。"


func register_purifier(item_id: String) -> void:
	if item_id == "portable_purifier" and not purifier_states.has("portable"):
		purifier_states["portable"] = {"filter_remaining": 30.0, "daily_limit": 3.0}
	elif item_id == "gravity_purifier" and not purifier_states.has("gravity"):
		purifier_states["gravity"] = {"filter_remaining": 100.0, "daily_limit": 10.0}


func replace_purifier_filter(device_id: String) -> String:
	var filter_item := "portable_filter" if device_id == "portable" else "gravity_filter"
	if not purifier_states.has(device_id):
		return "家里没有对应的净水器。"
	if _consume_item_anywhere(filter_item, 1) <= 0:
		return "没有对应的替换滤芯。"
	var state: Dictionary = purifier_states[device_id]
	state["filter_remaining"] = 30.0 if device_id == "portable" else 100.0
	purifier_states[device_id] = state
	return "已经更换%s。" % str(shop_item(filter_item).get("name", "滤芯"))


func purify_water(device_id: String) -> String:
	if not purifier_states.has(device_id):
		return "家里没有这台净水器。"
	var state: Dictionary = purifier_states[device_id]
	var daily_limit := float(state.get("daily_limit", 0.0))
	var used_today := float(daily_purifier_usage.get(device_id, 0.0))
	var remaining_today := maxf(0.0, daily_limit - used_today)
	var filter_remaining := float(state.get("filter_remaining", 0.0))
	if remaining_today <= 0.001:
		return "今天的净水能力已经用完。"
	if filter_remaining <= 0.001:
		return "滤芯已经耗尽，需要通过事件或交换获得对应滤芯。"
	var allowed_qualities: Array[String] = [TAP_RAW_WATER, PRETREATED_RAIN_WATER]
	if device_id == "gravity":
		allowed_qualities.append(RAIN_WATER)
	var source_index := -1
	for index in range(water_containers.size()):
		var container: Dictionary = water_containers[index]
		if str(container.get("quality", "")) in allowed_qualities and float(container.get("amount", 0.0)) > 0.001:
			source_index = index
			break
	if source_index < 0:
		return "没有这台设备可以处理的原水。"
	var destination_index := -1
	for index in range(water_containers.size()):
		var container: Dictionary = water_containers[index]
		if index != source_index and float(container.get("amount", 0.0)) <= 0.001:
			destination_index = index
			break
	if destination_index < 0:
		return "缺少空容器盛放净化后的直饮水。"
	var source: Dictionary = water_containers[source_index]
	var destination: Dictionary = water_containers[destination_index]
	var amount := minf(
		minf(float(source.get("amount", 0.0)), float(destination.get("capacity", 0.0))),
		minf(remaining_today, filter_remaining)
	)
	source["amount"] = float(source.get("amount", 0.0)) - amount
	if float(source.get("amount", 0.0)) <= 0.001:
		source["amount"] = 0.0
		source["quality"] = "empty"
	destination["amount"] = amount
	destination["quality"] = POTABLE_WATER
	water_containers[source_index] = source
	water_containers[destination_index] = destination
	state["filter_remaining"] = filter_remaining - amount
	purifier_states[device_id] = state
	daily_purifier_usage[device_id] = used_today + amount
	return "净化得到%.1fL直饮水；滤芯还能处理%.1fL。" % [amount, float(state.get("filter_remaining", 0.0))]


func boil_tap_water() -> String:
	if gas_supply_state != "normal":
		return "燃气不可用，暂时无法烧水。"
	var source_index := -1
	var destination_index := -1
	for index in range(water_containers.size()):
		var container: Dictionary = water_containers[index]
		if source_index < 0 and str(container.get("quality", "")) == TAP_RAW_WATER and float(container.get("amount", 0.0)) > 0.001:
			source_index = index
		elif destination_index < 0 and float(container.get("amount", 0.0)) <= 0.001:
			destination_index = index
	if source_index < 0:
		return "没有需要烧开的自来水原水。"
	if destination_index < 0 or destination_index == source_index:
		return "缺少空容器盛放烧开后的水。"
	var source: Dictionary = water_containers[source_index]
	var destination: Dictionary = water_containers[destination_index]
	var amount := minf(3.0, minf(float(source.get("amount", 0.0)), float(destination.get("capacity", 0.0))))
	source["amount"] = float(source.get("amount", 0.0)) - amount
	if float(source.get("amount", 0.0)) <= 0.001:
		source["amount"] = 0.0
		source["quality"] = "empty"
	destination["amount"] = amount
	destination["quality"] = POTABLE_WATER
	water_containers[source_index] = source
	water_containers[destination_index] = destination
	return "用燃气灶烧开并冷却了%.1fL自来水，已经装入空容器。" % amount


func register_consumable_uses(item_id: String, item_count: int = 1) -> void:
	if not SUBSTANCE_RULES.has(item_id) or item_count <= 0:
		return
	consumable_uses[item_id] = int(consumable_uses.get(item_id, 0)) + int(SUBSTANCE_RULES[item_id].get("uses", 1)) * item_count


func use_substance(member_id: String, item_id: String) -> String:
	if not SUBSTANCE_RULES.has(item_id):
		return "这个物品不能这样使用。"
	var rule: Dictionary = SUBSTANCE_RULES[item_id]
	if member_id not in rule.get("allowed", []):
		return "%s不能使用%s。" % [FAMILY_NAMES.get(member_id, "该角色"), str(shop_item(item_id).get("name", item_id))]
	if daily_substance_users.has(member_id):
		return "%s今天已经使用过一次烟酒。" % FAMILY_NAMES[member_id]
	if int(consumable_uses.get(item_id, 0)) <= 0:
		return "%s已经用完了。" % str(shop_item(item_id).get("name", item_id))
	var uses_per_item := maxi(1, int(rule.get("uses", 1)))
	consumable_uses[item_id] = int(consumable_uses[item_id]) - 1
	_restore_morale(member_id, int(rule.get("morale", 0)), true)
	_adjust_member_stat(member_id, "health", int(rule.get("health", 0)))
	_adjust_member_stat(member_id, "hunger", int(rule.get("hunger", 0)))
	_adjust_member_stat(member_id, "thirst", int(rule.get("thirst", 0)))
	daily_substance_users[member_id] = item_id
	if int(consumable_uses[item_id]) % uses_per_item == 0:
		_consume_item_anywhere(item_id, 1)
	return "%s使用了%s：精神得到缓解，但健康付出了代价。" % [FAMILY_NAMES[member_id], str(shop_item(item_id).get("name", item_id))]


func substance_uses_text(item_id: String) -> String:
	return "剩余%d次" % int(consumable_uses.get(item_id, int(SUBSTANCE_RULES.get(item_id, {}).get("uses", 0))))


func _queue_toilet_visits() -> void:
	if toilet_state in ["clogged", "unusable"]:
		return
	# 父亲是玩家直接控制的角色，需要走到厕所主动使用；其余家人自动排队。
	for member_id in ["partner", "teen", "child", "elder"]:
		if (
			float(toilet_needs.get(member_id, 0.0)) >= 100.0
			and member_id != toilet_occupied_by
			and member_id not in toilet_queue
		):
			toilet_queue.append(member_id)


func update_toilet_automation() -> bool:
	var changed := false
	if not toilet_occupied_by.is_empty() and clock_minutes >= toilet_visit_end_minute:
		npc_activities.erase(toilet_occupied_by)
		toilet_occupied_by = ""
		toilet_visit_end_minute = -1.0
		changed = true
	_queue_toilet_visits()
	if toilet_occupied_by.is_empty() and not toilet_queue.is_empty() and toilet_state not in ["clogged", "unusable"]:
		var member_id := str(toilet_queue.pop_front())
		_begin_toilet_visit(member_id, 2)
		changed = true
	return changed


func use_toilet(member_id: String, floor_number: int = 2) -> String:
	if not toilet_occupied_by.is_empty():
		return "%s正在使用厕所。" % FAMILY_NAMES.get(toilet_occupied_by, "家人")
	if toilet_state in ["clogged", "unusable"]:
		return "厕所当前%s，不能使用。" % toilet_state_label()
	if float(toilet_needs.get(member_id, 0.0)) < 50.0:
		return "%s现在还不需要上厕所。" % FAMILY_NAMES.get(member_id, "该角色")
	_begin_toilet_visit(member_id, floor_number)
	return "%s开始使用厕所，需要15游戏分钟。" % FAMILY_NAMES.get(member_id, "该角色")


func _begin_toilet_visit(member_id: String, floor_number: int) -> void:
	toilet_occupied_by = member_id
	toilet_occupied_floor = clampi(floor_number, 1, 2)
	toilet_visit_end_minute = clock_minutes + 15.0
	npc_activities[member_id] = "toilet"
	toilet_needs[member_id] = maxf(0.0, float(toilet_needs.get(member_id, 0.0)) - 100.0)
	if current_survival_day() >= 6:
		if toilet_tank_liters >= 2.0:
			toilet_tank_liters -= 2.0
		else:
			toilet_unflushed_uses += 1
		_update_toilet_state()


func _update_toilet_state() -> void:
	if toilet_state == "unusable":
		return
	if toilet_unflushed_uses >= 3:
		toilet_state = "clogged"
	elif toilet_unflushed_uses > 0:
		toilet_state = "dirty"
	elif toilet_tank_liters < 2.0 and current_survival_day() >= 6:
		toilet_state = "low_water"
	else:
		toilet_state = "normal"


func toilet_state_label() -> String:
	match toilet_state:
		"low_water":
			return "水箱不足"
		"dirty":
			return "脏污 · 需要4L非饮用水清洁"
		"clogged":
			return "堵塞 · 需要工具箱和6L非饮用水"
		"unusable":
			return "无法使用"
	return "正常"


func refill_toilet_tank() -> String:
	var capacity_left := maxf(0.0, 12.0 - toilet_tank_liters)
	if capacity_left <= 0.001:
		return "马桶水箱已经装满12L。"
	var supplied := _consume_nonpotable_water(capacity_left)
	if supplied <= 0.001:
		return "没有可用于冲厕的非饮用水。"
	toilet_tank_liters += supplied
	_update_toilet_state()
	return "向马桶水箱加入%.1fL非饮用水，目前%.1f/12L。" % [supplied, toilet_tank_liters]


func clean_toilet() -> String:
	if toilet_state != "dirty":
		return "马桶当前不需要普通清洁。"
	if total_raw_water_liters() < 3.999:
		return "清洁需要4L非饮用水，目前不足。"
	_consume_nonpotable_water(4.0)
	toilet_unflushed_uses = 0
	_update_toilet_state()
	return "使用4L非饮用水完成清洁，马桶恢复正常。"


func unclog_toilet() -> String:
	if toilet_state != "clogged":
		return "马桶当前没有堵塞。"
	if not storage_has_any(["basic_toolkit"]):
		return "需要基础工具箱才能疏通。"
	if total_raw_water_liters() < 5.999:
		return "疏通需要6L非饮用水，目前不足。"
	_consume_nonpotable_water(6.0)
	toilet_unflushed_uses = 0
	_update_toilet_state()
	return "使用基础工具箱和6L非饮用水完成疏通。"


func _consume_nonpotable_water(requested: float) -> float:
	var remaining := requested
	for quality in [TAP_RAW_WATER, RAIN_WATER, PRETREATED_RAIN_WATER]:
		if remaining <= 0.001:
			break
		remaining -= consume_water_by_quality(quality, remaining)
	return requested - remaining


func settle_toilet_penalties() -> Array[String]:
	var changes: Array[String] = []
	if toilet_state == "dirty":
		for member_id in FAMILY_ORDER:
			_adjust_member_stat(member_id, "morale", -1)
		changes.append("厕所脏污使全家精神下降")
	for member_id in FAMILY_ORDER:
		var need := float(toilet_needs.get(member_id, 0.0))
		if need >= 150.0:
			_adjust_member_stat(member_id, "morale", -2)
			changes.append("%s因如厕需求积压而精神下降" % FAMILY_NAMES[member_id])
		if need >= 200.0:
			_adjust_member_stat(member_id, "health", -2)
	return changes


func schedule_consequence(consequence_id: String, due_day: int) -> void:
	for raw_entry in pending_consequences:
		if raw_entry is Dictionary and str(raw_entry.get("id", "")) == consequence_id:
			return
	pending_consequences.append({"id": consequence_id, "due_day": due_day})


func _apply_due_consequences() -> void:
	for index in range(pending_consequences.size() - 1, -1, -1):
		var entry: Dictionary = pending_consequences[index]
		if int(entry.get("due_day", 9999)) > survival_day:
			continue
		var consequence_id := str(entry.get("id", ""))
		if consequence_id == "living_window_leak_damage":
			room_function_states["living_room"] = "damp"
			room_function_states["radio"] = "disabled_by_water"
			flags["living_room_damp"] = true
			for member_id in FAMILY_ORDER:
				_adjust_member_stat(member_id, "morale", -2)
			daily_consequences.append("客厅受潮，收音机因附近积水暂时无法使用，全家精神下降")
		pending_consequences.remove_at(index)


func settle_new_survival_rules() -> Dictionary:
	if current_survival_day() == 1 and not has_flag("living_window_sealed"):
		schedule_consequence("living_window_leak_damage", 2)
	var food_changes := age_food_batches()
	if str(room_function_states.get("fridge_power", "normal")) == "tripped":
		food_changes.append("冰箱局部回路未修复，冷藏食物的保质期减少1天")
	var toilet_changes := settle_toilet_penalties()
	var all_changes: Array[String] = []
	all_changes.append_array(daily_consequences)
	all_changes.append_array(food_changes)
	all_changes.append_array(toilet_changes)
	daily_settlement_changes.append_array(food_changes)
	daily_settlement_changes.append_array(toilet_changes)
	return {
		"rationing": daily_ration_summary() if daily_ration_confirmed else "今天没有完成食物和饮水分配",
		"changes": "；".join(all_changes) if not all_changes.is_empty() else "没有额外后果",
		"toilet": "%s · 水箱%.1f/12L" % [toilet_state_label(), toilet_tank_liters],
	}


func survival_summary_rows() -> Array:
	var rows: Array = []
	rows.append({
		"name": "食物与饮水分配",
		"value": daily_ration_summary() if daily_ration_confirmed else "今天没有完成分配",
	})
	rows.append({
		"name": "厕所",
		"value": "%s · 水箱%.1f/12L" % [toilet_state_label(), toilet_tank_liters],
	})
	var discovered_events: Array[String] = []
	for raw_entry in event_log:
		if not (raw_entry is Dictionary):
			continue
		var entry: Dictionary = raw_entry
		if int(entry.get("survival_day", -1)) != current_survival_day():
			continue
		discovered_events.append("%s：%s" % [
			str(entry.get("title", entry.get("event_id", "事件"))),
			str(entry.get("choice_label", entry.get("choice_id", "已处理"))),
		])
	var leak_state: Dictionary = hidden_event_states.get("r1_window_leak", {})
	if (
		current_survival_day() == 1
		and bool(leak_state.get("discovered", false))
		and not completed_events.has("r1_window_leak")
	):
		discovered_events.append("窗沿渗水：已经发现，但没有处理")
	if not discovered_events.is_empty():
		rows.append({"name": "今日已发现事件", "value": "；".join(discovered_events)})
	if not daily_consequences.is_empty():
		rows.append({"name": "昨日选择的回应", "value": "；".join(daily_consequences)})
	if not daily_settlement_changes.is_empty():
		rows.append({"name": "物资与设施变化", "value": "；".join(daily_settlement_changes)})
	return rows


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
	update_toilet_automation()
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
			return "你重新检查了窗框和厨房下水口，也确认配电箱附近没有渗水痕迹。"
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


func begin_rain_day_one() -> void:
	phase_id = "rain_day_1_morning"
	day_label = "暴雨第1天"
	time_label = "上午07:00"
	time_segment = "morning"
	weather_label = "暴雨 · 红色预警"
	flags["rain_day_one_started"] = true
	start_survival_day(1)


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
	update_utilities_for_day(current_survival_day())
	var water_result := _settle_family_needs(nutrition_gain)
	for member_id in FAMILY_ORDER:
		_adjust_member_stat(member_id, "morale", -2)
	var note := "暴雨整夜没停。市政供水和外部电网仍然正常；真正的变化来自今天发现或遗漏的室内问题。"
	last_rain_day_one_summary = {
		"meal": "晚饭使用：%s" % meal_text,
		"water": str(water_result.get("water_text", "供水状态未知")),
		"power": power_state_label(),
		"family": "五人平均：饱腹%d · 水分%d · 精神%d" % [
			average_member_stat("hunger"), average_member_stat("thirst"), average_member_stat("morale")
		],
		"changes": "市政水电正常 · 室内事件按实际状态推进",
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
	update_utilities_for_day(current_survival_day())
	var water_result := _settle_family_needs(nutrition_gain)
	var note := "雨整夜没停。外部水电仍正常；如果冰箱局部回路没有修复，冷藏食物已经开始按断电状态倒计时。"
	last_rain_day_two_summary = {
		"meal": "晚饭使用：%s" % meal_text,
		"water": str(water_result.get("water_text", "供水状态未知")),
		"power": power_state_label(),
		"family": "五人平均：饱腹%d · 水分%d · 精神%d" % [
			average_member_stat("hunger"), average_member_stat("thirst"), average_member_stat("morale")
		],
		"changes": "市政水电正常 · 配电箱局部故障按检查结果结算",
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
	var supply_status := "直饮自来水与市电的最后正常日"
	var note := "第三夜结束。明天外部电网会中断，水龙头仍有水但不再能够直接饮用。"
	last_rain_day_three_summary = {
		"meal": "晚饭使用：%s" % meal_text,
		"water": str(water_result.get("water_text", "供水状态未知")),
		"power": power_state_label(),
		"family": "五人平均：饱腹%d · 水分%d · 精神%d" % [
			average_member_stat("hunger"), average_member_stat("thirst"), average_member_stat("morale")
		],
		"supply": supply_status,
		"note": note,
	}
	flags["rain_day_three_settled"] = true
	last_rain_day_three_summary["audio_hint"] = "持续雨声 · 室内管线声 · 冰箱运转声"
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
	update_utilities_for_day(current_survival_day())
	var water_result := _settle_family_needs(nutrition_gain)
	var move_status := "外部电网中断 · 水龙头输出自来水原水"
	var note := "第四夜结束。冰箱已经停止制冷，生鲜食物开始按各自保质期变化；地图仍保持可操作亮度。"
	last_rain_day_four_summary = {
		"meal": "晚饭使用：%s" % meal_text,
		"water": str(water_result.get("water_text", "供水状态未知")),
		"power": power_state_label(),
		"family": "五人平均：饱腹%d · 水分%d · 精神%d" % [
			average_member_stat("hunger"), average_member_stat("thirst"), average_member_stat("morale")
		],
		"supply": move_status,
		"changes": "停电 · 自来水不可直饮",
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
	update_utilities_for_day(current_survival_day())
	var water_result := _settle_family_needs(nutrition_gain)
	for member_id in FAMILY_ORDER:
		_adjust_member_stat(member_id, "morale", -1)
	var note := "第五夜结束。今天是最后一个还能从水龙头取得自来水原水的日子；明天起只能依靠现有储水和接取的雨水。"
	last_rain_day_five_summary = {
		"meal": "晚饭使用：%s" % meal_text,
		"water": str(water_result.get("water_text", "供水状态未知")),
		"power": power_state_label(),
		"family": "五人平均：饱腹%d · 水分%d · 精神%d" % [
			average_member_stat("hunger"), average_member_stat("thirst"), average_member_stat("morale")
		],
		"changes": "停电持续 · 自来水原水供应最后一天",
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
	update_utilities_for_day(current_survival_day())
	var water_result := _settle_family_needs(nutrition_gain)
	for member_id in FAMILY_ORDER:
		_adjust_member_stat(member_id, "morale", -2)
	var note := "第六夜结束。停水后，直饮水、待净化原水和马桶水箱第一次同时成为需要主动管理的资源。"
	last_rain_day_six_summary = {
		"meal": "晚饭使用：%s" % meal_text,
		"water": str(water_result.get("water_text", "供水状态未知")),
		"power": power_state_label(),
		"family": "五人平均：饱腹%d · 水分%d · 精神%d" % [
			average_member_stat("hunger"), average_member_stat("thirst"), average_member_stat("morale")
		],
		"changes": "彻底停水 · 持续停电 · 厕所开始消耗水箱",
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
	update_utilities_for_day(current_survival_day())
	var water_result := _settle_family_needs(nutrition_gain)
	for member_id in FAMILY_ORDER:
		_adjust_member_stat(member_id, "morale", -2)
	var note := "第七夜结束。第一周的室内生存循环已经完整跑通。"
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
	start_survival_day(safe_day)
	if experiment_start_snapshot.is_empty():
		experiment_start_snapshot = resource_snapshot()


func experiment_weather(day: int) -> String:
	return "暴雨第%d天 · 尚未开放" % day


func settle_experiment_day(day: int) -> Dictionary:
	last_experiment_summary = {
		"day": day,
		"meal": "未开放",
		"water": "未开放",
		"family": "未开放",
		"changes": experiment_change_label(day),
		"audio_hint": experiment_audio_hint(day),
		"note": "暴雨第%d天尚未制作，不结算资源或人物状态。" % day,
	}
	return last_experiment_summary


func experiment_change_label(day: int) -> String:
	return "暴雨第%d天尚未制作" % day


func experiment_audio_hint(day: int) -> String:
	return "未开放"


func resource_snapshot() -> Dictionary:
	return {
		"food": total_food_portions(),
		"water": total_water_reserve_liters(),
		"healthy": average_member_stat("health"),
	}


func experiment_delta_summary() -> String:
	var start := experiment_start_snapshot if not experiment_start_snapshot.is_empty() else resource_snapshot()
	var current := resource_snapshot()
	return "食物 %d→%d份；储备水 %.1f→%.1f升；平均健康 %d→%d。" % [
		int(start.get("food", 0)), int(current.get("food", 0)),
		float(start.get("water", 0.0)), float(current.get("water", 0.0)),
		int(start.get("healthy", 0)), int(current.get("healthy", 0)),
	]


func add_item_to_storage(item_id: String, amount: int = 1, storage_id: String = "pantry") -> void:
	if item_id.is_empty() or amount <= 0 or shop_item(item_id).is_empty():
		return
	if is_food_item(item_id):
		_add_food_batch(item_id, amount, storage_id)
		return
	if item_id == "water_container":
		for _index in range(amount):
			_add_water_container("water_container", 15.0, 0.0, "empty", storage_id, false)
		_sync_water_legacy_storage()
		return
	if item_id == "bottled_water":
		for _index in range(amount):
			_add_water_container("bottled_water", 6.0, 6.0, POTABLE_WATER, storage_id, false)
		_sync_water_legacy_storage()
		return
	if item_id == "empty_bottle":
		for _index in range(amount):
			_add_water_container("empty_bottle", 3.0, 0.0, "empty", storage_id, false)
		_sync_water_legacy_storage()
		return
	var storage := _container_storage(storage_id)
	storage[item_id] = int(storage.get(item_id, 0)) + amount
	_set_container_storage(storage_id, storage)
	if SUBSTANCE_RULES.has(item_id):
		register_consumable_uses(item_id, amount)
	if item_id in ["portable_purifier", "gravity_purifier"]:
		register_purifier(item_id)


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
	if is_food_item(item_id):
		return "食物现在按剩余份数管理，请在中午分配界面选择给谁食用。"
	if item_id in ["water_container", "bottled_water", "empty_bottle"]:
		return "装水容器按实际容量管理，暂时不能放入普通随身背包。"
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
	var storage_id := "pantry"
	if item_id in ["batteries", "power_bank", "basic_medicine", "shotgun", "ammo", "basic_toolkit", "portable_purifier", "gravity_purifier", "portable_filter", "gravity_filter"]:
		storage_id = "bathroom"
	var storage := _container_storage(storage_id)
	storage[item_id] = int(storage.get(item_id, 0)) + 1
	_set_container_storage(storage_id, storage)
	return true


func total_food_portions() -> int:
	_ensure_survival_state()
	var total := 0
	for raw_batch in food_batches:
		if raw_batch is Dictionary:
			total += int(raw_batch.get("servings", 0))
	return total


func total_water_reserve_liters() -> float:
	return total_water_by_quality(POTABLE_WATER)


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
				"toilet_need": roundi(float(toilet_needs.get(member_id, 0.0))),
				"activity": str(npc_activities.get(member_id, "")),
			}
		)
	return entries


func household_status() -> Dictionary:
	return {
		"water": water_state_label(),
		"power": power_state_label(),
		"food": "%d份" % total_food_portions(),
		"water_reserve": "%.1f升" % total_water_reserve_liters(),
		"raw_water": "%.1f升" % total_raw_water_liters(),
		"backup_power": "%d格" % backup_power_units(),
		"bag": "%d/%d格" % [inventory_slots(), personal_capacity],
		"toilet": "%s · %.1f/12L" % [toilet_state_label(), toilet_tank_liters],
		"gas": "正常" if gas_supply_state == "normal" else "不可用",
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
	if daily_ration_confirmed and daily_ration_day == current_survival_day():
		for member_id in FAMILY_ORDER:
			_adjust_member_stat(member_id, "hunger", -20)
			_adjust_member_stat(member_id, "thirst", -25)
			if power_supply_state == "off":
				_adjust_member_stat(member_id, "morale", -2)
			var member_state: Dictionary = family_states[member_id]
			var member_health_loss := 0
			if int(member_state.get("hunger", 100)) < 40:
				member_health_loss += 3
			if int(member_state.get("thirst", 100)) < 40:
				member_health_loss += 5
			if int(member_state.get("thirst", 100)) < 20:
				member_health_loss += 6
			if member_health_loss > 0:
				_adjust_member_stat(member_id, "health", -member_health_loss)
		var survival_result := settle_new_survival_rules()
		var morale_result := settle_morale_penalty()
		return {
			"water_text": "中午已按角色分配直饮水",
			"rationing": str(survival_result.get("rationing", "")),
			"survival_changes": str(survival_result.get("changes", "")),
			"toilet": str(survival_result.get("toilet", "")),
			"morale_penalty": "%d人崩溃" % int(morale_result.get("breakdown", 0)) if int(morale_result.get("breakdown", 0)) > 0 else "",
		}
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
	var morale_penalty := settle_morale_penalty()
	var result: Dictionary = {"water_text": water_text}
	if morale_penalty.breakdown > 0:
		result["morale_penalty"] = "%d人崩溃" % morale_penalty.breakdown
	if morale_penalty.dead > 0:
		result["morale_dead"] = "%d人精神死亡" % morale_penalty.dead
	return result


func _consume_water_reserve(requested_liters: float) -> float:
	return consume_water_by_quality(POTABLE_WATER, requested_liters)


func _consume_item_anywhere(item_id: String, requested: int) -> int:
	if requested <= 0:
		return 0
	if is_food_item(item_id):
		if daily_ration_confirmed:
			return 0
		var servings_per_package := maxi(1, int(food_rule(item_id).get("servings", 1)))
		var available_packages := int(ceil(float(available_food_servings(item_id)) / float(servings_per_package)))
		var consumed_packages := mini(requested, available_packages)
		var servings_to_remove := consumed_packages * servings_per_package
		while servings_to_remove > 0 and available_food_servings(item_id) > 0:
			_consume_food_serving(item_id)
			servings_to_remove -= 1
		return consumed_packages
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
		"player": {"health": 100, "hunger": 100, "thirst": 100, "morale": 100},
		"partner": {"health": 100, "hunger": 100, "thirst": 100, "morale": 100},
		"teen": {"health": 100, "hunger": 100, "thirst": 100, "morale": 100},
		"child": {"health": 100, "hunger": 100, "thirst": 100, "morale": 100},
		"elder": {"health": 100, "hunger": 100, "thirst": 100, "morale": 100},
	}


func _ensure_family_states() -> void:
	if family_states.is_empty():
		family_states = _default_family_states()


func morale_state(member_id: String) -> String:
	_ensure_family_states()
	if not family_states.has(member_id):
		return "normal"
	var morale := int((family_states[member_id] as Dictionary).get("morale", 100))
	if morale < 20:
		return "dead"
	if morale < 40:
		return "breakdown"
	if morale < 60:
		return "sluggish"
	return "normal"


func member_can_act(member_id: String) -> bool:
	var state := morale_state(member_id)
	return state == "normal" or state == "sluggish"


func settle_morale_penalty() -> Dictionary:
	_ensure_family_states()
	var breakdown_count := 0
	var dead_count := 0
	for member_id in FAMILY_ORDER:
		var state := morale_state(member_id)
		if state == "breakdown":
			_adjust_member_stat(member_id, "health", -2)
			breakdown_count += 1
		elif state == "dead":
			dead_count += 1
	return {"breakdown": breakdown_count, "dead": dead_count}


func update_utilities_for_day(day_number: int) -> void:
	if day_number >= 6:
		water_supply_state = "off"
	elif day_number >= 4:
		water_supply_state = "unsafe"
	else:
		water_supply_state = "normal"
	if day_number >= 4:
		power_supply_state = "off"
	else:
		power_supply_state = "normal"
	var faucet_state := "normal"
	if water_supply_state == "unsafe":
		faucet_state = "cloudy"
	elif water_supply_state == "off":
		faucet_state = "off"
	set_environment_state("kitchen_faucet", faucet_state, false)


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
	return SHOP_ITEMS.get(item_id, {})


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
		add_item_to_storage(item_id, 1, "fridge")
	elif item_id in ["batteries", "power_bank", "basic_medicine", "shotgun", "ammo", "basic_toolkit", "portable_purifier", "gravity_purifier", "portable_filter", "gravity_filter"]:
		add_item_to_storage(item_id, 1, "bathroom")
	else:
		add_item_to_storage(item_id, 1, "pantry")


func storage_has_any(item_ids: Array) -> bool:
	for raw_id in item_ids:
		var item_id := str(raw_id)
		# home_storage只保留购物历史；实际可用数量以容器和随身背包为准。
		if item_id in inventory:
			return true
		for storage in [fridge_storage, pantry_storage, utility_storage]:
			if int(storage.get(item_id, 0)) > 0:
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
		"survival_day": survival_day,
		"gas_supply_state": gas_supply_state,
		"food_batches": food_batches,
		"next_food_batch_id": next_food_batch_id,
		"water_containers": water_containers,
		"next_water_container_id": next_water_container_id,
		"purifier_states": purifier_states,
		"daily_purifier_usage": daily_purifier_usage,
		"daily_assignments": daily_assignments,
		"daily_intake_log": daily_intake_log,
		"daily_ration_confirmed": daily_ration_confirmed,
		"daily_ration_day": daily_ration_day,
		"daily_substance_users": daily_substance_users,
		"consumable_uses": consumable_uses,
		"toilet_needs": toilet_needs,
		"toilet_tank_liters": toilet_tank_liters,
		"toilet_unflushed_uses": toilet_unflushed_uses,
		"toilet_state": toilet_state,
		"toilet_occupied_by": toilet_occupied_by,
		"toilet_occupied_floor": toilet_occupied_floor,
		"toilet_visit_end_minute": toilet_visit_end_minute,
		"toilet_queue": toilet_queue,
		"npc_activities": npc_activities,
		"daily_consequences": daily_consequences,
		"daily_settlement_changes": daily_settlement_changes,
		"pending_consequences": pending_consequences,
		"room_function_states": room_function_states,
		"hidden_event_states": hidden_event_states,
		"ending_progress": ending_progress,
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
	survival_day = int(payload.get("survival_day", survival_day))
	gas_supply_state = str(payload.get("gas_supply_state", gas_supply_state))
	food_batches.assign(payload.get("food_batches", []))
	next_food_batch_id = int(payload.get("next_food_batch_id", next_food_batch_id))
	water_containers.assign(payload.get("water_containers", []))
	next_water_container_id = int(payload.get("next_water_container_id", next_water_container_id))
	purifier_states = payload.get("purifier_states", {})
	daily_purifier_usage = payload.get("daily_purifier_usage", {"portable": 0.0, "gravity": 0.0})
	daily_assignments = payload.get("daily_assignments", {})
	daily_intake_log = payload.get("daily_intake_log", {})
	daily_ration_confirmed = bool(payload.get("daily_ration_confirmed", false))
	daily_ration_day = int(payload.get("daily_ration_day", -1))
	daily_substance_users = payload.get("daily_substance_users", {})
	consumable_uses = payload.get("consumable_uses", {})
	toilet_needs = payload.get("toilet_needs", {})
	toilet_tank_liters = float(payload.get("toilet_tank_liters", 12.0))
	toilet_unflushed_uses = int(payload.get("toilet_unflushed_uses", 0))
	toilet_state = str(payload.get("toilet_state", "normal"))
	toilet_occupied_by = str(payload.get("toilet_occupied_by", ""))
	toilet_occupied_floor = int(payload.get("toilet_occupied_floor", 2))
	toilet_visit_end_minute = float(payload.get("toilet_visit_end_minute", -1.0))
	toilet_queue.assign(payload.get("toilet_queue", []))
	npc_activities = payload.get("npc_activities", {})
	daily_consequences.assign(payload.get("daily_consequences", []))
	daily_settlement_changes.assign(payload.get("daily_settlement_changes", []))
	pending_consequences.assign(payload.get("pending_consequences", []))
	room_function_states = payload.get("room_function_states", {})
	hidden_event_states = payload.get("hidden_event_states", {})
	ending_progress = payload.get("ending_progress", {})
	_ensure_survival_state()
	return payload
