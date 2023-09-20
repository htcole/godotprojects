extends Node


class_name PlayerController


var game = null
var team = 0
var curr_selected = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(game_in, team_in):
	game = game_in
	team = team_in


func select_object(target):
	AudioManager.play("GAME_OBJECT_SELECT")
	print("PlayerController.select_object: %s" % [target.get_type()])
	if curr_selected.size()>0:
		print("PlayerController.select_object: Check multi-select")
		if not game.get_multi_select() or \
			curr_selected[0].get_class()!=target.get_class() or \
			curr_selected[0].get_team()!=target.get_team():
			deselect_object()
	curr_selected.append(target)
	curr_selected.back().set_selected(true)
	game.set_curr_selected(curr_selected[0])


func select_objects(objects):
	deselect_object()
	for object in objects:
		curr_selected.append(object)
		object.set_selected(true)


func get_curr_selected():
	return(curr_selected)


func deselect_object():
	for object in curr_selected:
		if is_instance_valid(object):
			object.set_selected(false)
	curr_selected = []
	game.set_curr_selected(null)


func remove_object(object):
	curr_selected.erase(object)


func issue_task(task, curr_selected):
	AudioManager.play("UNIT_ACK")
	for object in curr_selected:
		object.perform_task(task)


func object_click(target):
	if curr_selected.size()==0:
		select_object(target)
		return
	
	if game.get_multi_select():
		select_object(target)
		return
	
	var select_new = true
	for assignee in curr_selected:
		if assignee.get_team()==0 and assignee.get_class()=="UNIT":
			if assignee.get_type() == "WORKER":
				match target.get_class():
					"MINE":
						var task = {
							"type": "GATHER",
							#"pos": path[0]
							"mine_type": target.get_type(),
							"resource": target.get_resource(),
							"mine": target
						}
						print("PlayerController.object_click: Issuing task: ", task)
						issue_task(task, [assignee])
						select_new = false
					"BUILDING":
						if not target.get_complete():
							var task = {
								"type": "BUILD",
								"building": target
							}
							print("PlayerController.object_click: Issuing task: ", task)
							issue_task(task, [assignee])
							select_new = false
			elif assignee.get_attack()>0:
				if target.get_team()==1:
					var task = {
						"type": "ATTACK",
						"target": target
					}
					print("PlayerController.object_click: Issuing task: ", task)
					issue_task(task, [assignee])
					select_new = false
	
	deselect_object()
	if select_new:
		select_object(target)


func map_click(pos, nav_map):
	for object in curr_selected:
		if object.get_team()==0 and object.get_class()=="UNIT":
			#var from = curr_selected[0].position
#			var path = Navigation2DServer.map_get_path(
#				nav_map,
#				from,
#				pos,
#				true
#			)
#			path.remove(0)
			
			var task = {
				"type": "MOVE_TO",
				#"pos": path[0]
				"pos": pos - object.get_size() * 0.5 + Vector2(rand_range(-50,50), rand_range(-50,50))
			}
			print("PlayerController.map_click: Issuing task: ", task)
			issue_task(task, [object])
			
		deselect_object()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(game, delta):
	pass

















