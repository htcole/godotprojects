extends Control


onready var button_new_campaign = find_node("ButtonNewCampaign");
onready var button_continue_campaign = find_node("ButtonContinueCampaign");
onready var button_abandon_campaign = find_node("ButtonAbandonCampaign");


func refresh():
	button_new_campaign.visible = Global.level_curr==1;
	button_continue_campaign.visible = Global.level_curr>1;
	button_abandon_campaign.visible = Global.level_curr>1;


# Called when the node enters the scene tree for the first time.
func _ready():
	if not AudioManager.is_playing("MENU_MUSIC"):
		AudioManager.play("MENU_MUSIC");
	refresh();


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonNewGame_pressed():
	AudioManager.stop("MENU_MUSIC");
	AudioManager.play("UI_ACTION");
	get_tree().change_scene_to(Global.Game);
	#get_tree().change_scene_to(Global.GameMenu);


func _on_ButtonSettings_pressed():
	AudioManager.play("UI_ACTION");
	get_tree().change_scene_to(Global.Settings);


func _on_ButtonCredits_pressed():
	AudioManager.play("UI_ACTION");
	get_tree().change_scene_to(Global.Credits);


func _on_ButtonAbandonCampaign_pressed():
	AudioManager.play("UI_ACTION");
	Global.level_curr = 1;
	refresh();
















