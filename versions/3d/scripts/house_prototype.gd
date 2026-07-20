extends Node3D

## 3D 房屋灰盒：用于验证动线、楼层关系和水位视觉表现。
## 尺寸以米为单位；道路在南侧，地势向北侧缓慢升高。

const HOUSE_MIN_X := -5.2
const HOUSE_MAX_X := 5.2
const HOUSE_MIN_Z := -4.4
const HOUSE_MAX_Z := 4.4
const GARAGE_FLOOR_Y := 0.45
const FIRST_FLOOR_Y := 0.65
const SECOND_FLOOR_Y := 3.65
const ROOF_Y := 6.65

const COLOR_EARTH := Color("665c4d")
const COLOR_GRASS := Color("52634f")
const COLOR_ROAD := Color("2e3539")
const COLOR_FOUNDATION := Color("555b5c")
const COLOR_FLOOR := Color("8b7d69")
const COLOR_UPSTAIRS_FLOOR := Color("807462")
const COLOR_WALL := Color("b8b3a5")
const COLOR_WOOD := Color("6d513d")
const COLOR_DARK_WOOD := Color("49392f")
const COLOR_FABRIC := Color("676f76")
const COLOR_KITCHEN := Color("77847d")
const COLOR_BED := Color("80717a")
const COLOR_WINDOW := Color(0.20, 0.32, 0.39, 0.72)
const COLOR_WATER := Color(0.08, 0.30, 0.42, 0.64)

