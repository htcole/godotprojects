extends MarginContainer


onready var icons = find_node("Icons")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func show_phase(phase_id):
	for icon in icons.get_children():
		icon.visible = false
	find_node("Phase_" + str(phase_id)).visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
