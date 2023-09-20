extends Node2D


var conf = {}

var complete = true
var busy = false
var hp_curr = 0
var gathered = null
var listener = null
var world = null
var task_queue = []
var task_queue_archive = null
var selected = false
var alert = false
var sprite = null
var shot_ready = true
var attack_sound_enable = true
var mines_spawned = false


onready var highlight = $Highlight
onready var outline_alert = $OutlineAlert
onready var button_cover = $ButtonCover
onready var nav_agent = $NavigationAgent2D
onready var bodies = [find_node("ColorTeam0"), find_node("ColorTeam1")]
onready var node_sprite = find_node("NodeSprite")
onready var timer_alert = find_node("TimerAlert")
onready var timer_reload = find_node("TimerReload")
onready var timer_attack_sound = find_node("TimerAttackSound")


func setup():
	#print("Unit.setup: Setting size to: %s" % [conf.size])
	for sprite in node_sprite.get_children():
		sprite.visible = false
	sprite = find_node(conf.type)
	if sprite!=null:
		sprite.visible = true
	for i in range(bodies.size()):
		bodies[i].visible = (sprite==null) and (i==conf.team)
	highlight.rect_size = conf.size
	outline_alert.rect_size = conf.size
	button_cover.rect_size = conf.size
	hp_curr = conf.hp_max


func _update():
	z_index = position.y + get_size().y
	highlight.visible = selected
	outline_alert.visible = alert


func show_alert():
	alert = true
	timer_alert.start()
	_update()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(listener_in, world_in, conf_in):
	listener = listener_in
	world = world_in
	conf = conf_in
	
	setup()
	_update()


func get_class():
	return("UNIT")


func get_type():
	return(conf.type)


func get_team():
	return(conf.team)


func get_size():
	return(conf.size)


func get_position():
	return(position)


func get_rect() -> Rect2:
	return(Rect2(get_position(), get_size()))


func get_center():
	return(get_position() + 0.5 * get_size())


func get_hp_curr():
	return(hp_curr)


func get_hp_max():
	return(conf.hp_max)


func get_attack():
	return(conf.get("attack",0))


func get_gathered():
	return(gathered)


func get_build_options():
	return(conf.build_options)


func get_complete():
	return(complete)


func set_selected(selected_in):
	selected = selected_in
	_update()


func is_busy():
	return(busy)


func is_idle():
	return(task_queue.size()==0)


func take_damage(damage_in):
	var damage_actual = min(get_hp_curr(), damage_in)
	hp_curr -= damage_actual
	if hp_curr==0:
		die()
	return


func die():
	if conf.team==0:
		AudioManager.play("PLAYER_UNIT_DEAD")
	else:
		spawn_magic_mines()
	world.remove_object(self)
	queue_free()


func spawn_magic_mines():
	if mines_spawned:
		return
		
	print("Unit.spawn_magic_mines")
	mines_spawned = true
	var magic_conf = Global.unit_types_conf[conf.type]["MAGIC_REWARD"]
	var mine_type = "MAGIC_FLOWER"
	for i in range(magic_conf.MINES):
		var amount = floor(rand_range(magic_conf.AMOUNT[0], magic_conf.AMOUNT[1]+1))
		var mine = Global.Mine.instance()
		world.add_child(mine)
		mine.init(world.get_game(), world, {
			"type": mine_type,
			"team": -1,
			"resource": Global.mine_types_conf[mine_type]["RESOURCE"],
			"amount_start": amount,
			"size": Global.mine_types_conf[mine_type]["SIZE"]
		})
		mine.position = get_position() + Vector2(100,100) * Vector2(randf()-0.5,randf()-0.5)
		mine._update()
		world.new_object(mine)


func updated_gathered(gathered_curr):
	if gathered==null or gathered.resource!=gathered_curr.resource:
		gathered = gathered_curr
	else:
		gathered.amount += gathered_curr.amount


func add_task(task):
	task_queue.append(task)


func archive_tasks():
	task_queue_archive = task_queue
	task_queue = []


func resume_tasks():
	task_queue = task_queue_archive


