class_name StormFirstPersonController
extends CharacterBody3D

@export var walk_speed: float = 4.2
@export var sprint_speed: float = 6.2
@export var acceleration: float = 16.0
@export var mouse_sensitivity: float = 0.0022
@export var jump_velocity: float = 4.3

@onready var head: Node3D = $Head
@onready var flashlight: SpotLight3D = $Head/Camera3D/Flashlight

var gravity: float = 9.8


func _ready() -> void:
	gravity = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clampf(head.rotation.x, deg_to_rad(-82.0), deg_to_rad(82.0))
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event.keycode == KEY_F:
			flashlight.visible = not flashlight.visible


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_physical_key_pressed(KEY_SPACE):
		velocity.y = jump_velocity

	var input_vector := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A):
		input_vector.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		input_vector.x += 1.0
	if Input.is_physical_key_pressed(KEY_W):
		input_vector.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		input_vector.y += 1.0
	input_vector = input_vector.normalized()

	var desired_direction := (transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()
	var speed := sprint_speed if Input.is_physical_key_pressed(KEY_SHIFT) else walk_speed
	var target_x := desired_direction.x * speed
	var target_z := desired_direction.z * speed
	velocity.x = move_toward(velocity.x, target_x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_z, acceleration * delta)
	move_and_slide()

