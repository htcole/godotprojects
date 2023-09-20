extends Node2D

var conf = {}

var task_queue = []
var busy = false
var complete = false
var hp_curr = 0
var listener = null
var game = null
var size = Vector2(100,100)
var selected = false
var alert = false
var curr_task_time = 0
var attack_sound_enable = true
var shot_ready = true


onready var highlight = find_node("Highlight")
onready var outline_alert = find_node("OutlineAlert")
onready var button_cover = find_node("ButtonCover")
onready var icons = find_node("Icons")
onready var timer_task = find_node("TimerTask")
onready var timer_alert = find_node("TimerAlert")
onready var timer_generate = find_node("TimerGenerate")
onready var timer_attack_sound = find_node("TimerAttackSound")
onready var timer_reload = find_node("TimerReload")


func setup():
	for icon in icons.get_children():
		icon.visible = false
	var icon = find_node(conf.type)
	icon.visible = true
	#if conf.size:
	#	size = conf.size
	
	#print("Mine.setup: Setting size to: %s" % [size])
	size = icon.rect_size * icon.rect_scale
	button_cover.rect_size = size
	highlight.rect_size = size
	outline_alert.rect_size = size
	#hp_curr = conf.hp_max


func _update():
	z_index = position.y + get_size().y
	highlight.visible = selected
	outline_alert.visible = alert


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(listener_in, game_in, conf_in):
	listener = listener_in
	game = game_in
	conf = conf_in
	
	setup()
	_update()


func get_class():
	return("BUILDING")


func get_type():
	return(conf.type)


func get_team():
	return(conf.team)


func get_size():
	return(size)


func get_position():
	return(position)


func get_rect() -> Rect2:
	return(Rect2(get_position(), get_size()))


func get_center():
	return(get_position() + 0.5 * get_size())


func get_hp_curr():
	return(hp_curr)


func set_hp_to_full():
	hp_curr = conf.hp_max


func get_hp_max():
	return(conf.hp_max)


func get_population():
	return(conf.population)


func set_selected(selected_in):
	selected = selected_in
	_update()


func get_complete():
	return(complete)


func set_complete(complete_in):
	complete = complete_in


func is_busy():
	return(busy)


func get_building_curr():
	return("" if not is_busy() else task_queue[0].unit)


func get_curr_task_fraction():
	var frac = 1 - timer_task.time_left/curr_task_time if is_busy() else 1
	return(frac)


func get_build_options():
	return(conf.build_options)


func get_queued_units_count():
	return(task_queue.size())


func build(build_amount):
	var build_amount_actual = min(build_amount, get_hp_max()-get_hp_curr())
	hp_curr += build_amount_actual
	if get_hp_curr()==get_hp_max():
		set_complete(true)
		AudioManager.play("BUILDING_READY")
		alert = true
		timer_alert.start()
		timer_generate.start()
	_update()


func perform_task(task):
	task_queue.clear()
	task_queue.append(task)


func take_damage(damage_in):
	var damage_actual = min(get_hp_curr(), damage_in)
	hp_curr -= damage_actual
	if hp_curr==0:
		AudioManager.play("BUILDING_DESTROYED")
		game.get_world().remove_object(self)
		queue_free()
	return


# 
func _on_ButtonCover_pressed():
	print("Building._on_ButtonCover_pressed")
	_update()
	listener.object_click(self)


func complete_task(task):
	create_unit(task.unit)
	task_queue.erase(task)
	busy = false


func generate():
	if conf.type == "TEMPLE":
		game.get_world().deposit_resource({
			"resource": "MAGIC",
			"amount": 1
		})


func create_unit(unit_type):
	AudioManager.play("UNIT_CREATED")
	var unit = Global.Unit.instance()
	game.get_world().add_child(unit)
	unit.init(game, game.get_world(), {
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
	game.get_world().new_object(unit)
	unit.position = get_position() + get_size() * 0.5 - unit.get_size() * 0.5 + Vector2(150,0).rotated(randf()*PI*2)
	unit.show_alert()
	unit._update()


func attack_sound():
	if conf.team==0 and attack_sound_enable:
		AudioManager.play("PLAYER_ATTACK")
		attack_sound_enable = false
		timer_attack_sound.start()


func fire_projectile_at(pos_target):
	if not shot_ready:
		return
	shot_ready = false
	var projectile = Global.Projectile.instance()
	game.get_world().add_child(projectile)
	projectile.init(get_center(), pos_target, Global.building_types_conf[conf.type]["PROJECTILE"], false)
	timer_reload.start()


func attack(delta):
	if not get_complete():
		return
	var attack = Global.building_types_conf[conf.type].get("ATTACK", 0)
	if attack<=0:
		return
	var range_dist = Global.building_types_conf[conf.type].get("RANGE", 0)
	var target = game.get_world().get_nearest_unit(1, get_position())
	if not is_instance_valid(target):
		return
	if get_center().distance_to(target.get_center()) > range_dist:
		return
	var damage = attack * delta
	target.take_damage(damage)
	attack_sound()
	fire_projectile_at(target.get_center())



func _process(delta):
	attack(delta)
	
	if task_queue.size()==0 or task_queue[0].get("doing",false):
		return
	
	var task = task_queue[0]
	match task.type:
		"BUILD":
			task.doing = true
			busy = true
			curr_task_time = Global.unit_types_conf[task.unit]["BUILD_TIME"]
			timer_task.start(curr_task_time)
	
	_update()


func _on_TimerTask_timeout():
	complete_task(task_queue[0])


func _on_TimerAlert_timeout():
	alert = false
	_update()


func _on_TimerGenerate_timeout():
	generate()


func _on_TimerAttackSound_timeout():
	attack_sound_enable = true


func _on_TimerReload_timeout():
	shot_ready = true















