extends Node2D


var world = null
var conf = {}


onready var land = find_node("Land")
onready var water = find_node("Water")
onready var nav_poly = find_node("NavigationPolygonInstance")

var nav_map
var nav_region


func get_random_land_pos(offset):
	return(land.rect_position + (land.rect_size - offset) * Vector2(randf(), randf()))


func setup():
	water.rect_size = conf.SIZE
	land.rect_size = conf.SIZE - 2 * Vector2(conf.WATER_WIDTH, conf.WATER_WIDTH)
	land.rect_position = Vector2(conf.WATER_WIDTH, conf.WATER_WIDTH)
	for mine_type in conf.MINE_CONF.keys():
		var mine_type_conf = conf.MINE_CONF[mine_type]
		var n_clust = floor(rand_range(mine_type_conf.clusters[0], mine_type_conf.clusters[1]+1))
		var map_center = conf.SIZE * 0.5
		var radius = min(land.rect_size.x, land.rect_size.y) * 0.5
		var radius_step = radius / (n_clust+1)
		for i_clust in range(n_clust):
			var clust_center = null
			if i_clust < 2:
				clust_center = map_center + Vector2(1,0).rotated(randf()*2*PI) * radius_step * (i_clust+1)
			else:
				clust_center = get_random_land_pos(Vector2(200,200)) + Vector2(100,100)
			var n_mines = floor(rand_range(mine_type_conf.mines[0], mine_type_conf.mines[1]+1))
			for i_mine in range(n_mines):
				var amount = floor(rand_range(mine_type_conf.amount[0], mine_type_conf.amount[1]+1))
				var mine = Global.Mine.instance()
				world.add_child(mine)
				mine.init(world.get_game(), world, {
					"type": mine_type,
					"team": -1,
					"resource": Global.mine_types_conf[mine_type]["RESOURCE"],
					"amount_start": amount,
					"size": Global.mine_types_conf[mine_type]["SIZE"]
				})
				mine.position = clust_center + Vector2(100,100) * Vector2(randf()-0.5,randf()-0.5)
				mine._update()
				world.new_object(mine)

	_setup_navigation()


func _setup_navigation():
	nav_map = Navigation2DServer.map_create()
	nav_region = Navigation2DServer.region_create()
	
	Navigation2DServer.region_set_navpoly(nav_region, nav_poly.navpoly)
	Navigation2DServer.region_set_map(nav_region, nav_map)
	Navigation2DServer.map_set_active(nav_map, true)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(world_in, conf_in):
	world = world_in
	conf = conf_in
	print("Map.init")
	setup()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
