extends Node


var game_over_loop_enable = false


onready var sound_conf = {
	"MENU_MUSIC": {
		"stream": find_node("MenuMusic"),
		"volume_min": -5,
		"volume_max": 5,
	},
	"GAME_START": {
		"stream": find_node("GameStart"),
		"volume_min": -5,
		"volume_max": 5,
	},
	"GAME_MUSIC_DAY": {
		"stream": find_node("GameMusicDay"),
		"volume_min": -15,
		"volume_max": -5,
	},
	"GAME_MUSIC_NIGHT": {
		"stream": find_node("GameMusicNight"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"GAME_WIN": {
		"stream": find_node("GameWin"),
		"volume_min": -2,
		"volume_max": -12,
	},
	"GAME_LOSE": {
		"stream": find_node("GameLose"),
		"volume_min": -20,
		"volume_max": -10,
	},
	"UI_ACTION": {
		"stream": find_node("UIAction"),
		"volume_min": -5,
		"volume_max": 5,
	},
	"GAME_OBJECT_SELECT": {
		"stream": find_node("GameObjectSelect"),
		"volume_min": -5,
		"volume_max": 5,
	},
	"BUILDING_READY": {
		"stream": find_node("BuildingReady"),
		"volume_min": -5,
		"volume_max": 5,
	},
	"PLAYER_ATTACK": {
		"stream": find_node("PlayerAttack"),
		"volume_min": -5,
		"volume_max": 5,
	},
	"PLAYER_UNIT_DEAD": {
		"stream": find_node("PlayerUnitDead"),
		"volume_min": -5,
		"volume_max": 5,
	},
	"UNIT_CREATED": {
		"stream": find_node("UnitCreated"),
		"volume_min": -5,
		"volume_max": 5,
	},
	"TOWN_BELL": {
		"stream": find_node("TownBell"),
		"volume_min": -5,
		"volume_max": 5,
	},
	"UNIT_ACK": {
		"stream": find_node("UnitAck"),
		"volume_min": -5,
		"volume_max": 5,
	},
	"BUILDING_DESTROYED": {
		"stream": find_node("BuildingDestroyed"),
		"volume_min": -5,
		"volume_max": 5,
	}
}


var group_conf = {
	"MENU_MUSIC": {
		"volume": 50,
		"sounds": [],
		"sounds_all": ["MENU_MUSIC"]
	},
	"GAME_MUSIC": {
		"volume": 50,
		"sounds": [],
	},
	"SOUNDS": {
		"volume": 50,
		"sounds": [],
	}
}


func get_stream(sound_id):
	return(sound_conf[sound_id]["stream"])


func get_group_volume(group):
	return(group_conf[group]["volume"])


func is_playing(sound_id):
	return(sound_conf[sound_id]["stream"].playing)


func play(sound_id):
	sound_conf[sound_id]["stream"].play(sound_conf[sound_id].get("offset", 0))


func stop(sound_id):
	sound_conf[sound_id]["stream"].stop()


func stop_group(group_id):
	for sound_id in group_conf[group_id]["sounds"]:
		stop(sound_id)


func set_game_over_loop_enable(enable_in):
	game_over_loop_enable = enable_in


func refresh():
	for group in group_conf.keys():
		var value = group_conf[group]["volume"]
		for sound in group_conf[group]["sounds"]:
			var volume = -70 if value==0 else sound_conf[sound]["volume_min"] + (value/100) * (sound_conf[sound]["volume_max"]-sound_conf[sound]["volume_min"])
			print("Setting volume for ", sound, " to ", volume, " db")
			sound_conf[sound]["stream"].volume_db = volume


func set_volume(group, value):
	print("AudioManager.set_volume: Group: ", group, "; Volume: ", value)
	group_conf[group]["volume"] = value
	refresh();


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
















