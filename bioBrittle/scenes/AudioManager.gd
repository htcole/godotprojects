extends Node


var game_over_loop_enable = false;


onready var sound_conf = {
	"UI_ACTION": {
		"stream": find_node("UIAction"),
		"volume_min": -5,
		"volume_max": 5,
	},
	"TILE_DAMAGE_1": {
		"stream": find_node("TileDamage1"),
		"volume_min": -5,
		"volume_max": 5,
	},
	"TILE_DAMAGE_2": {
		"stream": find_node("TileDamage2"),
		"volume_min": -5,
		"volume_max": 5,
	},
	"TILE_DAMAGE_3": {
		"stream": find_node("TileDamage3"),
		"volume_min": -5,
		"volume_max": 5,
	},
	"TILE_BREAK": {
		"stream": find_node("TileBreak"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"SELECT_TILE": {
		"stream": find_node("SelectTile"),
		"volume_min": -5,
		"volume_max": 5,
	},
	"GAME_MUSIC": {
		"stream": find_node("GameMusic"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"MENU_MUSIC": {
		"stream": find_node("MenuMusic"),
		"volume_min": -12,
		"volume_max": -2,
	},
	"GAME_WIN": {
		"stream": find_node("GameWin"),
		"volume_min": 0,
		"volume_max": -10,
	},
	"GAME_LOSE": {
		"stream": find_node("GameLose"),
		"volume_min": -20,
		"volume_max": -10,
	},
	"TILE_PLAINS": {
		"stream": find_node("TilePlains"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"TILE_RIVER": {
		"stream": find_node("TileRiver"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"TILE_OCEAN": {
		"stream": find_node("TileOcean"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"TILE_DESERT": {
		"stream": find_node("TileDesert"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"TILE_FOREST": {
		"stream": find_node("TileForest"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"TILE_HILL": {
		"stream": find_node("TileHill"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"TILE_SWAMP": {
		"stream": find_node("TileSwamp"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"TILE_FARM": {
		"stream": find_node("TileFarm"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"TILE_WIND_FARM": {
		"stream": find_node("TileWindFarm"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"TILE_NUCLEAR_PLANT": {
		"stream": find_node("TileNuclearPlant"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"TILE_SOLAR_FARM": {
		"stream": find_node("TileSolarFarm"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"TILE_COAL_PLANT": {
		"stream": find_node("TileCoalPlant"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"TILE_TIDAL_FARM": {
		"stream": find_node("TileTidalFarm"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"TILE_GEOTHERMAL_PLANT": {
		"stream": find_node("TileGeothermalPlant"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"TILE_REFINERY": {
		"stream": find_node("TileRefinery"),
		"volume_min": -10,
		"volume_max": 0,
	},
	"TILE_GENERIC": {
		"stream": find_node("TileGeneric"),
		"volume_min": -10,
		"volume_max": 0,
	},
};


var group_conf = {
	"MENU_MUSIC": {
		"volume": 50,
		"sounds": ["MENU_MUSIC"],
		"sounds_all": []
	},
	"GAME_MUSIC": {
		"volume": 50,
		"sounds": ["GAME_MUSIC"],
		"sounds_all": []
	},
	"SOUNDS": {
		"volume": 50,
		"sounds": [
			"UI_ACTION", "TILE_BREAK", "SELECT_TILE",
			"GAME_WIN", "GAME_LOSE",
			"TILE_DAMAGE_1", "TILE_DAMAGE_2", "TILE_DAMAGE_3",
			"TILE_HILL",
			"TILE_PLAINS", "TILE_RIVER", "TILE_OCEAN", "TILE_DESERT",
			"TILE_SWAMP", "TILE_FARM", "TILE_WIND_FARM", "TILE_COAL_PLANT",
			"TILE_TIDAL_FARM", "TILE_SOLAR_FARM",
			"TILE_NUCLEAR_PLANT", "TILE_GEOTHERMAL_PLANT", "TILE_REFINERY"
		],
		"sounds_all": [
			"GAME_VICTORY_MUSIC", "GAME_DEFEAT_MUSIC"
		]
	}
};


func get_group_volume(group):
	return(group_conf[group]["volume"]);


func is_playing(sound_id):
	return(sound_conf[sound_id]["stream"].playing);


func play(sound_id):
	sound_conf[sound_id]["stream"].play(sound_conf[sound_id].get("offset", 0));


func stop(sound_id):
	sound_conf[sound_id]["stream"].stop();


func set_game_over_loop_enable(enable_in):
	game_over_loop_enable = enable_in;


func refresh():
	for group in group_conf.keys():
		var value = group_conf[group]["volume"];
		for sound in group_conf[group]["sounds"]:
			var volume = -70 if value==0 else sound_conf[sound]["volume_min"] + (value/100) * (sound_conf[sound]["volume_max"]-sound_conf[sound]["volume_min"]);
			print("Setting volume for ", sound, " to ", volume, " db");
			sound_conf[sound]["stream"].volume_db = volume;


func set_volume(group, value):
	print("AudioManager.set_volume: Group: ", group, "; Volume: ", value);
	group_conf[group]["volume"] = value;
	refresh();


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
















