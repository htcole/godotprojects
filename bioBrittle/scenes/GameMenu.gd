extends Control


var alive_threshold = 50;
var row_col_values = [5,7,10,15,20];


onready var label_alive_threshold = find_node("LabelAliveThreshold");
onready var checkbox_connect_start_to_end = find_node("CheckBoxConnectStartToEnd");
onready var checkbox_connect_start = find_node("CheckBoxConnectStart");
onready var input_rows = find_node("InputRows");
onready var input_cols = find_node("InputCols");


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SliderAliveThreshold_value_changed(value):
	label_alive_threshold.text = str(value) + "%";
	alive_threshold = value;


func _on_ButtonStart_pressed():
	Global.config.TARGET_ALIVE_FRACTION = alive_threshold/100.0;
	Global.config.GOAL_TYPE = "CONNECT" if checkbox_connect_start_to_end.pressed else "";
	Global.config.MUST_CONNECT_START = checkbox_connect_start.pressed;
	Global.config.GRID_SIZE = Vector2(row_col_values[input_cols.selected], row_col_values[input_rows.selected]);
	get_tree().change_scene_to(Global.Game);
















