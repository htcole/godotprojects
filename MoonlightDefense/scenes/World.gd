extends Node2D


var conf = {}

var resources = {}
var game = null
var object_type_map = {}
var object_class_map = {}
var mouse_down = false
var pos_drag_start = null
var dragging = false

onready var map = find_node("Map")
onready var button_cover = find_node("ButtonCover")
onready var drag_rect = find_node("DragRect")


func set_view(pos, size):
	pass


func new_object(object):
	if not object_type_map.has(object.get_type()):
		object_type_map[object.get_type()] = []
	object_type_map[object.get_type()].append(object)

	if not object_class_map.has(object.get_class()):
		object_class_map[object.get_class()] = []
	object_class_map[object.get_class()].append(object)


func remove_object(object):
	remove_child(object)
	object_type_map.get(object.get_type(), []).erase(object)
	object_class_map.get(object.get_class(), []).erase(object)
	
	game.remove_object(object)
	game.check_game_over()


func setup_buildings():
	for building_conf in conf.BUILDINGS_START:
		var building = Global.Building.instance()
		add_child(building)
		building.init(game, game, {
			"type": building_conf.type,
			"team": 0,
			"hp_max": Global.building_types_conf[building_conf.type]["HP_MAX"],
			"speed": 0,
			"size": Vector2(100,100),
			"population": Global.building_types_conf[building_conf.type]["POPULATION"],
			"build_options": Global.building_types_conf[building_conf.type]["BUILD_OPTIONS"]
		})
		building.position = building_conf.pos * (game.get_map_size() - building.get_size())
		building.set_complete(true)
		building.set_hp_to_full()
		building._update()
		new_object(building)


func setup_workers():
	for unit_type in conf.UNITS_START.keys():
		for i in range(conf.UNITS_START[unit_type]):
			var unit = Global.Unit.instance()
			add_child(unit)
			unit.init(game, self, {
				"type": unit_type,
				"team": 0,
				"hp_max": Global.unit_types_conf[unit_type]["HP_MAX"],
				"speed": Global.unit_types_conf[unit_type]["SPEED"],
				"size": Global.unit_types_conf[unit_type]["SIZE"],
				"capacity": Global.unit_types_conf[unit_type]["CAPACITY"],
				"gather_rate": Global.unit_types_conf[unit_type]["GATHER_RATE"],
				"build_rate": Global.unit_types_conf[unit_type]["BUILD_RATE"],
				"build_options": Global.unit_types_conf[unit_type]["BUILD_OPTIONS"],
				"attack": Global.unit_types_conf[unit_type]["ATTACK"],
				"range": Global.unit_types_conf[unit_type]["RANGE"]
			})
			unit.position = game.get_map_size() * 0.5 + Vector2(200,0).rotated(randf() * 2 * PI) - unit.get_size() * 0.5
			unit._update()
			new_object(unit)


func setup():
	button_cover.rect_size = conf.MAP_CONF.SIZE
	map.init(self, conf.MAP_CONF)
	setup_buildings()
	setup_workers()
	resources = conf.RESOURCES_START.duplicate()
	drag_rect.visible = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(game_in, conf_in):
	game = game_in
	conf = conf_in
	print("World.init")
	setup()


func get_game():
	return(game)


func get_map():
	return(map)


func get_resources():
	return(resources)


func get_nearest(type, pos):
	var nearest = null
	var dist_best = INF
	for object in object_type_map.get(type, []):
		var dist_curr = object.get_position().distance_to(pos)
		if dist_curr < dist_best:
			dist_best = dist_curr
			nearest = object
	return(nearest)



func get_objects_type_team(type, team):
	var objects = []
	for object in object_type_map.get(type, []):
		if object.get_team() == team:
			objects.append(object)
	return(objects)


func get_object_count_type_team(type, team):
	return(get_objects_type_team(type, team).size())


