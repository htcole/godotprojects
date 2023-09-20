extends Node2D

var conf = {}

var amount_curr = 0
var listener = null
var world = null
var size = Vector2(50,50)
var selected = false

onready var highlight = find_node("Highlight")
onready var button_cover = find_node("ButtonCover")
onready var icons = find_node("Icons")


func setup():
	for icon in icons.get_children():
		icon.visible = false
	var icon = find_node(conf.type)
	icon.visible = true
	
	size = icon.rect_size * icon.rect_scale
	conf.size = size
	#print("Mine.setup: Type: %s; Size: %s" % [conf.type, conf.size])
	highlight.rect_size = conf.size
	button_cover.rect_size = conf.size
	amount_curr = conf.amount_start


func _update():
	z_index = position.y + get_size().y
	highlight.visible = selected


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(listener_in, world_in, conf_in):
	listener = listener_in
	world = world_in
	conf = conf_in.duplicate(true)
	
	setup()
	_update()


func get_class():
	return("MINE")


func get_type():
	return(conf.type)


func get_team():
	return(conf.team)


func get_size():
	return(size)


func get_position():
	return(position)


func get_rect() -> Rect2:
	return(Rect2(get_position(), get_size()))


func get_center():
	return(get_position() + 0.5 * get_size())


func get_amount_start():
	return(conf.amount_start)


func get_amount_curr():
	return(amount_curr)


func get_resource():
	return(conf.resource)


func set_selected(selected_in):
	selected = selected_in
	_update()


func gather(amount):
	var amount_reduce = min(amount, amount_curr)
	amount_curr -= amount_reduce
	_update()
	if amount_curr==0:
		world.remove_object(self)
		queue_free()
	return({
		"resource": conf.resource,
		"amount": amount_reduce
	})

# 
func _on_ButtonCover_pressed():
	print("Mine._on_ButtonCover_pressed")
	_update()
	listener.object_click(self)