var water_levels: Array[float] = [-0.10, 0.08, 0.30, 0.45, 0.80, 1.55, 3.80]
var water_names: Array[String] = [
	"无积水",
	"道路出现薄层积水",
	"道路积水加深",
	"水逼近住宅入口",
	"一楼开始进水",
	"一楼水位接近腰部",
	"二楼地面开始进水",
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
		player.global_position = Vector3(2.6, 0.72, 3.0)
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
	# 低矮的缓坡地面：南侧道路低，北侧后院高，不再使用悬空大台地。
	var terrain := _create_box("缓坡地面", Vector3(0.0, 0.35, 0.0), Vector3(42.0, 0.7, 42.0), COLOR_GRASS)
	terrain.rotation.x = deg_to_rad(2.0)
	_create_box("南侧道路", Vector3(0.0, -0.05, 12.0), Vector3(42.0, 0.16, 7.0), COLOR_ROAD)
	_create_box("道路排水沟", Vector3(0.0, -0.18, 8.35), Vector3(42.0, 0.18, 0.55), Color("303e42"))
	_create_box("车库进车缓坡", Vector3(-3.5, 0.20, 7.65), Vector3(3.5, 0.16, 5.2), COLOR_FOUNDATION, true)
	_create_ramp("入户缓坡", Vector3(1.8, 0.37, 7.35), Vector3(3.0, 0.16, 5.0), deg_to_rad(3.0), COLOR_FOUNDATION, true, true)
	_create_box("前门雨棚地面", Vector3(1.7, FIRST_FLOOR_Y - 0.10, 5.0), Vector3(3.0, 0.20, 1.3), COLOR_FLOOR)
	for x in range(-18, 19, 6):
		_create_box("道路标线", Vector3(float(x), 0.04, 12.0), Vector3(3.2, 0.025, 0.14), Color("c5b976"), false)
	_create_box("北侧后院小径", Vector3(2.9, 0.72, -6.5), Vector3(3.0, 0.12, 3.8), COLOR_FOUNDATION, false)


func _build_house_shell() -> void:
	# 二楼楼板围绕楼梯洞口分块，楼梯位于靠墙位置，保留完整可见动线。
	_create_box("二楼楼板左", Vector3(-3.5, SECOND_FLOOR_Y - 0.12, 0.0), Vector3(3.4, 0.24, 8.8), COLOR_UPSTAIRS_FLOOR)
	_create_box("二楼楼板右", Vector3(2.8, SECOND_FLOOR_Y - 0.12, 0.0), Vector3(4.8, 0.24, 8.8), COLOR_UPSTAIRS_FLOOR)
	_create_box("二楼楼板后桥", Vector3(-0.7, SECOND_FLOOR_Y - 0.12, -3.8), Vector3(2.2, 0.24, 1.2), COLOR_UPSTAIRS_FLOOR)
	_create_box("二楼楼板前桥", Vector3(-0.7, SECOND_FLOOR_Y - 0.12, 3.9), Vector3(2.2, 0.24, 1.0), COLOR_UPSTAIRS_FLOOR)
	_create_box("平屋顶", Vector3(0.0, ROOF_Y, 0.0), Vector3(10.7, 0.30, 9.1), Color("4e5659"))

	var first_center_y := (FIRST_FLOOR_Y + SECOND_FLOOR_Y) * 0.5
	var second_center_y := (SECOND_FLOOR_Y + ROOF_Y) * 0.5
	var floor_height := SECOND_FLOOR_Y - FIRST_FLOOR_Y

	# 一楼外墙：南侧明确留出车库门、入户门和客厅窗带。
	_wall_z("一楼北墙左", HOUSE_MIN_Z, HOUSE_MIN_X, 0.1, first_center_y, floor_height)
	_window_wall_z("一楼北墙厨房窗", HOUSE_MIN_Z, 0.1, HOUSE_MAX_X, FIRST_FLOOR_Y, SECOND_FLOOR_Y, [1.8, 4.0], 1.55)
	_wall_z("一楼南墙车库右框", HOUSE_MAX_Z, -1.8, -0.9, first_center_y, floor_height)
	_wall_z("一楼南墙入户右框", HOUSE_MAX_Z, 0.10, 0.35, first_center_y, floor_height)
	_window_wall_z("一楼南墙客厅窗", HOUSE_MAX_Z, 0.35, HOUSE_MAX_X, FIRST_FLOOR_Y, SECOND_FLOOR_Y, [2.4, 4.25], 1.45)
	_wall_x("一楼西墙", HOUSE_MIN_X, HOUSE_MIN_Z, HOUSE_MAX_Z, first_center_y, floor_height)
	_wall_x("一楼东墙", HOUSE_MAX_X, HOUSE_MIN_Z, HOUSE_MAX_Z, first_center_y, floor_height)

	# 二楼外墙，南侧通往阳台；阳台栏杆由单独构件表现。
	_wall_z("二楼北墙", HOUSE_MIN_Z, HOUSE_MIN_X, HOUSE_MAX_X, second_center_y, ROOF_Y - SECOND_FLOOR_Y)
	_window_wall_z("二楼南墙左窗带", HOUSE_MAX_Z, HOUSE_MIN_X, 0.50, SECOND_FLOOR_Y, ROOF_Y, [-3.8], 1.65)
	_wall_z("二楼阳台门左框", HOUSE_MAX_Z, 0.50, 0.85, second_center_y, ROOF_Y - SECOND_FLOOR_Y)
	_wall_z("二楼阳台门右框", HOUSE_MAX_Z, 1.80, 2.00, second_center_y, ROOF_Y - SECOND_FLOOR_Y)
	_window_wall_z("二楼南墙右窗带", HOUSE_MAX_Z, 2.00, HOUSE_MAX_X, SECOND_FLOOR_Y, ROOF_Y, [2.8, 4.35], 1.35)
	_wall_x("二楼西墙", HOUSE_MIN_X, HOUSE_MIN_Z, HOUSE_MAX_Z, second_center_y, ROOF_Y - SECOND_FLOOR_Y)
	_wall_x("二楼东墙", HOUSE_MAX_X, HOUSE_MIN_Z, HOUSE_MAX_Z, second_center_y, ROOF_Y - SECOND_FLOOR_Y)

	# 车库门、入户门和阳台门用无碰撞门扇提示开口位置。
	_create_door_leaf("车库卷帘门", Vector3(-3.5, 1.95, HOUSE_MAX_Z + 0.06), Vector3(3.0, 2.55, 0.08), 0.0)
	_create_door_leaf("一楼入户门", Vector3(-0.32, 1.85, HOUSE_MAX_Z + 0.06), Vector3(0.95, 2.20, 0.08), 0.0)
	_create_door_leaf("二楼阳台门", Vector3(1.35, 5.15, HOUSE_MAX_Z + 0.06), Vector3(0.95, 2.15, 0.08), 0.0)

	# 南侧阳台为一楼屋檐下的安全观察点，向东侧转折。
	_create_box("南侧阳台地面", Vector3(2.8, SECOND_FLOOR_Y - 0.02, 5.1), Vector3(4.8, 0.16, 1.4), COLOR_FLOOR)
	_create_box("东侧阳台地面", Vector3(5.9, SECOND_FLOOR_Y - 0.02, 2.5), Vector3(1.4, 0.16, 5.2), COLOR_FLOOR)
	_create_box("阳台南栏杆", Vector3(2.8, SECOND_FLOOR_Y + 0.62, 5.75), Vector3(4.8, 1.15, 0.10), COLOR_DARK_WOOD)
	_create_box("阳台东栏杆", Vector3(6.55, SECOND_FLOOR_Y + 0.62, 2.5), Vector3(0.10, 1.15, 5.2), COLOR_DARK_WOOD)
	_create_box("楼梯间护栏", Vector3(0.40, SECOND_FLOOR_Y + 0.58, 1.35), Vector3(0.10, 1.05, 3.8), COLOR_DARK_WOOD)
	_create_box("屋顶检修口", Vector3(-0.70, ROOF_Y + 0.12, 3.65), Vector3(1.1, 0.18, 1.1), COLOR_DARK_WOOD)
	_add_windows()


func _build_first_floor_rooms() -> void:
	var y := (FIRST_FLOOR_Y + SECOND_FLOOR_Y) * 0.5
	var height := SECOND_FLOOR_Y - FIRST_FLOOR_Y
	# 分房间地面，不设置抬高整个平台；车库比居住区低 0.20m。
	_create_box("车库地面", Vector3(-3.5, GARAGE_FLOOR_Y - 0.12, 1.6), Vector3(3.4, 0.24, 5.6), COLOR_FOUNDATION)
	_create_box("一楼居住区地面", Vector3(1.7, FIRST_FLOOR_Y - 0.12, 0.0), Vector3(7.0, 0.24, 8.8), COLOR_FLOOR)
	_create_box("老人房后排地面", Vector3(-3.5, FIRST_FLOOR_Y - 0.12, -2.8), Vector3(3.4, 0.24, 3.2), COLOR_FLOOR)

	# 后排：老人房、卫生间、厨房；前排：车库、楼梯、入口和客厅。
	_wall_x("老人房与卫生间", -1.8, HOUSE_MIN_Z, -2.1, y, height)
	_wall_x("卫生间与厨房", 0.1, HOUSE_MIN_Z, -0.6, y, height)
	_wall_z("卫生间后墙左", -2.1, -1.8, -0.95, y, height)
	_wall_z("卫生间后墙右", -2.1, -0.05, 0.1, y, height)
	_create_door_leaf("卫生间门", Vector3(-0.50, 1.75, -2.1), Vector3(1.0, 2.1, 0.08), 0.0)
	_wall_x("车库隔墙后段", -1.8, -1.2, -0.25, y, height)
	_wall_x("车库隔墙前段", -1.8, 0.65, 3.4, y, height)
	_create_door_leaf("车库内门", Vector3(-1.8, 1.70, 0.20), Vector3(0.08, 2.1, 0.9), 0.0)
	_wall_z("厨房客厅隔墙左", -0.6, 0.1, 1.25, y, height)
	_wall_z("厨房客厅隔墙右", -0.6, 4.45, 5.2, y, height)
	_wall_z("老人房前墙", -1.2, -5.2, -1.8, y, height)


func _build_second_floor_rooms() -> void:
	var y := (SECOND_FLOOR_Y + ROOF_Y) * 0.5
	var height := ROOF_Y - SECOND_FLOOR_Y
	# 后排卧室与卫生间共用湿区，前排为主卧、楼梯 landing 和家庭活动区。
	_wall_z("二楼后排分隔左", -0.9, HOUSE_MIN_X, -1.8, y, height)
	_wall_z("二楼后排分隔右", -0.9, 0.4, HOUSE_MAX_X, y, height)
	_wall_x("青少年房与卫生间", -2.1, HOUSE_MIN_Z, -0.9, y, height)
	_wall_x("卫生间与储物过道", -0.1, HOUSE_MIN_Z, -2.65, y, height)
	_wall_x("卫生间与储物过道下段", -0.1, -1.85, -0.9, y, height)
	_wall_x("儿童房侧墙上段", 1.6, HOUSE_MIN_Z, -2.65, y, height)
	_wall_x("儿童房侧墙下段", 1.6, -1.85, -0.9, y, height)
	_create_door_leaf("青少年房门", Vector3(-2.1, 4.95, -1.95), Vector3(0.08, 2.1, 0.85), 0.0)
	_create_door_leaf("儿童房门", Vector3(1.6, 4.95, -1.95), Vector3(0.08, 2.1, 0.85), 0.0)
	_create_door_leaf("二楼卫生间门", Vector3(-0.95, 4.95, -0.9), Vector3(0.9, 2.1, 0.08), 0.0)
	_wall_x("主卧与楼梯边界", -1.8, -0.9, 4.4, y, height)
	_wall_x("活动区与楼梯边界", 0.4, -0.9, 3.4, y, height)
	_create_door_leaf("主卧门", Vector3(-1.8, 4.95, 0.05), Vector3(0.08, 2.1, 0.9), 0.0)


func _build_stairs() -> void:
	var step_count := 15
	var run := 4.0
	var rise := SECOND_FLOOR_Y - FIRST_FLOOR_Y
	var low_z := 3.25
	var tread := run / float(step_count)
	var stair_x := -0.70
	for index in range(step_count):
		var height := rise * float(index + 1) / float(step_count)
		var z := low_z - tread * (float(index) + 0.5)
		_create_box("楼梯踏步_%02d" % index, Vector3(stair_x, FIRST_FLOOR_Y + height * 0.5, z), Vector3(2.2, height, tread + 0.025), COLOR_WOOD, false)
	var angle := atan(rise / run)
	var ramp_length := sqrt(run * run + rise * rise)
	_create_ramp("楼梯行走斜面", Vector3(stair_x, FIRST_FLOOR_Y + rise * 0.5, low_z - run * 0.5), Vector3(2.05, 0.16, ramp_length), angle, Color(0.0, 0.0, 0.0, 0.0), true, false)


func _build_first_floor_furniture() -> void:
	# 车库：车辆、货架和会在早期积水中首先受影响的纸箱。
	_create_box("汽车车身", Vector3(-3.5, 1.05, 2.15), Vector3(2.7, 0.9, 3.7), Color("4d5960"))
	_create_box("汽车车顶", Vector3(-3.5, 1.76, 2.05), Vector3(1.8, 0.55, 2.0), Color("465158"))
	for z in [1.0, 3.25]:
		for x in [-4.6, -2.4]:
			_create_cylinder("车轮", Vector3(x, 0.78, z), 0.38, 0.30, Color("171b1d"), Vector3(90.0, 0.0, 0.0))
	_create_box("车库货架", Vector3(-4.75, 1.65, -0.25), Vector3(0.65, 2.1, 1.9), COLOR_DARK_WOOD)
	_create_box("低位纸箱", Vector3(-2.25, 0.78, -0.20), Vector3(0.85, 0.55, 0.80), Color("8a704d"))

	# 厨房与餐区。
	_create_box("厨房后操作台", Vector3(2.55, 1.18, -3.95), Vector3(4.9, 1.05, 0.72), COLOR_KITCHEN)
	_create_box("厨房侧操作台", Vector3(0.52, 1.18, -2.45), Vector3(0.72, 1.05, 2.2), COLOR_KITCHEN)
	_create_box("冰箱", Vector3(4.55, 1.55, -2.55), Vector3(0.80, 1.8, 0.90), Color("a5aa9f"))
	_create_box("食品高柜", Vector3(1.55, 1.70, -4.03), Vector3(0.75, 2.2, 0.58), COLOR_DARK_WOOD)
	_create_box("餐桌", Vector3(2.1, 0.90, -1.15), Vector3(2.5, 0.18, 1.35), COLOR_WOOD)
	for offset in [Vector3(0.95, 0.65, -2.05), Vector3(3.25, 0.65, -2.05), Vector3(0.95, 0.65, -0.25), Vector3(3.25, 0.65, -0.25)]:
		_create_box("餐椅", offset, Vector3(0.55, 0.72, 0.55), COLOR_DARK_WOOD)

	# 老人房与卫生间。
	_create_bed("老人床", Vector3(-3.5, FIRST_FLOOR_Y, -2.75), Vector2(2.1, 2.4), Color("877a83"))
	_create_box("老人床头柜", Vector3(-4.55, 1.15, -3.85), Vector3(0.55, 0.75, 0.65), COLOR_WOOD)
	_create_box("卫生间洗手台", Vector3(-1.25, 1.12, -3.55), Vector3(0.75, 0.95, 0.55), Color("a9b4ae"))
	_create_box("卫生间浴缸", Vector3(-0.85, 0.85, -2.55), Vector3(1.3, 0.55, 0.78), Color("9caeb0"))

	# 客厅和入户玄关是前 15 天的家庭活动核心。
	_create_box("客厅沙发", Vector3(3.15, 1.18, 2.95), Vector3(3.5, 1.0, 0.95), COLOR_FABRIC)
	_create_box("沙发靠背", Vector3(3.15, 1.62, 3.35), Vector3(3.5, 1.15, 0.25), COLOR_FABRIC)
	_create_box("客厅茶几", Vector3(3.15, 0.88, 1.55), Vector3(1.8, 0.55, 0.95), COLOR_WOOD)
	_create_box("玄关鞋柜", Vector3(-0.85, 1.18, 3.92), Vector3(1.35, 1.0, 0.50), COLOR_WOOD)


func _build_second_floor_furniture() -> void:
	_create_bed("主卧双人床", Vector3(-3.5, SECOND_FLOOR_Y, 2.35), Vector2(2.55, 3.1), Color("756b77"))
	_create_box("主卧衣柜", Vector3(-4.65, 4.85, -0.1), Vector3(0.75, 2.0, 1.8), COLOR_DARK_WOOD)
	_create_bed("青少年床", Vector3(-3.65, SECOND_FLOOR_Y, -2.65), Vector2(1.55, 2.5), Color("60728a"))
	_create_box("青少年书桌", Vector3(-4.55, 4.35, -3.85), Vector3(0.65, 0.78, 1.2), COLOR_WOOD)
	_create_bed("儿童床", Vector3(3.35, SECOND_FLOOR_Y, -2.65), Vector2(1.55, 2.5), Color("9a805f"))
	_create_box("儿童玩具柜", Vector3(4.55, 4.45, -3.8), Vector3(0.55, 1.2, 1.1), Color("927650"))
	_create_box("二楼活动区沙发", Vector3(3.25, 4.18, 2.75), Vector3(3.3, 0.95, 0.95), COLOR_FABRIC)
	_create_box("二楼矮桌", Vector3(3.25, 3.95, 1.55), Vector3(1.7, 0.55, 0.85), COLOR_WOOD)
	for index in range(4):
		_create_box("二楼储物箱_%02d" % index, Vector3(0.95 + float(index % 2) * 0.75, 4.10, -2.35 + float(index / 2) * 0.8), Vector3(0.60, 0.70, 0.60), Color("8a704d"))


func _build_lighting() -> void:
	_add_omni_light("一楼客厅灯", Vector3(3.0, 3.25, 2.1), Color("ffe0a5"), 3.7, 8.0)
	_add_omni_light("一楼厨房灯", Vector3(2.5, 3.25, -3.0), Color("e6eee9"), 3.2, 7.0)
	_add_omni_light("老人房灯", Vector3(-3.5, 3.20, -3.0), Color("f1d7ac"), 2.8, 6.0)
	_add_omni_light("二楼活动区灯", Vector3(3.1, 6.25, 2.0), Color("f4d8a3"), 3.5, 8.0)
	_add_omni_light("二楼卧室灯", Vector3(-3.4, 6.25, -2.5), Color("ddd8c7"), 2.9, 8.0)


func _build_water_preview() -> void:
	water_mesh = MeshInstance3D.new()
	water_mesh.name = "调试水面"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(70.0, 0.08, 70.0)
	water_mesh.mesh = mesh
	water_mesh.material_override = _make_material(COLOR_WATER, true)
	add_child(water_mesh)


func _build_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "原型说明"
	add_child(canvas)
	var panel := ColorRect.new()
	panel.position = Vector2(18.0, 18.0)
	panel.size = Vector2(470.0, 164.0)
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
	plan.text = "一楼：车库 / 厨房餐区 / 老人房 / 卫生间 / 客厅\n二楼：主卧 / 两个孩子房 / 活动区 / 阳台"
	plan.add_theme_font_size_override("font_size", 13)
	plan.add_theme_color_override("font_color", Color("d5ddda"))
	panel.add_child(plan)
	water_status_label = Label.new()
	water_status_label.position = Vector2(16.0, 98.0)
	water_status_label.add_theme_font_size_override("font_size", 14)
	water_status_label.add_theme_color_override("font_color", Color("8fcde0"))
	panel.add_child(water_status_label)
	var controls := Label.new()
	controls.position = Vector2(16.0, 128.0)
	controls.text = "WASD 移动 · 鼠标观察 · Shift 加速 · F 手电 · 1–7 水位 · R 复位"
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
		water_status_label.text = "水位预览 %d/7：%s（相对道路 %.2fm）" % [safe_index + 1, water_names[safe_index], water_levels[safe_index]]


func _add_windows() -> void:
	for x in [1.5, 3.3, 4.55]:
		_create_box("一楼客厅窗", Vector3(x, 2.20, HOUSE_MAX_Z + 0.02), Vector3(1.35, 1.25, 0.045), COLOR_WINDOW, true, true)
	for x in [-3.8, 2.8]:
		_create_box("二楼南窗", Vector3(x, 5.15, HOUSE_MAX_Z + 0.02), Vector3(1.55, 1.35, 0.045), COLOR_WINDOW, true, true)
	for x in [1.8, 4.0]:
		_create_box("一楼厨房窗", Vector3(x, 2.20, HOUSE_MIN_Z - 0.02), Vector3(1.35, 1.25, 0.045), COLOR_WINDOW, false, true)


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


func _window_wall_z(name_text: String, z: float, x_start: float, x_end: float, floor_y: float, ceiling_y: float, window_centers: Array, window_width: float) -> void:
	var sill_height := 1.05
	var window_height := 1.45
	var window_bottom := floor_y + sill_height
	var window_top := window_bottom + window_height
	_create_box(name_text + "窗台墙", Vector3((x_start + x_end) * 0.5, floor_y + sill_height * 0.5, z), Vector3(x_end - x_start, sill_height, 0.18), COLOR_WALL)
	_create_box(name_text + "窗上墙", Vector3((x_start + x_end) * 0.5, (window_top + ceiling_y) * 0.5, z), Vector3(x_end - x_start, ceiling_y - window_top, 0.18), COLOR_WALL)
	var cursor := x_start
	for center_value in window_centers:
		var center := float(center_value)
		var opening_left := maxf(cursor, center - window_width * 0.5)
		var opening_right := minf(x_end, center + window_width * 0.5)
		if opening_left > cursor:
			_create_box(name_text + "窗间墙", Vector3((cursor + opening_left) * 0.5, window_bottom + window_height * 0.5, z), Vector3(opening_left - cursor, window_height, 0.18), COLOR_WALL)
		cursor = maxf(cursor, opening_right)
	if cursor < x_end:
		_create_box(name_text + "窗间墙末端", Vector3((cursor + x_end) * 0.5, window_bottom + window_height * 0.5, z), Vector3(x_end - cursor, window_height, 0.18), COLOR_WALL)


func _create_box(name_text: String, center: Vector3, size: Vector3, color: Color, collision: bool = true, transparent: bool = false) -> MeshInstance3D:
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


func _create_ramp(name_text: String, center: Vector3, size: Vector3, rotation_x: float, color: Color, collision: bool, visible_mesh: bool) -> MeshInstance3D:
	var ramp := _create_box(name_text, center, size, color, collision)
	ramp.rotation.x = rotation_x
	ramp.visible = visible_mesh
	return ramp


func _create_cylinder(name_text: String, center: Vector3, radius: float, height: float, color: Color, rotation_degrees_value: Vector3) -> void:
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
