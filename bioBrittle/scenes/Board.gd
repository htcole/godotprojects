extends Node2D



# Vars
var game = null;
var cell_size = null;
var grid_size = null;

var tiles = [];
var tile_hover = null;
var tiles_location = [];


func make_hover_tile():
	tile_hover = Global.Tile.instance();
	add_child(tile_hover);
	tile_hover.visible = false;
	tile_hover.z_index = 1;
	tile_hover.modulate = Color(1,1,1,0.7);


# Called when the node enters the scene tree for the first time.
func _ready():
	make_hover_tile();


func init(game_in, cell_size_in, grid_size_in):
	game = game_in;
	cell_size = cell_size_in;
	grid_size = grid_size_in;


func get_bounds():
	var point_max = cell_size * grid_size;
	return({"x":[0,point_max.x], "y":[0,point_max.y]});


func get_game_bounds():
	game.get_bounds();


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func normalize_pos(pos_actual):
	var grid_pos_f = pos_actual/cell_size;
	var grid_pos = Vector2(floor(grid_pos_f.x), floor(grid_pos_f.y));
	var cell_pos = grid_pos * cell_size;
	return(cell_pos);


func is_any_tile_at(pos_cell):
	return(get_tile_at(pos_cell)!=null);


func get_tile_at(pos_cell):
	for tile in tiles:
		if tile.position==pos_cell:
			return(tile);
	return(null);


func get_tile_count():
	return(tiles.size());


func get_adj_tiles_at(pos_cell):
	return(get_tile_neighbors_at(pos_cell, false));


func get_adj_tiles_to(tile):
	return(get_tile_neighbors_at(tile.position, false));


func get_tile_neighbors_at(pos_cell, include_corners):
	var dist_factor = 1.5 if include_corners else 1.0;
	var tile_neighbors = [];
	for tile_new in tiles:
		if tile_new.position!=pos_cell and tile_new.position.distance_to(pos_cell)<=(cell_size.x*dist_factor):
			tile_neighbors.append(tile_new);
	return(tile_neighbors);


func get_tile_neighbors(tile, include_corners):
	return(get_tile_neighbors_at(tile.position, include_corners));


func is_any_tile_adj_to(pos_cell):
	return(get_adj_tiles_at(pos_cell).size()>0);


func validate_placement_reqs(tile_selected, pos_cell, include_corners):
	var tiles_adj = get_tile_neighbors_at(pos_cell, include_corners);
	var tiles_adj_types = [];
	for tile in tiles_adj:
		tiles_adj_types.append(tile.get_type());
	
	var neighbors_req_valid = true;
	var neighbors_req = TileManager.get_tile_conf(tile_selected).get("neighbors_req", []);
	for tile_group in neighbors_req:
		var group_valid = false;
		for tile in tile_group:
			if tiles_adj_types.has(tile):
				group_valid = true;
				break;
		if not group_valid:
			neighbors_req_valid = false;
			break;
	
	var neighbors_avoid_valid = true;
	var neighbors_avoid = TileManager.get_tile_conf(tile_selected).get("neighbors_avoid", []).duplicate();
	if Global.config.ENABLE_TERRAIN_PLACEMENT_REQS:
		neighbors_avoid = neighbors_avoid + TileManager.get_tile_conf(tile_selected).get("neighbors_avoid_terrain", []);
	for tile in neighbors_avoid:
		if tiles_adj_types.has(tile):
			neighbors_avoid_valid = false;
			break;
	
	var valid = neighbors_req_valid and neighbors_avoid_valid;
	return(valid);


func is_tile_req_satisfied(tile):
	if TileManager.is_tile_type_fixed(tile.type):
		return(true);
	
	var tile_adj_valid = (tiles.size()==1) or is_any_tile_adj_to(tile.position);
	var tile_connected_valid = not Global.config.MUST_CONNECT_START or get_tiles_reachable_from_start().has(tile);
	var neighbor_req_valid = validate_placement_reqs(tile.get_type(), tile.position, Global.config.ENABLE_CORNER_NEIGHBORS_PLACEMENT);
	return(tile_adj_valid and tile_connected_valid and neighbor_req_valid);


