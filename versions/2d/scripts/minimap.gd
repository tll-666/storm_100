class_name HouseMiniMap
extends Control

var floor_number: int = 1
var active_room_id: String = ""
var rooms: Array = []


func configure(new_floor: int, new_active_room_id: String, new_rooms: Array) -> void:
	floor_number = new_floor
	active_room_id = new_active_room_id
	rooms = new_rooms
	queue_redraw()


func _draw() -> void:
	if rooms.is_empty():
		return
	var bounds := _room_bounds()
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return
	var padding := 9.0
	var available := size - Vector2(padding * 2.0, padding * 2.0)
	var scale_value := minf(available.x / bounds.size.x, available.y / bounds.size.y)
	var drawn_size := bounds.size * scale_value
	var offset := (size - drawn_size) * 0.5 - bounds.position * scale_value
	for raw_room in rooms:
		if not (raw_room is Dictionary):
			continue
		var room: Dictionary = raw_room
		var source_rect: Rect2 = room.get("rect", Rect2())
		var rect := Rect2(source_rect.position * scale_value + offset, source_rect.size * scale_value)
		var room_id := str(room.get("id", ""))
		var explored := bool(room.get("explored", false))
		var fill := Color(0.08, 0.11, 0.13, 0.86) if explored else Color(0.025, 0.035, 0.045, 0.94)
		var border := Color(0.38, 0.46, 0.49, 0.8) if explored else Color(0.20, 0.25, 0.28, 0.75)
		if room_id == active_room_id:
			fill = Color(0.36, 0.27, 0.13, 0.95)
			border = Color("efc46f")
		draw_rect(rect, fill, true)
		draw_rect(rect, border, false, 2.0 if room_id == active_room_id else 1.0)
		if explored and rect.size.x >= 36.0 and rect.size.y >= 24.0:
			var label := str(room.get("short_label", room.get("label", "")))
			var font := ThemeDB.fallback_font
			var font_size := 10
			var label_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
			if label_size.x < rect.size.x - 4.0:
				draw_string(
					font,
					Vector2(rect.get_center().x - label_size.x * 0.5, rect.get_center().y + 4.0),
					label,
					HORIZONTAL_ALIGNMENT_LEFT,
					-1,
					font_size,
					Color("d7dfdc")
				)


func _room_bounds() -> Rect2:
	var result := Rect2()
	var initialized := false
	for raw_room in rooms:
		if not (raw_room is Dictionary):
			continue
		var rect: Rect2 = raw_room.get("rect", Rect2())
		if not initialized:
			result = rect
			initialized = true
		else:
			result = result.merge(rect)
	return result
