extends MarginContainer


onready var label_res = find_node("LabelResult")

var res_stream = ["GAME_WIN", "GAME_LOSE"]


# Called when the node enters the scene tree for the first time.
func _ready():
	label_res.text = Global.result_str[Global.game_res.team]
	var stream = res_stream[Global.game_res.team]
	if not AudioManager.is_playing(stream):
		AudioManager.play(stream)
	AudioManager.get_stream(stream).connect("finished", self, "result_music_complete")


func result_music_complete():
	if not AudioManager.is_playing("MENU_MUSIC"):
		AudioManager.play("MENU_MUSIC")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonPlayAgain_pressed():
	for stream in res_stream:
		AudioManager.stop(stream)
	AudioManager.stop("MENU_MUSIC")
	get_tree().change_scene_to(Global.Game)






