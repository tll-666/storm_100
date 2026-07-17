class_name HouseWorld
extends Node2D

const WORLD_SIZE := Vector2(1600.0, 1100.0)
const WALL_COLOR := Color("46545b")
const WALL_TOP_COLOR := Color("7e8a8f")

var current_floor: int = 1
var animation_time: float = 0.0
var collision_root: Node2D
var interaction_root: Node2D
var active_interactable: InteractionObject


func _ready() -> void:
	y_sort_enabled = true
	collision_root = Node2D.new()
	collision_root.name = "GeneratedCollisions"
	add_child(collision_root)
	interaction_root = Node2D.new()
	interaction_root.name = "GeneratedInteractions"
	interaction_root.y_sort_enabled = true
	add_child(interaction_root)


func build_floor(floor_number: int) -> void:
	current_floor = floor_number
	for child in collision_root.get_children():
		child.free()
	for child in interaction_root.get_children():
		child.free()
	for wall in _walls_for_floor(current_floor):
		_add_collision_rect(wall)
	for furniture in _furniture_for_floor(current_floor):
		if bool(furniture.get("solid", true)):
			_add_collision_rect(furniture.rect)
	for definition in _interactions_for_floor(current_floor):
		_add_interaction(definition)
	active_interactable = null
	queue_redraw()


func get_nearest_interactable(origin: Vector2, maximum_distance: float = 92.0) -> InteractionObject:
	var nearest: InteractionObject = null
	var nearest_distance := maximum_distance
	for child in interaction_root.get_children():
		if not child is InteractionObject:
			continue
		var candidate: InteractionObject = child
		var distance := origin.distance_to(candidate.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = candidate
	if active_interactable != nearest:
		if active_interactable != null and is_instance_valid(active_interactable):
			active_interactable.set_highlighted(false)
		active_interactable = nearest
		if active_interactable != null:
			active_interactable.set_highlighted(true)
	return nearest


func spawn_position(floor_number: int) -> Vector2:
	if floor_number == 2:
		return Vector2(1000.0, 690.0)
	return Vector2(790.0, 735.0)


func _process(delta: float) -> void:
	animation_time += delta
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("172127"), true)
	if current_floor == 1:
		_draw_ground_exterior()
	else:
		_draw_second_floor_exterior()
	for room in _rooms_for_floor(current_floor):
		_draw_room(room)
	for wall in _walls_for_floor(current_floor):
		_draw_wall(wall)
	for furniture in _furniture_for_floor(current_floor):
		_draw_furniture(furniture)
	_draw_floor_details()


func _draw_ground_exterior() -> void:
	draw_rect(Rect2(0.0, 860.0, 1600.0, 120.0), Color("405049"), true)
	draw_rect(Rect2(0.0, 980.0, 1600.0, 120.0), Color("343e43"), true)
	draw_rect(Rect2(0.0, 970.0, 1600.0, 10.0), Color("9a9787"), true)
	for x in range(30, 1600, 180):
		draw_rect(Rect2(float(x), 1035.0, 94.0, 6.0), Color(0.82, 0.78, 0.58, 0.72), true)
	draw_rect(Rect2(170.0, 860.0, 330.0, 120.0), Color("596159"), true)
	draw_rect(Rect2(500.0, 860.0, 930.0, 120.0), Color("526650"), true)
	draw_rect(Rect2(250.0, 860.0, 205.0, 120.0), Color("6d716b"), true)
	for index in range(7):
		var x := 535.0 + float(index) * 126.0
		var sway := sin(animation_time * 1.4 + float(index)) * 3.0
		draw_line(Vector2(x, 920.0), Vector2(x + sway, 886.0), Color("334b37"), 5.0)
		draw_circle(Vector2(x + sway, 880.0), 15.0, Color("3f6748"))
	var font := ThemeDB.fallback_font
	draw_string(
		font,
		Vector2(32.0, 1016.0),
		"城市边缘 · 住宅街",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color("cbd5d3")
	)
	draw_string(
		font, Vector2(1190.0, 1016.0), "排水河方向 →", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("aebdc1")
	)


func _draw_second_floor_exterior() -> void:
	draw_rect(Rect2(0.0, 860.0, 1600.0, 240.0), Color("253239"), true)
	draw_rect(Rect2(0.0, 970.0, 1600.0, 130.0), Color("2f393e"), true)
	for x in range(20, 1600, 170):
		draw_rect(Rect2(float(x), 1038.0, 90.0, 5.0), Color(0.78, 0.76, 0.58, 0.45), true)


