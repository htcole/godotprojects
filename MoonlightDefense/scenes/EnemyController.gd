extends Node

class_name EnemyController


var game = null
var team = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(game_in, team_in):
	game = game_in
	team = team_in


# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(game, delta):
	var enemies = EnemyManager.get_enemies()
	if enemies.size()==0:
		return
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var target_unit = game.get_world().get_nearest_class_team("UNIT", 0, enemy.get_position())
		var target_building = game.get_world().get_nearest_class_team("BUILDING", 0, enemy.get_position())
		var target_select = target_unit
		if not is_instance_valid(target_unit):
			target_select = target_building
		else:
			if is_instance_valid(target_building):
				if target_building.get_position().distance_to(enemy.position) < target_unit.get_position().distance_to(enemy.position):
					target_select = target_building
		
		if is_instance_valid(target_select):
			var task = {
				"type": "ATTACK",
				"target": target_select
			}
			#print("EnemyController._process: Issuing task: ", task)
			enemy.perform_task(task)





