extends Control


onready var sound_conf = {
	"MENU_MUSIC": find_node("SliderMenuMusic"),
	"GAME_MUSIC": find_node("SliderGameMusic"),
	"SOUNDS": find_node("SliderSounds"),
};


# Called when the node enters the scene tree for the first time.
func _ready():
	if not AudioManager.is_playing("MENU_MUSIC"):
		AudioManager.play("MENU_MUSIC");
	refresh_sliders();


func refresh_sliders():
	for group in sound_conf.keys():
		sound_conf[group].value = AudioManager.get_group_volume(group);


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_SliderMenuMusic_value_changed(value):
	AudioManager.play("UI_ACTION");
	AudioManager.set_volume("MENU_MUSIC", value);


func _on_SliderGameMusic_value_changed(value):
	AudioManager.play("UI_ACTION");
	AudioManager.set_volume("GAME_MUSIC", value);


func _on_SliderSounds_value_changed(value):
	AudioManager.play("UI_ACTION");
	AudioManager.set_volume("SOUNDS", value);


func _on_ButtonBack_pressed():
	AudioManager.play("UI_ACTION");
	get_tree().change_scene_to(Global.MainMenu);














