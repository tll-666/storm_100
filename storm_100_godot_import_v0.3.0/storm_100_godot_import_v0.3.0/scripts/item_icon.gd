class_name StormItemIcon
extends Control

var item_id: String = ""
var count: int = 1


func configure(id_value: String, count_value: int = 1) -> void:
	item_id = id_value
	count = maxi(1, count_value)
	custom_minimum_size = Vector2(76.0, 72.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(4, 4, 68, 64), Color("202c32"), true)
	draw_rect(Rect2(4, 4, 68, 64), Color("5d6b70"), false, 2.0)
	match item_id:
		"rice":
			_draw_rice()
		"noodles":
			_draw_noodles()
		"canned_fish":
			_draw_can()
		"vegetables":
			_draw_vegetables()
		"milk":
			_draw_milk()
		"chocolate":
			_draw_chocolate()
		"toilet_paper":
			_draw_toilet_paper()
		"cleaner":
			_draw_cleaner()
		"bottled_water":
			_draw_water()
		"batteries":
			_draw_batteries()
		"power_bank":
			_draw_power_bank()
		"basic_medicine":
			_draw_medicine()
		"meat":
			_draw_meat()
		"eggs":
			_draw_eggs()
		_:
			draw_circle(Vector2(38, 34), 19, Color("78888d"))
	if count > 1:
		draw_circle(Vector2(61, 57), 12, Color("d6a85d"))
		var font := ThemeDB.fallback_font
		var text := str(count)
		var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
		draw_string(font, Vector2(61.0 - width * 0.5, 62.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("172127"))


func _draw_rice() -> void:
	var sack := PackedVector2Array([Vector2(23, 22), Vector2(53, 22), Vector2(58, 57), Vector2(18, 57)])
	draw_colored_polygon(sack, Color("d4b979"))
	draw_line(Vector2(24, 28), Vector2(52, 28), Color("735f3d"), 3.0)
	for x in [28.0, 38.0, 48.0]:
		draw_circle(Vector2(x, 42), 2.0, Color("fff0c3"))


func _draw_noodles() -> void:
	draw_rect(Rect2(20, 17, 36, 43), Color("c95b43"), true)
	draw_rect(Rect2(24, 22, 28, 10), Color("f1d487"), true)
	for y in [39.0, 45.0, 51.0]:
		draw_arc(Vector2(38, y), 10, 0.0, PI, 12, Color("f3d27a"), 2.0)


func _draw_can() -> void:
	draw_rect(Rect2(20, 20, 36, 38), Color("7698a6"), true)
	draw_line(Vector2(20, 24), Vector2(56, 24), Color("d4dddc"), 3.0)
	draw_line(Vector2(20, 54), Vector2(56, 54), Color("4d6168"), 3.0)
	draw_colored_polygon(PackedVector2Array([Vector2(27, 40), Vector2(41, 32), Vector2(50, 40), Vector2(41, 48)]), Color("e5c16d"))
	draw_circle(Vector2(42, 38), 1.5, Color("273035"))


func _draw_vegetables() -> void:
	draw_circle(Vector2(31, 42), 15, Color("5b8d58"))
	draw_circle(Vector2(47, 42), 14, Color("76a763"))
	draw_colored_polygon(PackedVector2Array([Vector2(37, 31), Vector2(28, 17), Vector2(41, 25)]), Color("3f7749"))
	draw_colored_polygon(PackedVector2Array([Vector2(42, 30), Vector2(52, 17), Vector2(50, 31)]), Color("4d8750"))


func _draw_milk() -> void:
	draw_rect(Rect2(23, 23, 31, 37), Color("e9eee8"), true)
	draw_colored_polygon(PackedVector2Array([Vector2(23, 23), Vector2(31, 14), Vector2(50, 14), Vector2(54, 23)]), Color("cbdad8"))
	draw_rect(Rect2(27, 35, 23, 12), Color("6aa0ba"), true)
	draw_circle(Vector2(38, 41), 4, Color("f5fbf7"))


func _draw_chocolate() -> void:
	draw_rect(Rect2(22, 17, 34, 44), Color("70412f"), true)
	for x in [33.0, 45.0]:
		draw_line(Vector2(x, 18), Vector2(x, 60), Color("a2704f"), 2.0)
	for y in [31.0, 46.0]:
		draw_line(Vector2(23, y), Vector2(55, y), Color("a2704f"), 2.0)


func _draw_toilet_paper() -> void:
	draw_rect(Rect2(23, 27, 30, 28), Color("f1eee5"), true)
	_draw_oval_shape(Vector2(24, 41), Vector2(8, 14), Color("d8d6ce"))
	draw_circle(Vector2(24, 41), 4, Color("8d8170"))
	draw_rect(Rect2(42, 50, 17, 10), Color("f4f0e6"), true)


func _draw_cleaner() -> void:
	draw_rect(Rect2(28, 26, 25, 34), Color("68aeb2"), true)
	draw_rect(Rect2(34, 17, 13, 12), Color("d7e4de"), true)
	draw_rect(Rect2(39, 13, 17, 5), Color("d7e4de"), true)
	draw_rect(Rect2(33, 39, 15, 9), Color("f2d78c"), true)


func _draw_water() -> void:
	draw_rect(Rect2(29, 25, 20, 34), Color("76b7c7"), true)
	draw_rect(Rect2(33, 17, 12, 10), Color("b8dce0"), true)
	draw_rect(Rect2(34, 13, 10, 5), Color("6788a1"), true)
	draw_line(Vector2(30, 43), Vector2(48, 43), Color("d5eef0"), 3.0)


func _draw_batteries() -> void:
	for x in [25.0, 43.0]:
		draw_rect(Rect2(x, 22, 13, 37), Color("d0a846"), true)
		draw_rect(Rect2(x + 3, 18, 7, 5), Color("e4ddd0"), true)
		draw_rect(Rect2(x, 47, 13, 12), Color("39444a"), true)


func _draw_power_bank() -> void:
	draw_rect(Rect2(19, 21, 40, 38), Color("4e5e68"), true)
	draw_rect(Rect2(24, 26, 30, 25), Color("26343b"), true)
	for x in [29.0, 35.0, 41.0]:
		draw_circle(Vector2(x, 55), 1.7, Color("85c79a"))
	draw_rect(Rect2(30, 18, 16, 4), Color("9ca9aa"), true)


func _draw_medicine() -> void:
	draw_rect(Rect2(19, 22, 40, 36), Color("e7e8df"), true)
	draw_rect(Rect2(33, 27, 11, 26), Color("c65c56"), true)
	draw_rect(Rect2(26, 34, 25, 11), Color("c65c56"), true)


func _draw_meat() -> void:
	_draw_oval_shape(Vector2(38, 39), Vector2(23, 16), Color("bd685f"))
	draw_circle(Vector2(45, 35), 7, Color("e4b7a3"))
	draw_circle(Vector2(46, 35), 3, Color("f0d8c5"))


func _draw_eggs() -> void:
	_draw_oval_shape(Vector2(29, 41), Vector2(10, 16), Color("e8dfc5"))
	_draw_oval_shape(Vector2(47, 39), Vector2(10, 17), Color("f2e9ce"))


func _draw_oval_shape(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(24):
		var angle := TAU * float(index) / 24.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)
