extends Node2D


var speed = 200

var src = null
var dest = null
var type = ""
var show_overlay = false

var dir = null
var dist_target = null


onready var icons = find_node("Icons")
onready var overlay = find_node("Overlay")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(src_in: Vector2, dest_in: Vector2, type_in: String, show_overlay_in):
	src = src_in
	dest = dest_in
	type = type_in
	show_overlay = show_overlay_in
	
	overlay.visible = show_overlay
	for icon in icons.get_children():
		icon.visible = false
	find_node(type).visible = true
	position = src
	dir = src.direction_to(dest)
	rotate(dir.angle())
	dist_target = src.distance_to(dest)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += dir * speed * delta
	var dist_curr = position.distance_to(src)
	if dist_curr >= dist_target:
		queue_free()






