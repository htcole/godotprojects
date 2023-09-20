extends Node2D

var dist_threshold = 10;

var center = Vector2(0,0);
var radius = 1000;
var speed = Vector2(50,50);

var dir = Vector2(1,0);
var pos_start = Vector2(0,0);
var pos_end = Vector2(0,0);


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func start_trajectory():
	var dir_rad = rand_range(0,2*PI);
	#var dir_rad = 0;
	var dir_degrees = rad2deg(dir_rad);
	dir = Vector2(cos(dir_rad), sin(dir_rad));
	pos_start = center - dir * radius;
	pos_end = center + dir * radius;
	position = pos_start;
	#look_at(pos_end);
	self.rotate(dir_rad);
	print("Comet.start_trajectory: dir_degrees = %s; pos_start = %s, pos_end = %s" % [dir_degrees, pos_start, pos_end]);


func init(center_in, radius_in, speed_in):
	center = center_in;
	radius = radius_in;
	speed = speed_in;
	start_trajectory();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += dir * speed * delta;
	var dist_target = position.distance_to(pos_end);
	#print("Comet._process: position = ", position);
	if randf()<0.05:
		print("Comet._process: pos_end = %s, position = %s, dist_target = %s" % [pos_end, position, dist_target]);
	if dist_target<=dist_threshold:
		self.rotate(-dir.angle());
		start_trajectory();