func perform_task(task):
	task_queue.clear()
	task_queue.append(task)


func get_valid_mine(mine, mine_type):
	if is_instance_valid(mine):
		return(mine)
	var mine_new = world.get_nearest(mine_type, get_position())
	return(mine_new)


func animate(pos_delta):
	if sprite==null:
		return
	if pos_delta==null:
		#sprite.animation = "down"
		sprite.stop()
	else:
		var animation = "down"
		if abs(pos_delta.x) > abs(pos_delta.y):
			animation = "right" if pos_delta.x > 0 else "left"
		else:
			animation = "down" if pos_delta.y > 0 else "up"
		sprite.animation = animation
		sprite.play()


func move_towards(pos_target, delta):
	var pos_delta = position.direction_to(pos_target) * delta * conf.speed
	position += pos_delta
	animate(pos_delta)


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
	world.add_child(projectile)
	projectile.init(get_center(), pos_target, Global.unit_types_conf[conf.type]["PROJECTILE"], false)
	timer_reload.start()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if task_queue.size()==0:
		if get_team()==0 and get_attack()>0:
			var target = world.get_nearest_unit(1, get_position())
			if target!=null and target.get_position().distance_to(get_position()) < Global.game_conf.ATTACK_PROXIMITY:
				perform_task({
					"type": "ATTACK",
					"target": target
				})
		return
	
	var task = task_queue[0]
	match task.type:
		"MOVE_TO":
			if position.distance_to(task.pos) <= 10:
				task_queue.pop_front()
				animate(null)
			else:
				move_towards(task.pos, delta)
		"GATHER":
			if gathered==null or gathered.resource!=task.resource:
				gathered = {
					"resource": task.resource,
					"amount": 0
				}
			if gathered.amount >= conf.capacity:
				# Deposit at nearest town center
				var town_center = world.get_nearest("TOWN_CENTER", get_position())
				if not get_rect().intersects(town_center.get_rect()):
					# Move towards nearest town center
					move_towards(town_center.get_position(), delta)
				else:
					# Deposit reource
					world.deposit_resource(gathered)
					gathered.amount = 0
					animate(null)
			else:
				# Mine resource
				task.mine = get_valid_mine(task.mine, task.mine_type)
				if not is_instance_valid(task.mine):
					task_queue.pop_front()
					animate(null)
				else:
					if not get_rect().intersects(task.mine.get_rect()):
						# Move towards mine
						move_towards(task.mine.get_position(), delta)
					else:
						# Gather resource
						var gather_attempt = min(conf.gather_rate * delta, conf.capacity-gathered.amount)
						var gathered_curr = task.mine.gather(gather_attempt)
						updated_gathered(gathered_curr)
						animate(null)
		"BUILD":
			if not is_instance_valid(task.building):
				task_queue.pop_front()
				animate(null)
			else:
				if not get_rect().intersects(task.building.get_rect()):
					move_towards(task.building.get_position(), delta)
				else:
					animate(null)
					if task.building.get_hp_curr()==task.building.get_hp_max():
						task_queue.pop_front()
					else:
						var build_attempt = min(conf.build_rate * delta, task.building.get_hp_max()-task.building.get_hp_curr())
						task.building.build(build_attempt)
		"ATTACK":
			if not is_instance_valid(task.target):
				task_queue.pop_front()
				animate(null)
			else:
				if (conf.range==0 and not get_rect().intersects(task.target.get_rect())) or \
					(conf.range>0 and get_position().distance_to(task.target.get_position())>conf.range):
					move_towards(task.target.get_position(), delta)
				else:
					animate(null)
					var damage = conf.attack * delta
					task.target.take_damage(damage)
					attack_sound()
					if conf.range>0:
						fire_projectile_at(task.target.get_center())
	
	_update()


func _on_ButtonCover_pressed():
	print("Unit._on_ButtonCover_pressed")
	listener.object_click(self)


func _on_TimerReload_timeout():
	shot_ready = true


func _on_TimerAttackSound_timeout():
	attack_sound_enable = true


func _on_TimerAlert_timeout():
	alert = false
	_update()




















