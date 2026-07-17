extends SceneTree

const PLAYER_CLEARANCE := 16.0
const GRID_STEP := 12.0

var failures: Array[String] = []
var game_state: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	game_state = root.get_node("GameState")
	_test_world_routes()
	await _test_inventory_interfaces()
	if failures.is_empty():
		print("PASS: Godot场景启动、主要通路与物品栏界面测试全部通过。")
		quit(0)
		return
	for message in failures:
		push_error("FAIL: %s" % message)
	quit(1)


func _test_world_routes() -> void:
	var world_script := load("res://scripts/world_map.gd")
	var world: Node2D = world_script.new()
	root.add_child(world)
	var floor_one := [
		{"name": "车库", "point": Vector2(350, 720)},
		{"name": "客厅", "point": Vector2(705, 430)},
		{"name": "厨房", "point": Vector2(700, 250)},
		{"name": "厕所", "point": Vector2(1010, 235)},
		{"name": "老人房", "point": Vector2(1260, 585)},
		{"name": "一楼楼梯", "point": Vector2(1010, 570)},
		{"name": "前院", "point": Vector2(790, 915)},
	]
	_assert_floor_routes(world, 1, Vector2(790, 735), floor_one)
	_assert_direct_gap(world, 1, Vector2(500, 600), "车库通往客厅的门洞")

	var floor_two := [
		{"name": "主卧", "point": Vector2(650, 300)},
		{"name": "大孩子房", "point": Vector2(940, 245)},
		{"name": "小孩子房", "point": Vector2(1260, 520)},
		{"name": "二楼厕所", "point": Vector2(1260, 245)},
		{"name": "公共阳台", "point": Vector2(300, 650)},
	]
	_assert_floor_routes(world, 2, Vector2(1000, 690), floor_two)

	var store := [
		{"name": "主食货架", "point": Vector2(405, 345)},
		{"name": "蔬菜货架", "point": Vector2(800, 345)},
		{"name": "日用品货架", "point": Vector2(1195, 345)},
		{"name": "电池货架", "point": Vector2(405, 600)},
		{"name": "饮料冷柜", "point": Vector2(800, 600)},
		{"name": "收银台", "point": Vector2(1115, 770)},
	]
	_assert_floor_routes(world, 3, Vector2(800, 810), store)
	world.queue_free()


func _assert_floor_routes(world: Node, floor_number: int, start: Vector2, targets: Array) -> void:
	var obstacles := _obstacles_for_floor(world, floor_number)
	for target in targets:
		if not _can_reach_near(start, target.point, obstacles):
			failures.append("%d层无法从出生点到达%s附近" % [floor_number, str(target.name)])


func _assert_direct_gap(world: Node, floor_number: int, point: Vector2, label: String) -> void:
	for obstacle in _obstacles_for_floor(world, floor_number):
		if obstacle.has_point(point):
			failures.append("%s仍被碰撞体遮挡" % label)
			return


func _obstacles_for_floor(world: Node, floor_number: int) -> Array[Rect2]:
	var result: Array[Rect2] = []
	for wall in world._walls_for_floor(floor_number):
		result.append((wall as Rect2).grow(PLAYER_CLEARANCE))
	for furniture in world._furniture_for_floor(floor_number):
		if bool(furniture.get("solid", true)):
			var rect: Rect2 = furniture.rect
			result.append(rect.grow(PLAYER_CLEARANCE))
	return result


func _can_reach_near(start: Vector2, target: Vector2, obstacles: Array[Rect2]) -> bool:
	var start_cell := Vector2i(roundi(start.x / GRID_STEP), roundi(start.y / GRID_STEP))
	var frontier: Array[Vector2i] = [start_cell]
	var visited: Dictionary = {start_cell: true}
	var directions := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	while not frontier.is_empty():
		var cell: Vector2i = frontier.pop_front()
		var point := Vector2(cell) * GRID_STEP
		if point.distance_to(target) <= 72.0:
			return true
		for direction in directions:
			var next_cell: Vector2i = cell + direction
			if visited.has(next_cell):
				continue
			var next_point := Vector2(next_cell) * GRID_STEP
			if not _is_walkable(next_point, obstacles):
				continue
			visited[next_cell] = true
			frontier.append(next_cell)
	return false


func _is_walkable(point: Vector2, obstacles: Array[Rect2]) -> bool:
	if point.x < PLAYER_CLEARANCE or point.y < PLAYER_CLEARANCE:
		return false
	if point.x > 1600.0 - PLAYER_CLEARANCE or point.y > 1100.0 - PLAYER_CLEARANCE:
		return false
	for obstacle in obstacles:
		if obstacle.has_point(point):
			return false
	return true


func _test_inventory_interfaces() -> void:
	game_state.reset_prologue()
	var packed: PackedScene = load("res://scenes/main.tscn")
	var main: Node = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var hud: Node = main.get_node("HUD")

	main._open_shop_shelf("shelf_food")
	_assert(bool(hud.is_item_grid_open()), "货架物品格未打开")
	_assert(hud.item_grid.get_child_count() == 3, "主食货架没有显示3种图标商品")
	main._on_item_grid_item_selected("rice")
	_assert(game_state.shopping_cart == ["rice"], "点击大米图标后未加入购物篮")

	main._open_checkout()
	_assert(hud.item_grid_title.text == "后备箱购物篮", "收银台未打开后备箱购物篮")
	_assert(hud.item_grid.get_child_count() == game_state.trunk_capacity, "大米占2格时购物篮没有正确显示10格容量")
	main._on_item_grid_item_selected("rice")
	_assert(game_state.shopping_cart.is_empty(), "点击购物篮中的大米后未放回")

	main._open_home_container("fridge")
	_assert(hud.item_grid_title.text == "冰箱", "冰箱没有打开独立物品栏")
	_assert(hud.item_grid.get_child_count() == 12, "冰箱物品栏没有显示12格")

	main._open_personal_inventory()
	_assert(hud.item_grid_title.text == "随身背包", "B键背包界面没有正确标题")
	_assert(hud.item_grid.get_child_count() == game_state.personal_capacity, "随身背包不是6格")
	main.queue_free()
	await process_frame


func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
