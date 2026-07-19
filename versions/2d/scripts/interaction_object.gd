class_name InteractionObject
extends Node2D

var object_id: String = ""
var prompt_text: String = "互动"
var category: String = "inspect"
var display_name: String = ""
var body_color: Color = Color("8899a1")
var highlighted: bool = false
var animation_time: float = 0.0


func configure(
	id_value: String,
	prompt_value: String,
	category_value: String,
	name_value: String,
	color_value: Color = Color("8899a1")
) -> void:
	object_id = id_value
	prompt_text = prompt_value
	category = category_value
	display_name = name_value
	body_color = color_value
	add_to_group("interactables")
	queue_redraw()


func set_highlighted(value: bool) -> void:
	if highlighted == value:
		return
	highlighted = value
	queue_redraw()


func _process(delta: float) -> void:
	animation_time += delta
	if highlighted or category == "npc":
		queue_redraw()


func _draw() -> void:
	if highlighted:
		var pulse := 30.0 + sin(animation_time * 6.0) * 3.0
		draw_circle(Vector2.ZERO, pulse, Color(0.95, 0.75, 0.35, 0.18))
		draw_arc(Vector2.ZERO, pulse, 0.0, TAU, 40, Color(0.98, 0.82, 0.48, 0.82), 2.0)
	if category != "npc":
		return
	var bob := sin(animation_time * 2.2 + position.x * 0.01) * 1.5
	_draw_ellipse_polygon(Vector2(2.0, 15.0), Vector2(14.0, 6.0), Color(0.0, 0.0, 0.0, 0.32))
	draw_rect(Rect2(-10.0, -7.0 + bob, 20.0, 24.0), body_color, true)
	draw_rect(Rect2(-8.0, -20.0 + bob, 16.0, 13.0), Color("e1be98"), true)
	draw_rect(Rect2(-9.0, -21.0 + bob, 18.0, 5.0), Color("303639"), true)
	var font := ThemeDB.fallback_font
	var text_size := font.get_string_size(display_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
	draw_rect(
		Rect2(-text_size.x * 0.5 - 6.0, -44.0, text_size.x + 12.0, 20.0),
		Color(0.04, 0.07, 0.08, 0.84),
		true
	)
	draw_string(
		font,
		Vector2(-text_size.x * 0.5, -29.0),
		display_name,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		13,
		Color("f0f3ef")
	)


func _draw_ellipse_polygon(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(24):
		var angle := TAU * float(index) / 24.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)
