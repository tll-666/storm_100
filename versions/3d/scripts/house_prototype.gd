extends Node3D

const HOUSE_MIN_X := -11.0
const HOUSE_MAX_X := 11.0
const HOUSE_MIN_Z := -7.0
const HOUSE_MAX_Z := 7.0
const FIRST_FLOOR_Y := 2.15
const SECOND_FLOOR_Y := 5.65
const ROOF_Y := 9.15

const COLOR_EARTH := Color("665c4d")
const COLOR_GRASS := Color("52634f")
const COLOR_ROAD := Color("2e3539")
const COLOR_FOUNDATION := Color("555b5c")
const COLOR_FLOOR := Color("8b7d69")
const COLOR_UPSTAIRS_FLOOR := Color("807462")
const COLOR_WALL := Color("b8b3a5")
const COLOR_WALL_TRIM := Color("6f7777")
const COLOR_WOOD := Color("6d513d")
const COLOR_DARK_WOOD := Color("49392f")
const COLOR_FABRIC := Color("676f76")
const COLOR_KITCHEN := Color("77847d")
const COLOR_BED := Color("80717a")
const COLOR_WINDOW := Color(0.20, 0.32, 0.39, 0.72)
const COLOR_WATER := Color(0.08, 0.30, 0.42, 0.64)

var water_levels: Array[float] = [-1.10, -0.35, 0.35, 1.15, 2.35, 3.20, 5.90]
var water_names: Array[String] = [
	"无积水",
	"道路出现薄层积水",
	"道路积水加深",
	"水逼近住宅台地",
	"一楼脚踝深度",
	"一楼接近齐腰",
	"二楼开始进水",
]
var water_mesh: MeshInstance3D
var water_status_label: Label
var player: CharacterBody3D


func _ready() -> void:
	player = $Player
	_build_environment()
	_build_site()
	_build_house_shell()
	_build_first_floor_rooms()
	_build_second_floor_rooms()
	_build_stairs()
	_build_first_floor_furniture()
	_build_second_floor_furniture()
	_build_lighting()
	_build_water_preview()
	_build_hud()
	_set_water_stage(0)


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.physical_keycode >= KEY_1 and event.physical_keycode <= KEY_7:
		_set_water_stage(int(event.physical_keycode - KEY_1))
	elif event.keycode == KEY_R:
		player.global_position = Vector3(2.5, 2.22, 4.7)
		player.velocity = Vector3.ZERO


func _build_environment() -> void:
	RenderingServer.set_default_clear_color(Color("152027"))
	var world_environment := WorldEnvironment.new()
	world_environment.name = "暴雨环境"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("26353e")
	environment.background_energy_multiplier = 0.55
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("7d8990")
	environment.ambient_light_energy = 0.62
	environment.fog_enabled = true
	environment.fog_light_color = Color("596770")
	environment.fog_light_energy = 0.45
	environment.fog_density = 0.008
	world_environment.environment = environment
	add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.name = "阴天主光"
	sun.rotation_degrees = Vector3(-54.0, -32.0, 0.0)
	sun.light_color = Color("a9b7bd")
	sun.light_energy = 0.82
	sun.shadow_enabled = true
	add_child(sun)


