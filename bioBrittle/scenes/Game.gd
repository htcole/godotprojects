extends Control


# Variables
var hovering_on_board = false;
var tiles_placed = [];
var n_tiles_placed = 0;
var tiles_alive = 0;
var flag_game_over = false;
var options_screen_open = false;


# Nodes
onready var board = find_node("Board");
onready var board_container = find_node("BoardContainer");
onready var tile_choice = find_node("TileChoice");
onready var background = find_node("Background");
onready var panel_comets = find_node("PanelComets");

onready var label_level = find_node("LabelLevelValue");
onready var label_tiles_placed = find_node("LabelTilesPlaced");
onready var label_tiles_alive = find_node("LabelTilesAlive");
onready var label_tiles_alive_percent = find_node("LabelTilesAlivePercent");
onready var label_tiles_alive_threshold = find_node("LabelTilesAliveThreshold");

onready var world = find_node("World");
onready var cont_game_over = find_node("ContGameOver");
onready var cont_game_options = find_node("ContGameOptions");
onready var button_options = find_node("ButtonOptions");
onready var button_proceed = find_node("ButtonProceed");



func refresh_tile_choice():
	var tiles_remove = tiles_placed.slice(max(0,n_tiles_placed-Global.config.TILE_SELECT_COOLDOWN), n_tiles_placed-1);
	var tiles_feasible = board.get_feasible_tiles();
	print("Game.refresh_tile_choice: feasible tiles: ", tiles_feasible);
	print("Game.refresh_tile_choice: tiles_remove: ", tiles_remove);
	for tile_remove in tiles_remove:
		tiles_feasible.erase(tile_remove);
	print("Game.refresh_tile_choice: final feasible tiles: ", tiles_feasible);
	#var tile_list = TileManager.get_random_tiles(Global.config.N_TILE_CHOICE);
	if tiles_feasible.size()>0:
		var tile_list = UtilsMath.sample_without_replacement(tiles_feasible, Global.config.N_TILE_CHOICE);
		tile_choice.init(self, tile_list);


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize();
	spawn_comet();
	board_container.rect_min_size = Global.config.CELL_SIZE * Global.config.GRID_SIZE;
	board.init(self, Global.config.CELL_SIZE, Global.config.GRID_SIZE);
	cont_game_over.visible = false;
	cont_game_options.visible = false;
	button_proceed.visible = false;
	refresh_stats();
	if not AudioManager.is_playing("GAME_MUSIC"):
		AudioManager.play("GAME_MUSIC");
	
	if Global.config.GOAL_TYPE=="CONNECT" or Global.config.MUST_CONNECT_START:
		board.add_tile("start", TileManager.get_tile_conf("start"), Global.config.POS_START*Global.config.CELL_SIZE);
	if Global.config.GOAL_TYPE=="CONNECT":
		board.add_tile("end", TileManager.get_tile_conf("end"), Global.config.POS_END*Global.config.CELL_SIZE);
		
	refresh_tile_choice();
	
	#if Global.level_curr==2:
	#	game_over(1);


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func spawn_comet():
	var comet = Global.Comet.instance();
	panel_comets.add_child(comet);
	comet.init(Vector2(260,260), 500, 50);


func get_bounds():
	return({"x":[0,rect_size.x], "y":[0,rect_size.y]});


func mouse_down():
	print("Game.mouse_down");
	place_tile(board.get_local_mouse_position());


func mouse_move():
	var tile_selected = tile_choice.get_tile_selected();
	var pos = board.get_local_mouse_position();
	if flag_game_over or options_screen_open or tile_selected==null or not board.is_within_grid(board.normalize_pos(pos)):
		board.clear_hover();
	else:
		var tile_conf = TileManager.get_tile_conf(tile_selected) if tile_selected!=null else null;
		var placement_valid = board.can_place_tile(tile_selected, pos);
		board.show_hover(tile_selected, tile_conf, pos, placement_valid);


