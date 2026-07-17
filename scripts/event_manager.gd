extends Node

const DATABASE_DIR := "res://data/events"

var database_version: int = 0
var events_by_id: Dictionary = {}
var validation_errors: Array[String] = []


func _ready() -> void:
	load_database()


func load_database() -> bool:
	events_by_id.clear()
	validation_errors.clear()
	var dir := DirAccess.open(DATABASE_DIR)
	if dir == null:
		validation_errors.append("无法打开事件数据库目录：%s" % DATABASE_DIR)
		return false
	var file_paths: Array[String] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			file_paths.append("%s/%s" % [DATABASE_DIR, file_name])
		file_name = dir.get_next()
	dir.list_dir_end()
	file_paths.sort()
	if file_paths.is_empty():
		validation_errors.append("事件数据库目录中没有JSON文件：%s" % DATABASE_DIR)
		return false
	for path in file_paths:
		_load_single_file(path)
	_validate_references()
	return validation_errors.is_empty()


func _load_single_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		validation_errors.append("无法打开事件数据库：%s" % path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		validation_errors.append("事件数据库不是有效的JSON对象：%s" % path)
		return
	var root_data: Dictionary = parsed
	var file_version := int(root_data.get("version", 0))
	if file_version > database_version:
		database_version = file_version
	var raw_events: Array = root_data.get("events", [])
	for raw_event in raw_events:
		if not (raw_event is Dictionary):
			validation_errors.append("事件列表中存在非对象数据：%s" % path)
			continue
		var event_data: Dictionary = raw_event
		var event_id := str(event_data.get("id", ""))
		if event_id.is_empty():
			validation_errors.append("存在没有ID的事件：%s" % path)
			continue
		if events_by_id.has(event_id):
			validation_errors.append("事件ID重复：%s" % event_id)
			continue
		if not event_data.has("title") or not event_data.has("choices"):
			validation_errors.append("事件缺少标题或选项：%s" % event_id)
			continue
		events_by_id[event_id] = event_data


func _validate_references() -> void:
	for raw_id in events_by_id:
		var event_data: Dictionary = events_by_id[raw_id]
		var choices: Array = event_data.get("choices", [])
		if choices.is_empty():
			validation_errors.append("事件没有任何选项：%s" % str(raw_id))
		for raw_choice in choices:
			if not (raw_choice is Dictionary):
				validation_errors.append("事件选项格式错误：%s" % str(raw_id))
				continue
			var choice: Dictionary = raw_choice
			if str(choice.get("id", "")).is_empty() or str(choice.get("label", "")).is_empty():
				validation_errors.append("事件选项缺少ID或文字：%s" % str(raw_id))
			for raw_effect in choice.get("effects", []):
				if not (raw_effect is Dictionary):
					continue
				var effect: Dictionary = raw_effect
				if str(effect.get("type", "")) == "schedule_event":
					var target_id := str(effect.get("event_id", ""))
					if not events_by_id.has(target_id):
						validation_errors.append("事件%s安排了不存在的事件%s" % [str(raw_id), target_id])


func all_events() -> Array:
	var result: Array = []
	for event_id in events_by_id:
		result.append(events_by_id[event_id])
	result.sort_custom(
		func(left: Dictionary, right: Dictionary) -> bool:
			var left_key := "%s/%s/%s" % [str(left.get("day", "")), str(left.get("phase", "")), str(left.get("id", ""))]
			var right_key := "%s/%s/%s" % [str(right.get("day", "")), str(right.get("phase", "")), str(right.get("id", ""))]
			return left_key < right_key
	)
	return result


func event_data(event_id: String) -> Dictionary:
	return events_by_id.get(event_id, {})


func is_available(event_id: String, ignore_completion: bool = false) -> bool:
	var data := event_data(event_id)
	if data.is_empty():
		return false
	if not ignore_completion and bool(data.get("once", true)) and GameState.completed_events.has(event_id):
		return false
	return _conditions_met(data.get("conditions", {}))


func _conditions_met(raw_conditions: Variant) -> bool:
	if not (raw_conditions is Dictionary):
		return true
	var conditions: Dictionary = raw_conditions
	var required_phase := str(conditions.get("phase", ""))
	if not required_phase.is_empty() and GameState.phase_id != required_phase:
		return false
	for flag_id in conditions.get("required_flags", []):
		if not GameState.has_flag(str(flag_id)):
			return false
	for flag_id in conditions.get("excluded_flags", []):
		if GameState.has_flag(str(flag_id)):
			return false
	for clue_id in conditions.get("required_clues", []):
		if not GameState.clues.has(str(clue_id)):
			return false
	if int(conditions.get("min_clues", 0)) > GameState.clues.size():
		return false
	for item_id in conditions.get("required_items", []):
		if not GameState.storage_has_any([str(item_id)]):
			return false
	return true


func resolved_text(event_id: String) -> String:
	var data := event_data(event_id)
	if data.is_empty():
		return ""
	var variants: Array = data.get("text_variants", [])
	for raw_variant in variants:
		if not (raw_variant is Dictionary):
			continue
		var variant: Dictionary = raw_variant
		var conditions := {
			"required_flags": variant.get("required_flags", []),
			"required_items": variant.get("required_items", []),
			"required_clues": variant.get("required_clues", []),
		}
		if _conditions_met(conditions):
			return str(variant.get("text", data.get("text", "")))
	return str(data.get("text", ""))


func choice_labels(event_id: String) -> Array[String]:
	var labels: Array[String] = []
	for raw_choice in event_data(event_id).get("choices", []):
		var choice: Dictionary = raw_choice
		labels.append(str(choice.get("label", "继续")))
	return labels


func apply_choice(event_id: String, choice_index: int, force: bool = false) -> Dictionary:
	var data := event_data(event_id)
	if data.is_empty():
		return {"ok": false, "error": "事件不存在。"}
	if not force and not is_available(event_id):
		return {"ok": false, "error": "事件条件不满足或已经完成。"}
	var choices: Array = data.get("choices", [])
	if choices.is_empty():
		return {"ok": false, "error": "事件没有选项。"}
	var safe_index := clampi(choice_index, 0, choices.size() - 1)
	var choice: Dictionary = choices[safe_index]
	for raw_effect in choice.get("effects", []):
		if raw_effect is Dictionary:
			_apply_effect(raw_effect)
	GameState.completed_events[event_id] = true
	GameState.event_choices[event_id] = str(choice.get("id", safe_index))
	GameState.event_log.append(
		{
			"event_id": event_id,
			"choice_id": str(choice.get("id", safe_index)),
			"phase": GameState.phase_id,
		}
	)
	GameState.remove_scheduled_event(event_id)
	return {
		"ok": true,
		"event_id": event_id,
		"choice_id": str(choice.get("id", safe_index)),
		"result": str(choice.get("result", "")),
		"merge": str(data.get("merge", "")),
	}


func _apply_effect(effect: Dictionary) -> void:
	match str(effect.get("type", "")):
		"set_flag":
			GameState.flags[str(effect.get("id", ""))] = true
		"clear_flag":
			GameState.flags.erase(str(effect.get("id", "")))
		"add_clue":
			GameState.clues[str(effect.get("id", ""))] = true
		"set_phase":
			GameState.phase_id = str(effect.get("value", GameState.phase_id))
		"set_time":
			GameState.time_label = str(effect.get("label", GameState.time_label))
			GameState.time_segment = str(effect.get("segment", GameState.time_segment))
		"set_weather":
			GameState.weather_label = str(effect.get("value", GameState.weather_label))
		"relationship":
			var member_id := str(effect.get("member", ""))
			if GameState.relationships.has(member_id):
				GameState.relationships[member_id] = int(GameState.relationships[member_id]) + int(effect.get("amount", 0))
		"member_stat":
			GameState.adjust_member_stat(
				str(effect.get("member", "")), str(effect.get("stat", "")), int(effect.get("amount", 0))
			)
		"add_water":
			GameState.loose_water_liters += float(effect.get("amount", 0.0))
		"add_backup_power":
			GameState.prepared_power_units += int(effect.get("amount", 0))
		"set_preparation":
			GameState.day_two_preparation = str(effect.get("value", ""))
		"schedule_event":
			GameState.schedule_event(
				str(effect.get("event_id", "")), str(effect.get("trigger_phase", ""))
			)


func scheduled_event_for_phase(phase_id: String) -> String:
	for raw_entry in GameState.scheduled_events:
		if not (raw_entry is Dictionary):
			continue
		var entry: Dictionary = raw_entry
		var event_id := str(entry.get("event_id", ""))
		if str(entry.get("trigger_phase", "")) == phase_id and is_available(event_id):
			return event_id
	return ""


func debug_reset_event(event_id: String) -> void:
	GameState.completed_events.erase(event_id)
	GameState.event_choices.erase(event_id)


func debug_entries() -> Array:
	var entries: Array = []
	for raw_event in all_events():
		var data: Dictionary = raw_event
		var event_id := str(data.get("id", ""))
		var choice_entries: Array = []
		for raw_choice in data.get("choices", []):
			var choice: Dictionary = raw_choice
			choice_entries.append(
				{
					"label": str(choice.get("label", "")),
					"result": str(choice.get("result", "")),
					"effects": _effects_summary(choice.get("effects", [])),
				}
			)
		entries.append(
			{
				"id": event_id,
				"title": str(data.get("title", event_id)),
				"day": str(data.get("day", "")),
				"phase": str(data.get("phase", "")),
				"type": str(data.get("type", "")),
				"location": str(data.get("location", "")),
				"status": _debug_status(event_id),
				"conditions": _conditions_summary(data.get("conditions", {})),
				"clues": "；".join(PackedStringArray(data.get("clues", []))),
				"text": str(data.get("text", "")),
				"choices": choice_entries,
				"merge": str(data.get("merge", "")),
			}
		)
	return entries


func _debug_status(event_id: String) -> String:
	if GameState.completed_events.has(event_id):
		return "已完成 · 选择%s" % str(GameState.event_choices.get(event_id, ""))
	if is_available(event_id):
		return "当前可触发"
	return "条件未满足"


func _conditions_summary(raw_conditions: Variant) -> String:
	if not (raw_conditions is Dictionary):
		return "无"
	var conditions: Dictionary = raw_conditions
	var parts: Array[String] = []
	if not str(conditions.get("phase", "")).is_empty():
		parts.append("阶段=%s" % str(conditions.get("phase")))
	if not conditions.get("required_flags", []).is_empty():
		parts.append("标记=%s" % "、".join(PackedStringArray(conditions.get("required_flags", []))))
	if not conditions.get("required_items", []).is_empty():
		parts.append("物品=%s" % "、".join(PackedStringArray(conditions.get("required_items", []))))
	if int(conditions.get("min_clues", 0)) > 0:
		parts.append("至少%d条线索" % int(conditions.get("min_clues")))
	return "；".join(parts) if not parts.is_empty() else "无"


func _effects_summary(raw_effects: Variant) -> String:
	if not (raw_effects is Array):
		return "无"
	var parts: Array[String] = []
	for raw_effect in raw_effects:
		if not (raw_effect is Dictionary):
			continue
		var effect: Dictionary = raw_effect
		match str(effect.get("type", "")):
			"set_flag": parts.append("设置标记:%s" % str(effect.get("id", "")))
			"add_clue": parts.append("获得线索:%s" % str(effect.get("id", "")))
			"set_phase": parts.append("阶段→%s" % str(effect.get("value", "")))
			"set_time": parts.append("时间→%s" % str(effect.get("label", "")))
			"set_preparation": parts.append("准备方向:%s" % str(effect.get("value", "")))
			"add_water": parts.append("储水+%.1f升" % float(effect.get("amount", 0.0)))
			"add_backup_power": parts.append("备用电力+%d格" % int(effect.get("amount", 0)))
			"relationship": parts.append("%s信任%+d" % [str(effect.get("member", "")), int(effect.get("amount", 0))])
			"member_stat": parts.append("%s的%s%+d" % [str(effect.get("member", "")), str(effect.get("stat", "")), int(effect.get("amount", 0))])
			"schedule_event": parts.append("安排:%s" % str(effect.get("event_id", "")))
	return "；".join(parts) if not parts.is_empty() else "无"
