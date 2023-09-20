extends MarginContainer

signal show_map;


# Vars
var message_1 = "";
var message_2 = "";
var play_again_visible = false;
var continue_visible = false;
var alive_threshold = 50;
var alive_percentage = 100;


# Nodes
onready var label_message_1 = find_node("LabelMessage1");
onready var label_message_2 = find_node("LabelMessage2");
onready var button_play_again = find_node("ButtonPlayAgain");
onready var button_continue = find_node("ButtonContinue");
onready var world = find_node("World");


# Called when the node enters the scene tree for the first time.
func _ready():
	refresh();


func refresh():
	label_message_1.text = message_1;
	label_message_1.visible = message_1!="";
	label_message_2.text = message_2;
	button_play_again.visible = play_again_visible;
	button_continue.visible = continue_visible;
	world.init(alive_threshold, alive_percentage);


func init(message_1_in, message_2_in, play_again_visible_in, continue_visible_in, alive_threshold_in, alive_percentage_in):
	message_1 = message_1_in;
	message_2 = message_2_in;
	play_again_visible = play_again_visible_in;
	continue_visible = continue_visible_in;
	alive_threshold = alive_threshold_in;
	alive_percentage = alive_percentage_in;
	refresh();


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonPlayAgain_pressed():
	AudioManager.play("UI_ACTION");
	get_tree().change_scene_to(Global.Game);


func _on_ButtonMainMenu_pressed():
	AudioManager.play("UI_ACTION");
	get_tree().change_scene_to(Global.MainMenu);


func _on_ButtonContinue_pressed():
	AudioManager.play("UI_ACTION");
	get_tree().change_scene_to(Global.Game);


func _on_ButtonShowMap_pressed():
	emit_signal("show_map");