func check_game_over():
	# Check target alive fraction
	var tiles_alive_fraction = (tiles_alive+0.0)/n_tiles_placed;
	print("Tiles alive = %d; Tiles placed = %d" % [tiles_alive, n_tiles_placed]);
	print("Tiles alive fraction: Target = %.2f; Current = %.2f" % [Global.level_config[Global.level_curr-1].TARGET_ALIVE_FRACTION, tiles_alive_fraction]);
	if tiles_alive_fraction < Global.level_config[Global.level_curr-1].TARGET_ALIVE_FRACTION:
		game_over(1);
	
	match Global.config.GOAL_TYPE:
		"CONNECT":
			if board.get_tiles_reachable_from_start().has(board.get_end_tile()):
				game_over(0);
		"FILL_GRID":
			if board.get_tile_count()>=(Global.config.FILL_FRACTION * Global.config.GRID_SIZE.x * Global.config.GRID_SIZE.y):
				game_over(0);


func refresh_stats():
	label_level.text = str(Global.level_curr);
	label_tiles_alive_threshold.text = str(Global.level_config[Global.level_curr-1].TARGET_ALIVE_FRACTION * 100);
	label_tiles_placed.text = str(n_tiles_placed);
	label_tiles_alive.text = str(tiles_alive);
	var tiles_alive_percent = 100 if n_tiles_placed==0 else (100*tiles_alive/n_tiles_placed);
	label_tiles_alive_percent.text = "%.2f" % tiles_alive_percent;
	world.init(Global.level_config[Global.level_curr-1].TARGET_ALIVE_FRACTION * 100, tiles_alive_percent);


func place_tile(pos):
	#game_over(1);
	
	#print("Game.place_tile at ", pos);
	if not hovering_on_board or flag_game_over:
		return;
	
	var tile_selected = tile_choice.get_tile_selected();
	if tile_selected!=null and board.can_place_tile(tile_selected, pos):
		tiles_placed.append(tile_selected);
		n_tiles_placed += 1;
		print("Game.place_tile: ", tile_selected);
		print("Game.place_tile: All tiles placed: ", tiles_placed);
		board.clear_hover();
		board.clear_valid_locations();
		var tile_conf = TileManager.get_tile_conf(tile_selected)
		board.add_tile(tile_selected, tile_conf, pos);
		if tile_conf.has("sound"):
			AudioManager.play(tile_conf.sound);
		board.advance();
		tiles_alive = board.get_alive_tiles().size();
		refresh_stats();
		check_game_over();
		refresh_tile_choice();


func game_over(team_win):
	flag_game_over = true;
	button_options.disabled = true;
	board.clear_hover();
	AudioManager.stop("GAME_MUSIC");
	cont_game_over.visible = true;
	var play_again_visible = team_win==1 or Global.level_curr==Global.level_config.size();
	var continue_visible = team_win==0 and Global.level_curr<Global.level_config.size();
	cont_game_over.init(
		Global.config.RESULT_TEXT[team_win],
		Global.level_config[Global.level_curr-1].RESULT_MESSAGE[team_win],
		play_again_visible,
		continue_visible,
		Global.level_config[Global.level_curr-1].TARGET_ALIVE_FRACTION,
		100 * (1-team_win)
	);
	if team_win==0:
		AudioManager.play("GAME_WIN");
		if Global.level_curr==Global.level_config.size():
			Global.level_curr = 1;
		else:
			Global.level_curr += 1;
	else:
		AudioManager.play("GAME_LOSE");


func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		print("Game: Mouse down at: ", event.position);
		mouse_down();
	if event is InputEventMouseMotion:
		mouse_move();


func _on_ButtonBoard_pressed():
	print("Game._on_ButtonBoard_pressed");
	var pos = get_global_mouse_position();
	place_tile(pos);


func _on_BoardContainer_mouse_entered():
	#print("Game._on_BoardContainer_mouse_entered");
	hovering_on_board = true;


func _on_BoardContainer_mouse_exited():
	#print("Game._on_BoardContainer_mouse_exited");
	hovering_on_board = false;


func _on_TileChoice_tile_selected(type):
	AudioManager.play("SELECT_TILE");
	if not flag_game_over:
		board.show_valid_locations(type);


func _on_ButtonOptions_pressed():
	AudioManager.play("UI_ACTION");
	tile_choice.clear_selection();
	options_screen_open = true;
	cont_game_options.visible = true;


func _on_ContGameOptions_done():
	AudioManager.play("UI_ACTION");
	options_screen_open = false;
	cont_game_options.visible = false;


func _on_ContGameOver_show_map():
	AudioManager.play("UI_ACTION");
	cont_game_over.visible = false;
	button_proceed.visible = true;


func _on_ButtonProceed_pressed():
	AudioManager.play("UI_ACTION");
	cont_game_over.visible = true;
	button_proceed.visible = false;






















