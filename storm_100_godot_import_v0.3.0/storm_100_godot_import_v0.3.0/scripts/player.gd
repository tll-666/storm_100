class_name StormPlayer
extends CharacterBody2D

@export var move_speed: float = 235.0

var movement_enabled: bool = false
var facing: Vector2 = Vector2.DOWN
var walk_time: float = 0.0


func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	if movement_enabled:
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			direction.x += 1.0
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			direction.x -= 1.0
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
			direction.y += 1.0
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
			direction.y -= 1.0
		direction = direction.normalized()
	velocity = direction * move_speed
	if not direction.is_zero_approx():
		facing = direction
		walk_time += delta * 11.0
	else:
		walk_time = 0.0
	move_and_slide()
	queue_redraw()


func _draw() -> void:
	var bob := sin(walk_time) * 2.0 if walk_time > 0.0 else 0.0
	_draw_ellipse_polygon(Vector2(2.0, 17.0), Vector2(15.0, 7.0), Color(0.0, 0.0, 0.0, 0.34))
	draw_rect(Rect2(-10.0, -6.0 + bob, 20.0, 25.0), Color("e3a65a"), true)
	draw_rect(Rect2(-8.0, -20.0 + bob, 16.0, 14.0), Color("e4c29e"), true)
	draw_rect(Rect2(-9.0, -21.0 + bob, 18.0, 5.0), Color("273035"), true)
	var step := sin(walk_time) * 3.0 if walk_time > 0.0 else 0.0
	draw_rect(Rect2(-9.0, 18.0 + bob, 7.0, 9.0 + maxf(step, 0.0)), Color("2d373b"), true)
	draw_rect(Rect2(2.0, 18.0 + bob, 7.0, 9.0 + maxf(-step, 0.0)), Color("2d373b"), true)
	var eye_offset := facing.normalized() * 2.0
	draw_circle(Vector2(-4.0, -13.0) + eye_offset + Vector2(0.0, bob), 1.4, Color("20272a"))
	draw_circle(Vector2(4.0, -13.0) + eye_offset + Vector2(0.0, bob), 1.4, Color("20272a"))


func _draw_ellipse_polygon(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(24):
		var angle := TAU * float(index) / 24.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)