func _build_site() -> void:
	_create_box("远端地面", Vector3(0.0, -0.62, 0.0), Vector3(70.0, 0.6, 70.0), COLOR_EARTH)
	_create_box("前方道路", Vector3(0.0, -0.28, 17.0), Vector3(70.0, 0.12, 8.0), COLOR_ROAD)
	_create_box("道路边沟", Vector3(0.0, -0.42, 12.3), Vector3(70.0, 0.18, 1.0), Color("303e42"))
	_create_box("住宅高地", Vector3(0.0, 0.82, 0.0), Vector3(25.0, 2.1, 17.0), COLOR_GRASS)
	_create_box("房屋地基", Vector3(0.0, 1.08, 0.0), Vector3(22.8, 2.15, 14.8), COLOR_FOUNDATION)
	_create_box("一楼楼板", Vector3(0.0, FIRST_FLOOR_Y - 0.12, 0.0), Vector3(22.0, 0.24, 14.0), COLOR_FLOOR)

	# 前门台阶使用可行走斜坡碰撞，台阶盒只负责视觉层次。
	var outside_steps := 9
	for index in range(outside_steps):
		var progress := float(index + 1) / float(outside_steps)
		var height := progress * 2.25
		var z := 11.1 - float(index) * 0.43
		_create_box(
			"前门台阶_%02d" % index,
			Vector3(0.0, -0.20 + height * 0.5, z),
			Vector3(2.5, height, 0.48),
			COLOR_FOUNDATION,
			false
		)
	_create_ramp(
		"前门隐藏斜坡",
		Vector3(0.0, 0.92, 9.35),
		Vector3(2.35, 0.14, 4.45),
		deg_to_rad(29.0),
		Color(0.0, 0.0, 0.0, 0.0),
		true,
		false
	)

	# 台地边缘和道路标线让玩家能够直接比较住宅与街道高差。
	_create_box("台地挡墙前", Vector3(0.0, 0.65, 8.35), Vector3(25.0, 1.7, 0.28), COLOR_FOUNDATION)
	for x in range(-28, 29, 7):
		_create_box("道路标线", Vector3(float(x), -0.18, 17.0), Vector3(3.6, 0.025, 0.16), Color("c5b976"), false)


func _build_house_shell() -> void:
	# 二楼楼板围绕楼梯井分成四块，避免玩家撞上完整天花板。
	_create_box("二楼楼板左", Vector3(-6.5, SECOND_FLOOR_Y - 0.12, 0.0), Vector3(9.0, 0.24, 14.0), COLOR_UPSTAIRS_FLOOR)
	_create_box("二楼楼板右", Vector3(6.5, SECOND_FLOOR_Y - 0.12, 0.0), Vector3(9.0, 0.24, 14.0), COLOR_UPSTAIRS_FLOOR)
	_create_box("二楼楼板后桥", Vector3(0.0, SECOND_FLOOR_Y - 0.12, -4.55), Vector3(4.0, 0.24, 4.9), COLOR_UPSTAIRS_FLOOR)
	_create_box("二楼楼板前桥", Vector3(0.0, SECOND_FLOOR_Y - 0.12, 6.35), Vector3(4.0, 0.24, 1.3), COLOR_UPSTAIRS_FLOOR)
	_create_box("平屋顶", Vector3(0.0, ROOF_Y, 0.0), Vector3(22.5, 0.30, 14.5), Color("4e5659"))

	var first_center_y := (FIRST_FLOOR_Y + SECOND_FLOOR_Y) * 0.5
	var second_center_y := (SECOND_FLOOR_Y + ROOF_Y) * 0.5
	var wall_height := 3.50

	# 一楼外墙：前门和左侧车库门保留真实开口。
	_wall_z("一楼后墙", HOUSE_MIN_Z, HOUSE_MIN_X, HOUSE_MAX_X, first_center_y, wall_height)
	_window_wall_z("一楼前墙左", HOUSE_MAX_Z, HOUSE_MIN_X, -1.25, FIRST_FLOOR_Y, SECOND_FLOOR_Y, [-7.5, -3.2], 1.8)
	_window_wall_z("一楼前墙右", HOUSE_MAX_Z, 1.25, HOUSE_MAX_X, FIRST_FLOOR_Y, SECOND_FLOOR_Y, [4.2, 8.2], 1.8)
	_wall_x("一楼右墙", HOUSE_MAX_X, HOUSE_MIN_Z, HOUSE_MAX_Z, first_center_y, wall_height)
	_wall_x("一楼左墙后", HOUSE_MIN_X, HOUSE_MIN_Z, -4.15, first_center_y, wall_height)
	_wall_x("一楼左墙前", HOUSE_MIN_X, -0.55, HOUSE_MAX_Z, first_center_y, wall_height)

	# 二楼外墙完整封闭；窗户以深色玻璃面板标识观察方向。
	_wall_z("二楼后墙", HOUSE_MIN_Z, HOUSE_MIN_X, HOUSE_MAX_X, second_center_y, wall_height)
	_window_wall_z("二楼前墙", HOUSE_MAX_Z, HOUSE_MIN_X, HOUSE_MAX_X, SECOND_FLOOR_Y, ROOF_Y, [-7.2, 0.0, 7.2], 2.0)
	_wall_x("二楼左墙", HOUSE_MIN_X, HOUSE_MIN_Z, HOUSE_MAX_Z, second_center_y, wall_height)
	_wall_x("二楼右墙", HOUSE_MAX_X, HOUSE_MIN_Z, HOUSE_MAX_Z, second_center_y, wall_height)

	_create_box("前门门楣", Vector3(0.0, 4.95, HOUSE_MAX_Z), Vector3(2.5, 1.0, 0.18), COLOR_WALL)
	_create_box("车库门楣", Vector3(HOUSE_MIN_X, 5.0, -2.35), Vector3(0.18, 0.9, 3.6), COLOR_WALL)
	_add_windows()


