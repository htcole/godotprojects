extends MarginContainer

signal done;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonBack_pressed():
	emit_signal("done");


func _on_ButtonPlayAgain_pressed():
	AudioManager.play("UI_ACTION");
	get_tree().change_scene_to(Global.Game);


func _on_ButtonMainMenu_pressed():
	AudioManager.stop("GAME_MUSIC");
	AudioManager.play("UI_ACTION");
	get_tree().change_scene_to(Global.MainMenu);


func _on_ButtonAbandonCampaign_pressed():
	AudioManager.stop("GAME_MUSIC");
	AudioManager.play("UI_ACTION");
	Global.level_curr = 1;
	get_tree().change_scene_to(Global.MainMenu);



