func _draw_floor_details() -> void:
	var font := ThemeDB.fallback_font
	if current_floor == 1:
		draw_string(
			font, Vector2(1110.0, 935.0), "前院", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("d6dfd3")
		)
		draw_string(
			font, Vector2(290.0, 935.0), "车道", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("d6dfd3")
		)
	else:
		for x in range(200, 490, 34):
			draw_line(Vector2(float(x), 520.0), Vector2(float(x), 560.0), Color("c3cdca"), 4.0)
		draw_line(Vector2(190.0, 520.0), Vector2(490.0, 520.0), Color("c3cdca"), 4.0)


func _draw_room(room: Dictionary) -> void:
	var rect: Rect2 = room.rect
	draw_rect(rect, room.color, true)
	for y in range(int(rect.position.y + 18.0), int(rect.end.y), 30):
		draw_line(
			Vector2(rect.position.x, float(y)),
			Vector2(rect.end.x, float(y)),
			Color(0.0, 0.0, 0.0, 0.055),
			1.0
		)
	var font := ThemeDB.fallback_font
	draw_string(
		font,
		rect.position + Vector2(16.0, 28.0),
		str(room.label),
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color(0.08, 0.12, 0.14, 0.72)
	)


func _draw_wall(rect: Rect2) -> void:
	draw_rect(rect, WALL_COLOR, true)
	draw_rect(
		Rect2(rect.position, Vector2(rect.size.x, minf(rect.size.y, 4.0))), WALL_TOP_COLOR, true
	)


func _draw_furniture(item: Dictionary) -> void:
	var rect: Rect2 = item.rect
	draw_rect(Rect2(rect.position + Vector2(5.0, 6.0), rect.size), Color(0.0, 0.0, 0.0, 0.22), true)
	draw_rect(rect, item.color, true)
	draw_rect(rect, Color(1.0, 1.0, 1.0, 0.16), false, 1.0)
	var font := ThemeDB.fallback_font
	var label := str(item.get("label", ""))
	if not label.is_empty() and rect.size.x >= 52.0:
		var label_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
		var text_position := (
			rect.position
			+ Vector2(maxf(4.0, (rect.size.x - label_size.x) * 0.5), rect.size.y * 0.5 + 5.0)
		)
		draw_string(
			font,
			text_position,
			label,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			12,
			Color(0.06, 0.09, 0.10, 0.82)
		)


