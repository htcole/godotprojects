extends MarginContainer


var day = 1
var phase = 0

var town_bell_active = false
var is_multi_select = false
var conf = Global.game_conf
var curr_selected = null
var building_tentative = null
var worker_to_build = null

var controllers = []

var key_press_action_map = {
	KEY_I: "select_next_idle_worker",
	KEY_C: "cancel_selection",
	KEY_B: "ring_town_bell",
	KEY_SHIFT: "start_multi_select",
	KEY_SPACE: "pause_game",
	KEY_W: "scroll_up_begin",
	KEY_S: "scroll_down_begin",
	KEY_A: "scroll_left_begin",
	KEY_D: "scroll_right_begin",
	KEY_UP: "scroll_up_begin",
	KEY_DOWN: "scroll_down_begin",
	KEY_LEFT: "scroll_left_begin",
	KEY_RIGHT: "scroll_right_begin",
}

var key_release_action_map = {
	KEY_SHIFT: "end_multi_select",
	KEY_W: "scroll_up_end",
	KEY_S: "scroll_down_end",
	KEY_A: "scroll_left_end",
	KEY_D: "scroll_right_end",
	KEY_UP: "scroll_up_end",
	KEY_DOWN: "scroll_down_end",
	KEY_LEFT: "scroll_left_end",
	KEY_RIGHT: "scroll_right_end",
}


func scroll_up_begin():
	world_scroller.scroll_top = true

func scroll_up_end():
	world_scroller.scroll_top = false

func scroll_down_begin():
	world_scroller.scroll_bottom = true

func scroll_down_end():
	world_scroller.scroll_bottom = false

func scroll_left_begin():
	world_scroller.scroll_left = true

func scroll_left_end():
	world_scroller.scroll_left = false

func scroll_right_begin():
	world_scroller.scroll_right = true

func scroll_right_end():
	world_scroller.scroll_right = false



func ring_town_bell():
	AudioManager.play("TOWN_BELL")
	var workers = world.get_objects_type_team("WORKER", 0)
	
	if not town_bell_active:
		town_bell_active = true
		var map_center = get_map_size() * Vector2(0.5,0.5)
		for worker in workers:
			var dir = map_center.direction_to(worker.get_center())
			var pos_target = map_center + 200 * dir
			var task = {
				"type": "MOVE_TO",
				"pos": pos_target
			}
			worker.archive_tasks()
			worker.perform_task(task)
	else:
		town_bell_active = false
		for worker in workers:
			worker.resume_tasks()




onready var world = find_node("World")
onready var world_panel = find_node("WorldPanel")
onready var info_panel = find_node("InfoPanel")
onready var resource_display = find_node("ResourceDisplay")
onready var label_phase = find_node("LabelPhase")
onready var timer_phase = find_node("TimerPhase")
onready var phase_progress_bar = find_node("PhaseProgressBar")
onready var world_scroller = find_node("WorldScroller")
onready var pause_menu = find_node("PauseMenu")
onready var moon = find_node("Moon")


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	init()
	timer_phase.set_wait_time(Global.game_conf.PHASE_DURATION)
	timer_phase.start()
	world_scroller.init(world)
	pause_menu.visible = false
	moon.visible = false
	if not AudioManager.is_playing("GAME_START"):
		AudioManager.play("GAME_START")
		#AudioManager.get_stream("GAME_START").connect("finished", self, "game_start_music_complete")
		yield(get_tree().create_timer(2), "timeout")
		AudioManager.stop("GAME_START")
		game_start_music_complete()
	#EnemyManager.spawn_enemies(self, day)


func game_start_music_complete():
	if not AudioManager.is_playing(Global.phase_music[phase]):
		AudioManager.play(Global.phase_music[phase])


func _update():
	label_phase.text = "Day %s of %s, %s" % [day, conf.N_DAYS, Global.phase_names[phase]]
	phase_progress_bar.value = 100 * ( 1 - timer_phase.time_left/Global.game_conf.PHASE_DURATION)
	info_panel.init(self, curr_selected)
	if is_instance_valid(building_tentative):
		building_tentative.position = world.get_local_mouse_position() + Vector2(3,3)


func init():
	print("Game.init")
	#world_panel.rect_min_size = conf.WORLD_CONF.MAP_CONF.SIZE
	world.init(self, conf.WORLD_CONF)
	resource_display.init(world)
	controllers = [PlayerController.new(), EnemyController.new()]
	for team in range(controllers.size()):
		controllers[team].init(self, team)
	_update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for controller in controllers:
		controller.process(self, delta)
	_update()


func get_world():
	return(world)


func get_map_size():
	return(Global.game_conf.WORLD_CONF.MAP_CONF.SIZE)


func get_cost(object_class, object_type):
	var cost = null
	match object_class:
		"UNIT":
			cost = Global.unit_types_conf[object_type].COST
		"BUILDING":
			cost = Global.building_types_conf[object_type].COST
		_:
			cost = INF
	return(cost)


