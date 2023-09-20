extends Node


var enemies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_enemies() -> Array:
	return(enemies)


func spawn_enemies(game, day):
	var map_size = Global.game_conf.WORLD_CONF.MAP_CONF.SIZE
	enemies = []
	var enemies_conf = Global.game_conf.ENEMY_CONF[day-1]
	for enemy_type in enemies_conf.keys():
		var n_enemy = enemies_conf[enemy_type]
		for i in range(n_enemy):
			var enemy = Global.Unit.instance()
			game.get_world().add_child(enemy)
			enemy.init(game, game.get_world(), {
				"type": enemy_type,
				"team": 1,
				"hp_max": Global.unit_types_conf[enemy_type]["HP_MAX"],
				"speed": Global.unit_types_conf[enemy_type]["SPEED"],
				"size": Global.unit_types_conf[enemy_type]["SIZE"],
				"attack": Global.unit_types_conf[enemy_type]["ATTACK"],
				"range": Global.unit_types_conf[enemy_type]["RANGE"],
				"build_options": Global.unit_types_conf[enemy_type]["BUILD_OPTIONS"]
			})
			enemy.position = get_random_border_position(map_size - enemy.get_size())
			#enemy.position = game.get_world().get_map().get_random_land_pos(enemy.get_size())
			enemies.append(enemy)
			game.get_world().new_object(enemy)


func get_random_border_position(size):
	var rand_pos_norm = [randf(), randf()]
	var rand_bit = randi() % 2
	var rand_val = randi() % 2
	rand_pos_norm[rand_bit] = rand_val
	var rand_pos = Vector2(rand_pos_norm[0], rand_pos_norm[1]) * size
	return(rand_pos)



func clear_enemies(game):
	var enemies = game.get_world().get_objects_class_team("UNIT", 1)
	for enemy in enemies:
		game.get_world().remove_object(enemy)
		enemy.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
