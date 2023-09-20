extends MarginContainer

signal pressed

var game = null
var builder = null
var class_str = null
var type = null
var progress_bar = null


onready var box_items = find_node("BoxItems")
onready var button_cover = find_node("ButtonCover")


func setup():
	for child in box_items.get_children():
		child.queue_free()
	var label = Label.new()
	box_items.add_child(label)
	label.text = Global.get_display_str(type)
	#var h_sep = HSeparator.new()
	#box_items.add_child(h_sep)
	progress_bar = ProgressBar.new()
	box_items.add_child(progress_bar)
	progress_bar.percent_visible = false
	progress_bar.rect_min_size = Vector2(0,5)
	var cost_map = Global.building_types_conf[type].COST if class_str=="BUILDING" else Global.unit_types_conf[type].COST
	for resource in cost_map:
		var label_2 = Label.new()
		box_items.add_child(label_2)
		label_2.text = "%s: %s" % [Global.get_display_str(resource), cost_map[resource]]
	if class_str=="UNIT":
		var label_build_time = Label.new()
		box_items.add_child(label_build_time)
		label_build_time.text = "%s: %s" % ["Time", Global.unit_types_conf[type].BUILD_TIME]


func refresh():
	button_cover.disabled = builder.is_busy() or \
							not builder.get_complete() or \
							not game.can_afford(class_str, type) or \
							(builder.get_class()=="BUILDING" and game.get_world().reached_population_limit())
	progress_bar.value = 100
	if builder.is_busy() and builder.get_building_curr()==type:
		progress_bar.value = builder.get_curr_task_fraction() * 100


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(game_in, builder_in, class_str_in, type_in):
	game = game_in
	builder = builder_in
	class_str = class_str_in
	type = type_in
	
	setup()
	refresh()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(builder):
		refresh()


func _on_ButtonCover_pressed():
	emit_signal("pressed")












