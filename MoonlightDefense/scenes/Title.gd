extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	if not AudioManager.is_playing("MENU_MUSIC"):
		AudioManager.play("MENU_MUSIC")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func proceed():
	#proceed_to_main_menu()
	proceed_to_game()


func proceed_to_main_menu():
	AudioManager.play("UI_ACTION")
	get_tree().change_scene_to(Global.MainMenu)


func proceed_to_game():
	AudioManager.stop("MENU_MUSIC")
	AudioManager.play("UI_ACTION")
	get_tree().change_scene_to(Global.Game)


func _on_ButtonContinue_pressed():
	proceed()


func _input(event):
	return
	if event is InputEventMouseButton or event is InputEventKey:
		#AudioManager.stop("MENU_MUSIC")
		#get_tree().change_scene_to(Global.Game)
		proceed()







