extends PanelContainer

signal tile_selected;

var game = null;
var tile_list = [];
var tile_selected_ix = -1;


onready var tiles = [find_node("Tile1"), find_node("Tile2"), find_node("Tile3")];
onready var outlines = [find_node("Outline1"), find_node("Outline2"), find_node("Outline3")];


func refresh():
	for i in range(tile_list.size()):
		tiles[i].init(game, null, tile_list[i], TileManager.get_tile_conf(tile_list[i]), true);
		outlines[i].self_modulate = Color(1,1,1,1) if i==tile_selected_ix else Color(1,1,1,0);


func get_tile_selected():
	var tile_selected = tile_list[tile_selected_ix] if tile_selected_ix>=0 else null;
	return(tile_selected);


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(game_in, tile_list_in):
	game = game_in;
	tile_list = tile_list_in;
	tile_selected_ix = -1;
	refresh();


func clear_selection():
	tile_selected_ix = -1;
	refresh();


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func process_tile_selected(ix):
	tile_selected_ix = ix;
	emit_signal("tile_selected", tile_list[tile_selected_ix]);
	refresh();