func can_place_tile(tile_selected, pos_in):
	if not TileManager.is_tile_placeable(tile_selected):
		return(false);
	
	var pos_cell = normalize_pos(pos_in);
	var can_place = tiles.size()==0 or (is_within_grid(pos_cell) and not is_any_tile_at(pos_cell) and is_any_tile_adj_to(pos_cell));
	
	if Global.config.ENABLE_PLACEMENT_REQS:
		can_place = can_place and validate_placement_reqs(tile_selected, pos_cell, Global.config.ENABLE_CORNER_NEIGHBORS_PLACEMENT);
	
	return(can_place);


func is_within_grid(pos_new):
	return(pos_new.x>=0 and pos_new.x<=(grid_size.x-1)*cell_size.x and pos_new.y>=0 and pos_new.y<=(grid_size.y-1)*cell_size.y);


func get_alive_tiles():
	var tiles_alive = [];
	for tile in tiles:
		if tile.is_alive() and not TileManager.is_tile_type_fixed(tile.get_type()):
			tiles_alive.append(tile);
	return(tiles_alive);


func get_start_tile():
	for tile in tiles:
		if tile.get_type()=="start":
			return(tile);
	return(null);


func get_end_tile():
	for tile in tiles:
		if tile.get_type()=="end":
			return(tile);
	return(null);


func get_tiles_reachable_from_start():
	var tile_start = get_start_tile();
	var tiles_queue = [tile_start];
	var tiles_reachable = [];
	while tiles_queue.size()>0:
		var tile_curr = tiles_queue.pop_front();
		tiles_reachable.append(tile_curr);
		var tile_neighbors = get_adj_tiles_to(tile_curr);
		for tile in tile_neighbors:
			if not tiles_reachable.has(tile) and not tiles_queue.has(tile):
				tiles_queue.append(tile);
	return(tiles_reachable);


func get_next_locs():
	var locs_next = [];
	var pos_delta_arr = [Vector2(cell_size.x,0), Vector2(-cell_size.x,0), Vector2(0,cell_size.y), Vector2(0,-cell_size.y)];
	if tiles.size()==0:
		locs_next.append(Vector2.ZERO);
	else:
		var must_connect_start = Global.config.GOAL_TYPE=="CONNECT" or Global.config.MUST_CONNECT_START;
		var tiles_candidate = get_tiles_reachable_from_start() if must_connect_start else tiles;
		for tile in tiles_candidate:
			for pos_delta in pos_delta_arr:
				var pos_new = tile.position + pos_delta;
				if not is_any_tile_at(pos_new) and not locs_next.has(pos_new) and is_within_grid(pos_new):
					locs_next.append(pos_new);
	return(locs_next);


func get_feasible_tiles():
	var tiles_feasible = [];
	var locs_next = get_next_locs();
	
	for tile_type in TileManager.get_tile_types():
		for loc in locs_next:
			if can_place_tile(tile_type, loc) and not tiles_feasible.has(tile_type):
				tiles_feasible.append(tile_type);
	
	return(tiles_feasible);


func add_tile(type, stats, pos):
	var cell_pos = normalize_pos(pos);
	var tile = Global.Tile.instance();
	tile.position = cell_pos;
	add_child(tile);
	tile.init(game, self, type, stats, true);
	tiles.append(tile);


func clear_hover():
	tile_hover.visible = false;


func show_hover(type, stats, pos, valid):
	tile_hover.init(game, self, type, stats, false);
	var cell_pos = normalize_pos(pos);
	tile_hover.position = cell_pos;
	tile_hover.set_invalid(not valid);
	tile_hover.visible = true;


func show_valid_locations(type):
	clear_valid_locations();
	var locs_next = get_next_locs();
	for loc in locs_next:
		if not can_place_tile(type, loc):
			continue;
		var tile = Global.Tile.instance();
		tile.position = loc;
		add_child(tile);
		tile.init(game, self, "", {}, false);
		tiles_location.append(tile);


func clear_valid_locations():
	for tile in tiles_location:
		tile.queue_free();
	tiles_location = [];


func remove_dead_tiles():
	var tiles_dead = [];
	for tile in tiles:
		if not tile.is_alive():
			tiles_dead.append(tile);
	for tile in tiles_dead:
		tiles.erase(tile);
		tile.queue_free();


func advance():
	for tile in tiles:
		tile.advance();
	if Global.config.REMOVE_DEAD_TILES:
		remove_dead_tiles();