func can_afford(object_class, object_type):
	return(world.has_resources(get_cost(object_class, object_type)))


func set_curr_selected(target):
	curr_selected = target
	_update()


func object_click(target):
	if is_instance_valid(building_tentative):
		return
	print("Game.object_click")
	controllers[0].object_click(target)


func map_click(pos):
	if is_instance_valid(building_tentative):
		var cost = Global.building_types_conf[building_tentative.get_type()].COST
		if world.has_resources(cost):
			world.reduce_resources(cost)
			world.new_object(building_tentative)
			var task = {
				"type": "BUILD",
				#"pos": path[0]
				"building": building_tentative
			}
			print("Game.map_click: Issuing task: ", task)
			AudioManager.play("UNIT_ACK")
			worker_to_build.perform_task(task)
			controllers[0].deselect_object()
		building_tentative = null
	else:
		curr_selected = null
		controllers[0].map_click(pos, world.map.nav_map)


func select_to_build(building_type, worker):
	if is_instance_valid(building_tentative):
		building_tentative.queue_free()
	building_tentative = Global.Building.instance()
	worker_to_build = worker
	world.add_child(building_tentative)
	building_tentative.init(self, self, {
		"type": building_type,
		"team": 0,
		"hp_max": Global.building_types_conf[building_type]["HP_MAX"],
		"speed": 0,
		"size": Vector2(100,100),
		"population": Global.building_types_conf[building_type]["POPULATION"],
		"build_options": Global.building_types_conf[building_type]["BUILD_OPTIONS"]
	})
	_update()


func deselect_object():
	controllers[0].deselect_object()


func end_of_phase():
	AudioManager.stop(Global.phase_music[phase])
	phase = 1 - phase
	if phase==0:
		day += 1
		moon.visible = false
		EnemyManager.clear_enemies(self)
	else:
		moon.visible = true
		moon.show_phase(day)
		EnemyManager.spawn_enemies(self, day)
	_update()
	if day > conf.N_DAYS:
		game_over(0)
	else:
		AudioManager.play(Global.phase_music[phase])


func check_game_over():
	# Defeat condition
	var n_town_center = world.get_object_count_type_team("TOWN_CENTER", 0)
	if n_town_center==0:
		game_over(1)
		
	# Victory condition
	if day == conf.N_DAYS and phase==1:
		var enemy_count = world.get_object_count_class_team("UNIT", 1)
		print("Game.check_game_over: Enemy count: %s" % [enemy_count])
		if enemy_count==0:
			game_over(0)


func game_over(team):
	for phase in range(2):
		AudioManager.stop(Global.phase_music[phase])
	Global.game_res = {
		"team": team
	}
	get_tree().change_scene_to(Global.GameOver)


func _on_TimerPhase_timeout():
	end_of_phase()


func cancel_selection():
	controllers[0].deselect_object()


func select_next_idle_worker():
	print("Game.select_next_idle_worker")
	var workers_idle = world.get_idle_workers()
	print("Game.select_next_idle_worker: Idle workers: %s" % [workers_idle.size()])
	if workers_idle.size()==0:
		return
	var curr_selected = controllers[0].get_curr_selected()
	controllers[0].deselect_object()
	var target = null
	if curr_selected.size()>0 and curr_selected[0].get_type()=="WORKER":
		var ix = workers_idle.find(curr_selected[0])
		if ix < 0:
			target = workers_idle[0]
		else:
			var ix_select = (ix + 1) % workers_idle.size()
			target = workers_idle[ix_select]
	else:
		target = workers_idle[0]
	if target!=null:
		controllers[0].select_object(target)
		world_scroller.center_position(target.get_center())


func remove_object(object):
	controllers[0].remove_object(object)


func start_multi_select():
	print("Game.start_multi_select")
	is_multi_select = true


func end_multi_select():
	print("Game.end_multi_select")
	is_multi_select = false


func get_multi_select():
	return(is_multi_select)


func select_units_drag(pos_start, pos_end):
	var rect = Rect2(pos_start, Vector2(1,1)).expand(pos_end)
	var units = world.get_units_in_rect_team(rect, 0)
	controllers[0].select_objects(units)


func pause_game():
	if not pause_menu.visible and Input.is_action_just_pressed("ui_accept"):
		print("Game.pause_game")
		pause_menu.visible = true
		get_tree().paused = true


func _on_PauseMenu_resume():
	print("Game._on_PauseMenu_resume")
	pause_menu.visible = false
	get_tree().paused = false


func _on_PauseMenu_restart():
	pause_menu.visible = false
	get_tree().paused = false
	for phase in range(2):
		AudioManager.stop(Global.phase_music[phase])
	get_tree().change_scene_to(Global.Game)


func _input(event):
	if event is InputEventKey:
		var func_call = null
		if event.is_pressed():
			func_call = key_press_action_map.get(event.scancode, null)
		else:
			func_call = key_release_action_map.get(event.scancode, null)
		if func_call != null:
			call(func_call)