func _build_first_floor_rooms() -> void:
	var y := (FIRST_FLOOR_Y + SECOND_FLOOR_Y) * 0.5
	var height := 3.25
	# 车库与住宅之间保留一处内门。
	_wall_x("车库隔墙后", -4.0, -7.0, -1.2, y, height)
	_wall_x("车库隔墙前", -4.0, 0.7, 2.0, y, height)
	_wall_z("车库前隔墙左", 2.0, -11.0, -7.1, y, height)
	_wall_z("车库前隔墙右", 2.0, -5.5, -4.0, y, height)

	# 后排为厨房和老人房，中部小房间为卫生间，其余连成客餐厅。
	_wall_z("后排分隔左", -1.0, -4.0, -0.8, y, height)
	_wall_z("后排分隔中", -1.0, 0.8, 5.8, y, height)
	_wall_z("后排分隔右", -1.0, 7.4, 11.0, y, height)
	_wall_x("厨房老人房分隔", 3.5, -7.0, -4.5, y, height)
	_wall_x("厨房老人房门后", 3.5, -3.0, -1.0, y, height)
	_wall_x("卫生间侧墙", 7.2, -1.0, 2.2, y, height)
	_wall_z("卫生间前墙左", 2.2, 7.2, 8.0, y, height)
	_wall_z("卫生间前墙右", 2.2, 9.4, 11.0, y, height)

	_create_door_leaf("前门", Vector3(0.95, 3.35, 6.90), Vector3(0.10, 2.35, 1.85), 90.0)
	_create_door_leaf("老人房门", Vector3(6.55, 3.32, -1.05), Vector3(1.35, 2.25, 0.08), 0.0)
	_create_door_leaf("卫生间门", Vector3(8.05, 3.32, 2.15), Vector3(1.35, 2.25, 0.08), 0.0)


func _build_second_floor_rooms() -> void:
	var y := (SECOND_FLOOR_Y + ROOF_Y) * 0.5
	var height := 3.25
	# 后排三间卧室，前排保持为公共活动和物资转移空间。
	_wall_z("二楼卧室分隔左", 0.0, -11.0, -8.2, y, height)
	_wall_z("二楼卧室分隔左门后", 0.0, -6.7, -1.0, y, height)
	_wall_z("二楼卧室分隔中门前", 0.0, 1.0, 2.7, y, height)
	_wall_z("二楼卧室分隔中门后", 0.0, 4.2, 7.0, y, height)
	_wall_z("二楼卧室分隔右门后", 0.0, 8.5, 11.0, y, height)
	_wall_x("二楼主卧分隔", -3.5, -7.0, 0.0, y, height)
	_wall_x("二楼孩子房分隔", 4.0, -7.0, 0.0, y, height)

	# 楼梯井护栏提供可读的楼层边界，但不封死视线。
	_create_box("楼梯井左护栏", Vector3(-2.0, SECOND_FLOOR_Y + 0.55, 1.7), Vector3(0.12, 1.1, 7.3), COLOR_DARK_WOOD)
	_create_box("楼梯井右护栏", Vector3(2.0, SECOND_FLOOR_Y + 0.55, 1.7), Vector3(0.12, 1.1, 7.3), COLOR_DARK_WOOD)
	_create_box("楼梯井前护栏", Vector3(0.0, SECOND_FLOOR_Y + 0.55, 5.35), Vector3(4.1, 1.1, 0.12), COLOR_DARK_WOOD)


