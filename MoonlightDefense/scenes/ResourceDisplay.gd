extends MarginContainer


var world = null


onready var grid_resources = find_node("GridResources")
onready var grid_stats = find_node("GridStats")


func _update():
	for child in grid_resources.get_children() + grid_stats.get_children():
		child.queue_free()
	var resources = world.get_resources()
	for resource_name in resources.keys():
		var label = Label.new()
		grid_resources.add_child(label)
		label.text = "%s: %s" % [Global.get_display_str(resource_name), resources[resource_name]]
	
	var label_pop = Label.new()
	grid_stats.add_child(label_pop)
	label_pop.text = "%s: %s/%s" % ["Population", world.get_population_curr(), world.get_population_limit_curr()]
	var label_enemies = Label.new()
	grid_stats.add_child(label_enemies)
	label_enemies.text = "%s: %s" % ["Enemies", world.get_enemy_count()]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(world_in):
	world = world_in
	_update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update()
