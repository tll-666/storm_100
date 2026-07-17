extends Node

const SAVE_PATH := "user://storm_100_checkpoint.json"

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
	return payload