func _build_stairs() -> void:
	var step_count := 14
	var run := 5.55
	var rise := SECOND_FLOOR_Y - FIRST_FLOOR_Y
	var low_z := 4.85
	var tread := run / float(step_count)
	for index in range(step_count):
		var height := rise * float(index + 1) / float(step_count)
		var z := low_z - tread * (float(index) + 0.5)
		_create_box(
			"楼梯踏步_%02d" % index,
			Vector3(0.0, FIRST_FLOOR_Y + height * 0.5, z),
			Vector3(2.45, height, tread + 0.025),
			COLOR_WOOD,
			false
		)
	var angle := atan(rise / run)
	var ramp_length := sqrt(run * run + rise * rise)
	_create_ramp(
		"楼梯行走斜坡",
		Vector3(0.0, FIRST_FLOOR_Y + rise * 0.5, low_z - run * 0.5),
		Vector3(2.32, 0.16, ramp_length),
		angle,
		Color(0.0, 0.0, 0.0, 0.0),
		true,
		false
	)


func _build_first_floor_furniture() -> void:
	# 车库：车辆、货架和未来最先出现积水的纸箱。
	_create_box("汽车车身", Vector3(-7.7, 2.72, -2.1), Vector3(3.9, 1.05, 2.05), Color("4d5960"))
	_create_box("汽车车顶", Vector3(-7.7, 3.55, -2.25), Vector3(2.2, 0.75, 1.65), Color("465158"))
	for z in [-2.75, -1.45]:
		for x in [-9.1, -6.3]:
			_create_cylinder("车轮", Vector3(x, 2.55, z), 0.42, 0.34, Color("171b1d"), Vector3(90.0, 0.0, 0.0))
	_create_box("车库货架", Vector3(-9.9, 3.35, -5.75), Vector3(1.3, 2.3, 0.65), COLOR_DARK_WOOD)
	_create_box("低位纸箱", Vector3(-5.0, 2.48, -5.7), Vector3(0.9, 0.65, 0.8), Color("8a704d"))

	# 厨房：L形操作台和食品柜。
	_create_box("厨房后操作台", Vector3(-0.4, 2.65, -6.25), Vector3(6.2, 1.0, 0.75), COLOR_KITCHEN)
	_create_box("厨房侧操作台", Vector3(-3.25, 2.65, -4.2), Vector3(0.75, 1.0, 3.5), COLOR_KITCHEN)
	_create_box("冰箱", Vector3(2.75, 3.15, -5.9), Vector3(1.1, 2.0, 1.05), Color("a5aa9f"))
	_create_box("食品高柜", Vector3(-2.6, 3.4, -6.35), Vector3(1.05, 2.5, 0.62), COLOR_DARK_WOOD)

	# 老人房靠近卫生间，减少照护路线。
	_create_box("老人床架", Vector3(6.7, 2.52, -4.8), Vector3(2.3, 0.65, 4.0), COLOR_DARK_WOOD)
	_create_box("老人床垫", Vector3(6.7, 2.92, -4.8), Vector3(2.15, 0.28, 3.85), COLOR_BED, false)
	_create_box("老人床头柜", Vector3(8.5, 2.65, -6.0), Vector3(0.85, 0.9, 0.8), COLOR_WOOD)
	_create_box("卫生间洗手台", Vector3(10.25, 2.75, 0.7), Vector3(1.05, 1.15, 0.62), Color("a9b4ae"))
	_create_box("卫生间浴缸", Vector3(9.2, 2.52, -0.1), Vector3(2.8, 0.72, 1.25), Color("9caeb0"))

	# 客餐厅是前15天家庭活动核心，保持较大连续空间。
	_create_box("长沙发", Vector3(5.7, 2.68, 4.8), Vector3(4.4, 1.05, 1.15), COLOR_FABRIC)
	_create_box("沙发靠背", Vector3(5.7, 3.12, 5.25), Vector3(4.4, 1.25, 0.28), COLOR_FABRIC)
	_create_box("茶几", Vector3(5.7, 2.48, 3.15), Vector3(2.3, 0.62, 1.2), COLOR_WOOD)
	_create_box("餐桌", Vector3(-1.6, 2.82, -0.05), Vector3(2.8, 0.18, 1.65), COLOR_WOOD)
	for offset in [Vector3(-1.6, 2.55, -1.25), Vector3(-1.6, 2.55, 1.15), Vector3(-3.25, 2.55, -0.05), Vector3(0.05, 2.55, -0.05)]:
		_create_box("餐椅", offset, Vector3(0.62, 0.8, 0.62), COLOR_DARK_WOOD)
	_create_box("玄关鞋柜", Vector3(2.8, 2.7, 6.35), Vector3(2.2, 1.05, 0.55), COLOR_WOOD)


