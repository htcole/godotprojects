extends Node2D

signal tile_clicked;

# Variables
var initialized = false;
var info_card_update_count = 0;
var type = "";
var stats = null;

var alive = true;
var invalid = false;
var game = null;
var board = null;
var health_curr = 0;
var mouse_hover = false;
var enable_hint = false;


# Nodes
onready var background = find_node("Background");
onready var label_type = find_node("LabelType");
onready var label_health = find_node("LabelHealth");
onready var panel_blur = find_node("PanelBlur");
onready var icon = find_node("Icon");
onready var disp_invalid = find_node("DispInvalid");
onready var disp_damage = [find_node("Damage1"), find_node("Damage2"), find_node("Damage3")];

onready var info_card = find_node("InfoCard");
onready var info_panel = find_node("InfoPanel");
onready var label_info_title = find_node("LabelInfoTitle");
onready var label_info_reqs = find_node("LabelInfoReqs");
onready var label_info_interactions = find_node("LabelInfoInteractions");
onready var label_interactions_positive = find_node("LabelInteractionsPositive");
onready var label_interactions_negative = find_node("LabelInteractionsNegative");


# Constants
var damage_sounds = ["TILE_DAMAGE_1", "TILE_DAMAGE_2", "TILE_DAMAGE_3"];


func get_type():
	return(type);


func is_alive():
	return(alive);


func get_display_str(text, single_line):
	var str_disp = text.replace("_", " ").capitalize();
	if not single_line:
		str_disp = str_disp.replace(" ", "\n");
	return(str_disp);


func set_invalid(invalid_in):
	invalid = invalid_in;
	refresh();


func make_interactions_text():
	var interactions = stats.get("interactions", {});
	if interactions.size()==0:
		return("");
	
	var text = "Impact of neighboring tiles:";
	for type in interactions.keys():
		var type_disp = type.replace("_", " ").capitalize();
		text += "\n" + type_disp + "(" + str(interactions[type]) + ")";
	return(text);


func make_interactions_text_2(sgn):
	var interactions = stats.get("interactions", {});
	var text = "";
	var value_prefix = "+" if sgn>0 else "";
	var first = true;
	var count = 0;
	for type in interactions.keys():
		if interactions[type] * sgn < 0:
			continue;
		count += 1;
		var type_disp = type.replace("_", " ").capitalize();
		if not first:
			text += "\n";
		text += type_disp + "(" + value_prefix + str(interactions[type]) + ")";
		first = false;
	if count==0:
		return("None");
	return(text);


func refresh_info_card():
	info_card.visible = enable_hint and mouse_hover;
	label_info_title.text = get_display_str(type, true);
	label_info_reqs.text = stats.get("reqs_text", "");
	label_interactions_positive.text = make_interactions_text_2(1);
	label_interactions_negative.text = make_interactions_text_2(-1);
	#label_info_interactions.text = make_interactions_text();
	#print("Tile.refresh: position: %s, global position: %s" % [position, global_position]);
	info_card.position = background.rect_size;
	#if info_card.global_position.x + info_panel.rect_size.x > OS.window_size.x:
	var overhang_x = info_card.global_position.x + info_panel.rect_size.x - game.get_bounds().x[1];
	if overhang_x > 0:
		#print("Tile.refresh_info_card: Out of X bounds.");
		info_card.position = Vector2(info_card.position.x-overhang_x-20, info_card.position.y);
	var overhang_y = info_card.global_position.y + info_panel.rect_size.y - game.get_bounds().y[1];
	#print("Tile.refresh_info_card: Y bounds. position: %f, rect_size: %f, window_size: %f, overhang_y: %f" %
	#	[info_card.global_position.y, info_panel.rect_size.y, game.get_bounds().y[1], overhang_y]);
	if overhang_y > 0:
		info_card.position = Vector2(info_card.position.x, info_card.position.y-overhang_y-20);


func refresh():
	if stats.has("texture"):
		icon.set_texture(load(stats.texture));
		icon.visible = true;
	else:
		icon.visible = false;
	label_type.text = get_display_str(type, false);
	label_type.visible = not stats.has("texture");
	#label_health.text = str(health_curr) + "/" + str(stats.health_max);
	label_health.visible = false;
	panel_blur.visible = not alive;
	disp_invalid.visible = invalid;
	if type=="":
		modulate = Color(1,1,1,0.2);
	
	refresh_info_card();
	
	var damage = stats.get("health_start",5) - health_curr;
	for i in range(disp_damage.size()):
		disp_damage[i].visible = i==(damage-1);
	if damage>disp_damage.size():
		disp_damage[-1].visible = true;



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(game_in, board_in, type_in, stats_in, enable_hint_in):
	initialized = true;
	game = game_in;
	board = board_in;
	type = type_in;
	stats = stats_in;
	enable_hint = enable_hint_in;
	
	health_curr = stats.get("health_start", 5);
	refresh();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if info_card_update_count>0:
		#print("Tile._process: info_card_update_count = %d" % [info_card_update_count]);
		refresh();
		info_card_update_count -= 1;


func die():
	alive = false;
	AudioManager.play("TILE_BREAK");
	refresh();


func advance():
	#print("Tile.advance: ", type, " at ", position);
	var health_prev = health_curr;
	if not Global.config.DYNAMIC_HEALTH:
		health_curr = stats.health_start;
		#print("Tile.advance: Health reset to ", health_curr);
	var delta_total = 0;
	if Global.config.ENABLE_HEALTH_DEC:
		delta_total += stats.health_dec;
		#print("Tile.advance: Health decrement; Impact ", stats.health_dec);
	var tile_neighbors = board.get_tile_neighbors(self, Global.config.ENABLE_CORNER_NEIGHBORS_INTERACT);
	for tile_neighbor in tile_neighbors:
		if not tile_neighbor.is_alive():
			continue;
		var delta = stats.get("interactions", {}).get(tile_neighbor.get_type(), 0);
		delta_total += delta;
		if abs(delta)>0:
			pass;
			#print("Tile.advance: Impact of ", tile_neighbor.get_type(), " = ", delta);
	change_health(delta_total);
	if health_curr<health_prev:
		var damage_total = stats.health_start - health_curr;
		if damage_total <= damage_sounds.size():
			AudioManager.play(damage_sounds[damage_total-1]);
	#print("Tile.advance: New health ", health_curr);
	
	var placement_valid = board.is_tile_req_satisfied(self);

	if not placement_valid or health_curr==0:
		die();
	
	refresh();
	return(alive);


func change_health(delta):
	var health_proposed = health_curr + delta;
	health_curr = clamp(health_proposed, 0, stats.health_max);
	refresh();


func _on_MarginContainer_mouse_entered():
	print("Tile._on_MarginContainer_mouse_entered");
	mouse_hover = true;
	info_card_update_count = 100;
	refresh();


func _on_MarginContainer_mouse_exited():
	print("Tile._on_MarginContainer_mouse_exited");
	mouse_hover = false;
	info_card_update_count = 100;
	refresh();


func _on_Button_pressed():
	#print("Tile._on_Button_pressed");
	emit_signal("tile_clicked");


func _on_Button_mouse_entered():
	#print("Tile._on_Button_mouse_entered");
	mouse_hover = true;
	info_card_update_count = 1;
	refresh();


func _on_Button_mouse_exited():
	pass # Replace with function body.
	mouse_hover = false;
	info_card_update_count = 1;
	refresh();
