func _add_collision_rect(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 1
	body.position = rect.position + rect.size * 0.5
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	body.add_child(collision)
	collision_root.add_child(body)


func _add_interaction(definition: Dictionary) -> void:
	var object := InteractionObject.new()
	object.position = definition.position
	interaction_root.add_child(object)
	object.configure(
		str(definition.id),
		str(definition.prompt),
		str(definition.category),
		str(definition.get("name", "")),
		definition.get("color", Color("8899a1"))
	)


func _rooms_for_floor(floor_number: int) -> Array:
	if floor_number == 2:
		return [
			{"rect": Rect2(180, 500, 320, 350), "label": "二楼公共阳台", "color": Color("71877c")},
			{"rect": Rect2(500, 100, 350, 300), "label": "主卧", "color": Color("a2838c")},
			{"rect": Rect2(850, 100, 270, 300), "label": "大孩子房", "color": Color("7e8eaf")},
			{"rect": Rect2(1120, 100, 300, 220), "label": "二楼厕所", "color": Color("84a8aa")},
			{"rect": Rect2(1120, 320, 300, 330), "label": "小孩子房", "color": Color("b09769")},
			{"rect": Rect2(500, 400, 620, 450), "label": "楼梯平台 / 家庭活动区", "color": Color("aa9a7d")},
			{"rect": Rect2(1120, 650, 300, 200), "label": "储物角", "color": Color("8f8775")},
		]
	return [
		{"rect": Rect2(180, 500, 320, 350), "label": "车库 · 地面较低", "color": Color("717b7d")},
		{"rect": Rect2(500, 100, 400, 240), "label": "厨房 / 食品柜", "color": Color("8ca093")},
		{"rect": Rect2(900, 100, 220, 240), "label": "厕所 / 洗衣", "color": Color("86aaac")},
		{"rect": Rect2(1120, 100, 300, 240), "label": "后侧储物", "color": Color("938b78")},
		{"rect": Rect2(500, 340, 400, 310), "label": "客厅 / 餐厅", "color": Color("b7946c")},
		{"rect": Rect2(900, 340, 220, 310), "label": "楼梯间", "color": Color("aa9b80")},
		{"rect": Rect2(500, 650, 250, 200), "label": "玄关", "color": Color("9a8872")},
		{"rect": Rect2(750, 650, 370, 200), "label": "过道", "color": Color("ae9f84")},
		{"rect": Rect2(1120, 340, 300, 510), "label": "老人卧室", "color": Color("9d8388")},
	]


func _walls_for_floor(floor_number: int) -> Array[Rect2]:
	if floor_number == 2:
		return [
			Rect2(500, 90, 930, 16),
			Rect2(1414, 90, 16, 770),
			Rect2(500, 844, 930, 16),
			Rect2(500, 90, 16, 500),
			Rect2(500, 700, 16, 160),
			Rect2(170, 490, 330, 16),
			Rect2(170, 844, 330, 16),
			Rect2(170, 490, 16, 370),
			Rect2(500, 490, 16, 100),
			Rect2(500, 700, 16, 160),
			Rect2(850, 90, 16, 220),
			Rect2(850, 360, 16, 40),
			Rect2(1120, 90, 16, 145),
			Rect2(1120, 285, 16, 190),
			Rect2(1120, 535, 16, 325),
			Rect2(500, 400, 130, 16),
			Rect2(700, 400, 210, 16),
			Rect2(980, 400, 140, 16),
			Rect2(1120, 320, 115, 16),
			Rect2(1300, 320, 130, 16),
			Rect2(1120, 650, 115, 16),
			Rect2(1300, 650, 130, 16),
		]
	return [
		Rect2(500, 90, 930, 16),
		Rect2(1414, 90, 16, 770),
		Rect2(500, 844, 60, 16),
		Rect2(625, 844, 805, 16),
		Rect2(500, 90, 16, 400),
		Rect2(170, 490, 330, 16),
		Rect2(170, 844, 50, 16),
		Rect2(450, 844, 50, 16),
		Rect2(170, 490, 16, 370),
		Rect2(500, 490, 16, 130),
		Rect2(500, 700, 16, 160),
		Rect2(900, 90, 16, 240),
		Rect2(1120, 90, 16, 240),
		Rect2(500, 330, 180, 16),
		Rect2(750, 330, 210, 16),
		Rect2(1040, 330, 140, 16),
		Rect2(1250, 330, 180, 16),
		Rect2(1120, 330, 16, 160),
		Rect2(1120, 580, 16, 280),
		Rect2(500, 650, 200, 16),
		Rect2(780, 650, 200, 16),
		Rect2(1040, 650, 80, 16),
	]


func _furniture_for_floor(floor_number: int) -> Array:
	if floor_number == 2:
		return [
			{"rect": Rect2(555, 145, 170, 92), "label": "双人床", "color": Color("775f69")},
			{"rect": Rect2(745, 145, 65, 58), "label": "衣柜", "color": Color("66564f")},
			{"rect": Rect2(890, 145, 125, 72), "label": "床", "color": Color("66769b")},
			{"rect": Rect2(960, 270, 125, 55), "label": "书桌", "color": Color("655a49")},
			{"rect": Rect2(1160, 140, 58, 55), "label": "马桶", "color": Color("e4e9e4")},
			{"rect": Rect2(1280, 140, 100, 55), "label": "洗手台", "color": Color("cfd8d5")},
			{"rect": Rect2(1170, 375, 125, 74), "label": "床", "color": Color("947c58")},
			{"rect": Rect2(1305, 430, 82, 60), "label": "玩具柜", "color": Color("73613f")},
			{"rect": Rect2(1185, 555, 115, 50), "label": "小书桌", "color": Color("796c55")},
			{"rect": Rect2(695, 510, 155, 68), "label": "旧沙发", "color": Color("76604c")},
			{
				"rect": Rect2(240, 630, 65, 55),
				"label": "水桶",
				"color": Color("4e909b"),
				"solid": false
			},
			{
				"rect": Rect2(390, 690, 65, 55),
				"label": "排水口",
				"color": Color("52675d"),
				"solid": false
			},
		]
	return [
		{"rect": Rect2(235, 565, 205, 112), "label": "汽车", "color": Color("445158")},
		{"rect": Rect2(205, 745, 135, 55), "label": "工具架", "color": Color("5c6669")},
		{"rect": Rect2(390, 760, 62, 52), "label": "排水口", "color": Color("4c5c60"), "solid": false},
		{"rect": Rect2(535, 135, 70, 92), "label": "冰箱", "color": Color("d2d9d5")},
		{"rect": Rect2(655, 135, 130, 55), "label": "灶台", "color": Color("546d61")},
		{"rect": Rect2(800, 135, 68, 55), "label": "水槽", "color": Color("7e9088")},
		{"rect": Rect2(775, 245, 95, 55), "label": "食品柜", "color": Color("7d705c")},
		{"rect": Rect2(930, 135, 58, 55), "label": "马桶", "color": Color("e5e9e3")},
		{"rect": Rect2(1025, 135, 65, 65), "label": "洗衣机", "color": Color("d2dad6")},
		{"rect": Rect2(950, 250, 130, 50), "label": "洗手台", "color": Color("ced6d2")},
		{"rect": Rect2(550, 405, 155, 68), "label": "沙发", "color": Color("745c49")},
		{"rect": Rect2(750, 495, 145, 78), "label": "餐桌", "color": Color("76563d")},
		{"rect": Rect2(805, 385, 65, 45), "label": "收音机", "color": Color("5d5148"), "solid": false},
		{"rect": Rect2(1180, 405, 145, 86), "label": "床", "color": Color("756168")},
		{"rect": Rect2(1330, 405, 58, 75), "label": "衣柜", "color": Color("67564c")},
		{"rect": Rect2(1215, 690, 150, 56), "label": "矮柜", "color": Color("705e4f")},
		{"rect": Rect2(530, 715, 120, 48), "label": "鞋柜", "color": Color("715b47")},
		{
			"rect": Rect2(1000, 720, 75, 50),
			"label": "配电箱",
			"color": Color("505b61"),
			"solid": false
		},
	]


func _interactions_for_floor(floor_number: int) -> Array:
	if floor_number == 2:
		return [
			{
				"id": "teen",
				"position": Vector2(940, 245),
				"prompt": "和大孩子聊聊",
				"category": "npc",
				"name": "大孩子",
				"color": Color("7087c5")
			},
			{
				"id": "child",
				"position": Vector2(1260, 520),
				"prompt": "和小孩子聊聊",
				"category": "npc",
				"name": "小孩子",
				"color": Color("d1a15e")
			},
			{
				"id": "stairs_down",
				"position": Vector2(1010, 620),
				"prompt": "下一楼",
				"category": "stairs",
				"name": "楼梯"
			},
			{
				"id": "balcony_drain",
				"position": Vector2(420, 720),
				"prompt": "检查阳台排水口",
				"category": "inspect",
				"name": "排水口"
			},
			{
				"id": "balcony_view",
				"position": Vector2(280, 555),
				"prompt": "从阳台观察街道",
				"category": "inspect",
				"name": "街道"
			},
			{
				"id": "teen_desk",
				"position": Vector2(1020, 340),
				"prompt": "检查充电设备",
				"category": "inspect",
				"name": "书桌"
			},
			{
				"id": "child_toys",
				"position": Vector2(1340, 520),
				"prompt": "检查玩具柜",
				"category": "inspect",
				"name": "玩具柜"
			},
		]
	return [
		{
			"id": "partner",
			"position": Vector2(705, 430),
			"prompt": "和伴侣聊聊",
			"category": "npc",
			"name": "伴侣",
			"color": Color("cc716b")
		},
		{
			"id": "elder",
			"position": Vector2(1260, 585),
			"prompt": "和老人聊聊",
			"category": "npc",
			"name": "老人",
			"color": Color("929c86")
		},
		{
			"id": "stairs_up",
			"position": Vector2(1010, 570),
			"prompt": "上二楼",
			"category": "stairs",
			"name": "楼梯"
		},
		{
			"id": "car",
			"position": Vector2(340, 715),
			"prompt": "检查汽车和后备箱",
			"category": "inspect",
			"name": "汽车"
		},
		{
			"id": "garage_drain",
			"position": Vector2(420, 805),
			"prompt": "检查车库排水口",
			"category": "inspect",
			"name": "排水口"
		},
		{
			"id": "fridge",
			"position": Vector2(570, 245),
			"prompt": "检查冰箱",
			"category": "inspect",
			"name": "冰箱"
		},
		{
			"id": "pantry",
			"position": Vector2(825, 290),
			"prompt": "检查食品柜",
			"category": "inspect",
			"name": "食品柜"
		},
		{
			"id": "radio",
			"position": Vector2(835, 450),
			"prompt": "检查收音机",
			"category": "inspect",
			"name": "收音机"
		},
		{
			"id": "bathroom",
			"position": Vector2(1010, 235),
			"prompt": "检查卫生和洗衣用品",
			"category": "inspect",
			"name": "厕所 / 洗衣"
		},
		{
			"id": "breaker",
			"position": Vector2(1035, 790),
			"prompt": "检查配电箱",
			"category": "inspect",
			"name": "配电箱"
		},
		{
			"id": "front_yard",
			"position": Vector2(790, 915),
			"prompt": "观察住宅街",
			"category": "inspect",
			"name": "前院"
		},
	]