func _build_second_floor_furniture() -> void:
	# 三间卧室体量不同，让家庭成员位置无需依赖文字标识。
	_create_bed("主卧双人床", Vector3(-7.2, SECOND_FLOOR_Y, -4.6), Vector2(3.2, 4.2), Color("756b77"))
	_create_box("主卧衣柜", Vector3(-9.7, 6.65, -1.0), Vector3(1.25, 2.0, 2.0), COLOR_DARK_WOOD)
	_create_bed("大孩子床", Vector3(0.1, SECOND_FLOOR_Y, -5.0), Vector2(1.7, 3.7), Color("60728a"))
	_create_box("大孩子书桌", Vector3(-1.1, 6.08, -1.0), Vector3(2.0, 0.85, 0.75), COLOR_WOOD)
	_create_bed("小孩子床", Vector3(7.2, SECOND_FLOOR_Y, -5.0), Vector2(1.65, 3.4), Color("9a805f"))
	_create_box("玩具柜", Vector3(9.6, 6.25, -1.0), Vector3(1.6, 1.2, 0.75), Color("927650"))

	_create_box("二楼公共沙发", Vector3(6.5, 6.18, 4.5), Vector3(4.2, 1.0, 1.1), COLOR_FABRIC)
	_create_box("二楼矮桌", Vector3(6.5, 5.98, 2.8), Vector3(2.0, 0.6, 1.0), COLOR_WOOD)
	for index in range(5):
		var x := -9.5 + float(index % 3) * 1.15
		var z := 4.5 + float(index / 3) * 1.15
		_create_box("二楼储备箱_%02d" % index, Vector3(x, 6.02, z), Vector3(0.9, 0.75, 0.9), Color("8a704d"))


func _build_lighting() -> void:
	_add_omni_light("一楼客厅灯", Vector3(5.0, 5.05, 3.0), Color("ffe0a5"), 4.2, 8.5)
	_add_omni_light("一楼厨房灯", Vector3(-0.5, 5.0, -4.2), Color("e6eee9"), 3.4, 7.0)
	_add_omni_light("一楼老人房灯", Vector3(7.0, 5.0, -4.3), Color("f1d7ac"), 2.9, 6.0)
	_add_omni_light("二楼活动区灯", Vector3(6.0, 8.55, 3.0), Color("f4d8a3"), 3.7, 8.0)
	_add_omni_light("二楼卧室灯", Vector3(-3.0, 8.5, -4.0), Color("ddd8c7"), 3.0, 9.0)


