extends Node2D


var alive_threshold = 50;
var alive_percent = 70;


onready var frames = get_children();


func refresh():
	var frame_disp = -1;
	if alive_percent < alive_threshold:
		frame_disp = frames.size()-1;
	else:
		frame_disp = ceil((100-alive_percent)/6);
	for i in range(frames.size()):
		frames[i].visible = i==frame_disp;


func init(alive_threshold_in, alive_percent_in):
	alive_threshold = alive_threshold_in;
	alive_percent = alive_percent_in;
	refresh();


# Called when the node enters the scene tree for the first time.
func _ready():
	refresh();


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