func get_objects_class_team(class_str, team):
	var objects = []
	for object in object_class_map.get(class_str, []):
		if object.get_team() == team:
			objects.append(object)
	return(objects)


func get_object_count_class_team(class_str, team):
	return(get_objects_class_team(class_str, team).size())


func get_nearest_class_team(class_str, team, pos):
	var nearest = null
	var dist_best = INF
	for unit in get_objects_class_team(class_str, team):
		if unit.get_team() != team:
			continue
		var dist_curr = unit.get_position().distance_to(pos)
		if dist_curr < dist_best:
			dist_best = dist_curr
			nearest = unit
	return(nearest)


func get_nearest_unit(team, pos):
	var nearest = null
	var dist_best = INF
	for unit in object_class_map.get("UNIT", []):
		if unit.get_team() != team:
			continue
		var dist_curr = unit.get_position().distance_to(pos)
		if dist_curr < dist_best:
			dist_best = dist_curr
			nearest = unit
	return(nearest)


func get_enemy_count():
	return(get_object_count_class_team("UNIT", 1))


func get_queued_units_count():
	var units_queued = 0
	for building in get_objects_class_team("BUILDING", 0):
		units_queued += building.get_queued_units_count()
	return(units_queued)


func get_population_curr():
	var units_completed = get_object_count_class_team("UNIT", 0)
	var units_queued = get_queued_units_count()
	return(units_completed + units_queued)


func get_population_limit_curr():
	var pop_limit = 0
	for building in get_objects_class_team("BUILDING", 0):
		if building.get_complete():
			pop_limit += building.get_population()
	return(pop_limit)


func get_units_in_rect_team(rect: Rect2, team):
	var units_select = []
	for unit in get_objects_class_team("UNIT", team):
		if rect.has_point(unit.get_center()):
			units_select.append(unit)
	return(units_select)


func reached_population_limit():
	return(get_population_curr() >= get_population_limit_curr())


func get_idle_workers() -> Array:
	var workers_idle = []
	var workers = get_objects_type_team("WORKER", 0)
	for worker in workers:
		if worker.is_idle():
			workers_idle.append(worker)
	return(workers_idle)


func deposit_resource(gathered):
	resources[gathered.resource] += gathered.amount


func has_resources(cost):
	for resource_type in cost.keys():
		if resources[resource_type] < cost[resource_type]:
			return(false)
	return(true)


func reduce_resources(cost):
	if not has_resources(cost):
		return(false)
	for resource_type in cost.keys():
		resources[resource_type] -= cost[resource_type]
	return(true)


# Use gui_input so right click can be detected
func _on_ButtonCover_gui_input(event):
#	if event is InputEventMouseButton and event.pressed:
#		print("World._on_ButtonCover_gui_input.pressed")
#		game.map_click(get_local_mouse_position())
	pass


func _on_ButtonCover_pressed():
	if not dragging:
		print("World._on_ButtonCover_pressed")
		game.map_click(get_local_mouse_position())


func show_drag_rect(pos1, pos2):
	var rect = Rect2(pos1, Vector2(1,1)).expand(pos2)
	drag_rect.rect_position = rect.position
	drag_rect.rect_size = rect.size
	drag_rect.visible = true


func hide_drag_rect():
	drag_rect.visible = false


func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			#print("World._input: Mouse down")
			mouse_down = true
			pos_drag_start = get_local_mouse_position()
		else:
			#print("World._input: Mouse up")
			mouse_down = false
			var pos_drag_end = get_local_mouse_position()
			if pos_drag_end != pos_drag_start:
				print("World._input: drag end")
				game.select_units_drag(pos_drag_start, pos_drag_end)
				dragging = false
				#print("World._input: Setting input as handled")
				#get_tree().set_input_as_handled()
			hide_drag_rect()
	
	if event is InputEventMouseMotion and mouse_down:
		print("World._input: dragging")
		dragging = true
		show_drag_rect(pos_drag_start, get_local_mouse_position())