func _build_water_preview() -> void:
	water_mesh = MeshInstance3D.new()
	water_mesh.name = "调试水面"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(70.0, 0.08, 70.0)
	water_mesh.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = COLOR_WATER
	material.metallic = 0.15
	material.roughness = 0.18
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	water_mesh.material_override = material
	add_child(water_mesh)


func _build_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "原型说明"
	add_child(canvas)
	var panel := ColorRect.new()
	panel.position = Vector2(18.0, 18.0)
	panel.size = Vector2(430.0, 154.0)
	panel.color = Color(0.025, 0.04, 0.05, 0.86)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(panel)
	var title := Label.new()
	title.position = Vector2(16.0, 12.0)
	title.text = "高地两层住宅 · 第一人称灰盒"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color("efc46f"))
	panel.add_child(title)
	var plan := Label.new()
	plan.position = Vector2(16.0, 45.0)
	plan.text = "一楼：车库 / 厨房 / 老人房 / 卫生间 / 客餐厅\n二楼：主卧 / 两个孩子房 / 活动区 / 储备区"
	plan.add_theme_font_size_override("font_size", 13)
	plan.add_theme_color_override("font_color", Color("d5ddda"))
	panel.add_child(plan)
	water_status_label = Label.new()
	water_status_label.position = Vector2(16.0, 92.0)
	water_status_label.add_theme_font_size_override("font_size", 14)
	water_status_label.add_theme_color_override("font_color", Color("8fcde0"))
	panel.add_child(water_status_label)
	var controls := Label.new()
	controls.position = Vector2(16.0, 121.0)
	controls.text = "WASD移动 · 鼠标观察 · Shift加速 · F手电 · 1—7水位 · R复位"
	controls.add_theme_font_size_override("font_size", 12)
	controls.add_theme_color_override("font_color", Color("aab6ba"))
	panel.add_child(controls)

	var crosshair := Label.new()
	crosshair.set_anchors_preset(Control.PRESET_CENTER)
	crosshair.position = Vector2(-4.0, -12.0)
	crosshair.text = "+"
	crosshair.add_theme_font_size_override("font_size", 18)
	crosshair.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.72))
	canvas.add_child(crosshair)


func _set_water_stage(index: int) -> void:
	var safe_index := clampi(index, 0, water_levels.size() - 1)
	water_mesh.position.y = water_levels[safe_index]
	if water_status_label != null:
		water_status_label.text = "水位预览 %d/7：%s（海拔 %.2f米）" % [safe_index + 1, water_names[safe_index], water_levels[safe_index]]


func _add_windows() -> void:
	# 前窗是真实墙洞，玩家能从室内比较道路、台地和水面的高度。
	for x in [-7.5, -3.2, 4.2, 8.2]:
		_create_box("一楼前窗", Vector3(x, 3.92, 6.98), Vector3(1.8, 1.45, 0.045), COLOR_WINDOW, true, true)
	for x in [-7.2, 0.0, 7.2]:
		_create_box("二楼前窗", Vector3(x, 7.42, 6.98), Vector3(2.0, 1.45, 0.045), COLOR_WINDOW, true, true)
	for x in [-7.0, 0.0, 7.0]:
		_create_box("二楼后窗", Vector3(x, 7.35, -6.88), Vector3(2.1, 1.45, 0.05), COLOR_WINDOW, false, true)


func _create_bed(name_text: String, floor_position: Vector3, footprint: Vector2, color: Color) -> void:
	_create_box(name_text + "床架", floor_position + Vector3(0.0, 0.30, 0.0), Vector3(footprint.x, 0.55, footprint.y), COLOR_DARK_WOOD)
	_create_box(name_text + "床垫", floor_position + Vector3(0.0, 0.67, 0.0), Vector3(footprint.x - 0.12, 0.24, footprint.y - 0.12), color, false)


func _create_door_leaf(name_text: String, center: Vector3, size: Vector3, yaw_degrees: float) -> void:
	var door := _create_box(name_text, center, size, COLOR_WOOD, false)
	door.rotation_degrees.y = yaw_degrees


