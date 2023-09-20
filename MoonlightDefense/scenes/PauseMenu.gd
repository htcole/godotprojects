extends MarginContainer


signal resume
signal restart


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rect_size = OS.window_size


func _on_ButtonResume_pressed():
	emit_signal("resume")


func _on_ButtonRestart_pressed():
	emit_signal("restart")


func _input(event):
	#print("PauseMenu._input")
	if visible and Input.is_action_just_pressed("ui_accept"):
		print("PauseMenu._input")
		get_tree().set_input_as_handled()
		#if event.is_pressed() and event.scancode == KEY_SPACE:
		emit_signal("resume")














