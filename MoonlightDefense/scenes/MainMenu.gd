extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	if not AudioManager.is_playing("MENU_MUSIC"):
		AudioManager.play("MENU_MUSIC")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonStartGame_pressed():
	AudioManager.stop("MENU_MUSIC")
	AudioManager.play("UI_ACTION")
	get_tree().change_scene_to(Global.Game)