func _wall_x(name_text: String, x: float, z_start: float, z_end: float, y: float, height: float) -> void:
	_create_box(name_text, Vector3(x, y, (z_start + z_end) * 0.5), Vector3(0.18, height, z_end - z_start), COLOR_WALL)


func _wall_z(name_text: String, z: float, x_start: float, x_end: float, y: float, height: float) -> void:
	_create_box(name_text, Vector3((x_start + x_end) * 0.5, y, z), Vector3(x_end - x_start, height, 0.18), COLOR_WALL)


func _window_wall_z(
	name_text: String,
	z: float,
	x_start: float,
	x_end: float,
	floor_y: float,
	ceiling_y: float,
	window_centers: Array,
	window_width: float
) -> void:
	var sill_height := 1.05
	var window_height := 1.45
	var window_bottom := floor_y + sill_height
	var window_top := window_bottom + window_height
	_create_box(
		name_text + "窗台墙",
		Vector3((x_start + x_end) * 0.5, floor_y + sill_height * 0.5, z),
		Vector3(x_end - x_start, sill_height, 0.18),
		COLOR_WALL
	)
	_create_box(
		name_text + "窗上墙",
		Vector3((x_start + x_end) * 0.5, (window_top + ceiling_y) * 0.5, z),
		Vector3(x_end - x_start, ceiling_y - window_top, 0.18),
		COLOR_WALL
	)
	var cursor := x_start
	for center_value in window_centers:
		var center := float(center_value)
		var opening_left := maxf(cursor, center - window_width * 0.5)
		var opening_right := minf(x_end, center + window_width * 0.5)
		if opening_left > cursor:
			_create_box(
				name_text + "窗间墙",
				Vector3((cursor + opening_left) * 0.5, window_bottom + window_height * 0.5, z),
				Vector3(opening_left - cursor, window_height, 0.18),
				COLOR_WALL
			)
		cursor = opening_right
	if cursor < x_end:
		_create_box(
			name_text + "窗间墙末端",
			Vector3((cursor + x_end) * 0.5, window_bottom + window_height * 0.5, z),
			Vector3(x_end - cursor, window_height, 0.18),
			COLOR_WALL
		)


func _create_box(
	name_text: String,
	center: Vector3,
	size: Vector3,
	color: Color,
	collision: bool = true,
	transparent: bool = false
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name_text
	mesh_instance.position = center
	var box := BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.material_override = _make_material(color, transparent)
	add_child(mesh_instance)
	if collision:
		_add_box_collision(mesh_instance, size)
	return mesh_instance


func _create_ramp(
	name_text: String,
	center: Vector3,
	size: Vector3,
	rotation_x: float,
	color: Color,
	collision: bool,
	visible_mesh: bool
) -> MeshInstance3D:
	var ramp := _create_box(name_text, center, size, color, collision)
	ramp.rotation.x = rotation_x
	ramp.visible = visible_mesh
	return ramp


func _create_cylinder(
	name_text: String,
	center: Vector3,
	radius: float,
	height: float,
	color: Color,
	rotation_degrees_value: Vector3
) -> void:
	var instance := MeshInstance3D.new()
	instance.name = name_text
	instance.position = center
	instance.rotation_degrees = rotation_degrees_value
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = height
	instance.mesh = cylinder
	instance.material_override = _make_material(color)
	add_child(instance)


func _add_box_collision(parent: MeshInstance3D, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 2
	var collision_shape := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision_shape.shape = shape
	body.add_child(collision_shape)
	parent.add_child(body)


func _make_material(color: Color, transparent: bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.78
	if transparent or color.a < 0.99:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func _add_omni_light(name_text: String, position_value: Vector3, color: Color, energy: float, range_value: float) -> void:
	var light := OmniLight3D.new()
	light.name = name_text
	light.position = position_value
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range_value
	light.shadow_enabled = true
	add_child(light)
