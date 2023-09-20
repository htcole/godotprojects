extends MarginContainer


var game = null
var track_object_prev = null
var track_object = null


onready var box_items = find_node("BoxItems")
onready var label_type = find_node("LabelType")
onready var label_hp = find_node("LabelHP")
onready var label_gather = find_node("LabelGather")
onready var box_build = find_node("BoxBuild")


func setup_panel_unit():
	label_hp.text = "%s/%s" % [ceil(track_object.get_hp_curr()), track_object.get_hp_max()]
	var gathered = track_object.get_gathered()
	var gather_amount = 0 if gathered==null else floor(gathered.amount)
	#label_gather.visible = gathered!=null and gather_amount>0
	label_gather.text = ""
	if gathered!=null and gather_amount>0:
		label_gather.text = "%s: %s" % [Global.get_display_str(gathered.resource), gather_amount]
		
	if track_object!=track_object_prev:
		for child in box_build.get_children():
			child.queue_free()
		for building_type in track_object.get_build_options():
			var build_button = Global.BuildButton.instance()
			box_build.add_child(build_button)
			build_button.init(game, track_object, "BUILDING", building_type)
			build_button.connect("pressed", self, "select_to_build", [building_type, track_object])
		track_object_prev = track_object


func setup_panel_building():
	label_gather.text = "(Incomplete)" if not track_object.get_complete() else ""
	label_hp.text = "%s/%s" % [ceil(track_object.get_hp_curr()), track_object.get_hp_max()]

	if track_object!=track_object_prev:
		for child in box_build.get_children():
			child.queue_free()
		for build_option in track_object.get_build_options():
			var build_button = Global.BuildButton.instance()
			box_build.add_child(build_button)
			build_button.init(game, track_object, "UNIT", build_option)
			build_button.connect("pressed", self, "select_to_create", [build_option, track_object])
		track_object_prev = track_object


func select_to_build(building_type, worker):
	if game.can_afford("BUILDING", building_type):
		print("InfoPanel.select_to_build: %s" % [building_type])
		game.select_to_build(building_type, worker)


func select_to_create(unit_type, building):
	if not game.can_afford("UNIT", unit_type):
		return
	
	game.get_world().reduce_resources(game.get_cost("UNIT", unit_type))
	print("InfoPanel.select_to_create: %s" % [unit_type])
	var task = {
		"type": "BUILD",
		"unit": unit_type
	}
	print("InfoPanel.select_to_create: Issuing task: ", task)
	building.perform_task(task)



func _update():
	box_items.visible = is_instance_valid(track_object)
	if not is_instance_valid(track_object):
		return
	
	label_type.text = Global.get_display_str(track_object.get_type())
	match track_object.get_class():
		"UNIT":
			setup_panel_unit()
		"MINE":
			label_gather.text = ""
			label_hp.text = "%s/%s" % [floor(track_object.get_amount_curr()), track_object.get_amount_start()]
			for child in box_build.get_children():
				child.queue_free()
			track_object_prev = track_object
		"BUILDING":
			setup_panel_building()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func init(game_in, track_object_in):
	game = game_in
	track_object = track_object_in
	_update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update()


func _on_ButtonCancel_pressed():
	game.deselect_object()










