extends Node


var tile_conf = {
	"start": {
		"can_place": false,
		"fixed": true,
		"health_max": 4,
		"health_start": 4,
		"health_dec": 0,
		"neighbors_req": [],
		"reqs_text": "Starting tile.",
	},
	"end": {
		"can_place": false,
		"fixed": true,
		"health_max": 4,
		"health_start": 4,
		"health_dec": 0,
		"neighbors_req": [],
		"reqs_text": "Goal tile.",
	},
	"plains": {
		"texture": "res://art/tiles/plains.png",
		"sound": "TILE_PLAINS",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"neighbors_req": [],
		"neighbors_avoid_terrain": ["forest", "hill", "mountain", "lake", "river", "ocean", "swamp", "desert"],
		"interactions": {"plains":1, "farm":-1, "ranch":-1, "nuclear_plant":-1, "coal_plant":-1, "solar_farm":-1, "wind_farm":-1, "refinery":-1, "geothermal_plant":-1},
		"reqs_text": "Neighborhood must not contain terrain tiles of any other type.",
	},
	"forest": {
		"texture": "res://art/tiles/forest.png",
		"sound": "TILE_FOREST",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"neighbors_avoid_terrain": ["plains", "hill", "mountain", "lake", "river", "ocean", "swamp", "desert"],
		"interactions": {"forest":1, "farm":-2, "coal_plant":-1, "refinery":-2, "geothermal_plant":-1},
		"reqs_text": "Neighborhood must not contain terrain tiles of any other type."
	},
	"hill": {
		"texture": "res://art/tiles/hills.png",
		"sound": "TILE_HILL",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"neighbors_avoid_terrain": ["plains", "forest", "mountain", "lake", "river", "ocean", "swamp", "desert"],
		"interactions": {"hill":1, "farm":-1, "ranch":-1, "coal_plant":-1, "solar_plant":-1, "wind_farm":-2, "refinery":-1, "geothermal_plant":-1},
		"reqs_text": "Neighborhood must not contain terrain tiles of any other type."
	},
	"mountain": {
		"texture": "res://art/tiles/mountains.png",
		"sound": "TILE_HILL",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"neighbors_avoid_terrain": ["plains", "forest", "hill", "lake", "river", "ocean", "swamp", "desert"],
		"interactions": {"mountain":1, "coal_plant":-1, "solar_plant":-1, "wind_farm":-3, "refinery":-1},
		"reqs_text": "Neighborhood must not contain terrain tiles of any other type."
	},
	"lake": {
		"texture": "res://art/tiles/lake.png",
		"sound": "TILE_RIVER",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"neighbors_avoid_terrain": ["plains", "forest", "hill", "mountain", "river", "ocean", "swamp", "desert"],
		"interactions": {"lake":1, "river":1, "mountain":1, "farm":-2, "ranch":-2, "nuclear_plant":-1, "coal_plant":-3, "refinery":-3},
		"reqs_text": "Neighborhood must not contain terrain tiles of any other type."
	},
	"river": {
		"texture": "res://art/tiles/river.png",
		"sound": "TILE_RIVER",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"neighbors_avoid_terrain": ["plains", "forest", "hill", "mountain", "lake", "ocean", "swamp", "desert"],
		"interactions": {"lake":1, "river":1, "forest":1, "farm":-1, "ranch":-1, "nuclear_plant":-1, "coal_plant":-3},
		"reqs_text": "Neighborhood must not contain terrain tiles of any other type."
	},
	"ocean": {
		"texture": "res://art/tiles/ocean.png",
		"sound": "TILE_OCEAN",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"neighbors_avoid_terrain": ["plains", "forest", "hill", "mountain", "lake", "river", "swamp", "desert"],
		"interactions": {"ocean":1, "river":1, "forest":1, "farm":-1, "nuclear_plant":-1, "coal_plant":-3, "tidal_farm":-1, "refinery":-2},
		"reqs_text": "Neighborhood must not contain terrain tiles of any other type."
	},
	"swamp": {
		"texture": "res://art/tiles/swamp.png",
		"sound": "TILE_SWAMP",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"neighbors_avoid_terrain": ["plains", "forest", "hill", "mountain", "lake", "river", "ocean", "desert"],
		"interactions": {"lake":1, "river":1, "swamp":1, "coal_plant":-1, "refinery":-1},
		"reqs_text": "Neighborhood must not contain terrain tiles of any other type."
	},
	"desert": {
		"texture": "res://art/tiles/desert.png",
		"sound": "TILE_DESERT",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"neighbors_avoid_terrain": ["plains", "forest", "hill", "mountain", "lake", "river", "ocean", "swamp"],
		"interactions": {"desert":1, "farm":1, "ranch":1, "geothermal_plant":-1, "refinery":-1},
		"reqs_text": "Neighborhood must not contain terrain tiles of any other type."
	},
	"farm": {
		"texture": "res://art/tiles/farm-2.png",
		"sound": "TILE_FARM",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"neighbors_req": [["river", "lake", "ocean"]],
		"neighbors_avoid": ["swamp", "forest", "mountain"],
		"interactions": {"plains":2, "forest":2, "hill":1, "lake":2, "river":1, "ocean":1, "farm":1, "ranch":1, "nuclear_plant":-2, "coal_plant":-3, "wind_farm":2, "tidal_farm":-1, "refinery":-3, "geothermal_plant":-2},
		"reqs_text": "Neighborhood must have a water tile (lake, river, ocean), and must not have any swamp, forest, or mountains."
	},
	"ranch": {
		"texture": "res://art/tiles/ranch.png",
		"sound": "TILE_FARM",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"neighbors_req": [["river", "lake", "ocean"], ["plains", "hill"]],
		"interactions": {"plains":1, "hill":1, "lake":1, "river":1, "farm":1, "ranch":2, "nuclear_plant":-1, "coal_plant":-2, "solar_farm":-1, "wind_farm":1, "refinery":-1},
		"reqs_text": "Neighborhood must have a water tile (lake, river, ocean), and one of either plains or hills."
	},
	"nuclear_plant": {
		"texture": "res://art/tiles/nuclear.png",
		"sound": "TILE_NUCLEAR_PLANT",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"neighbors_req": [["river", "lake", "ocean"]],
		"interactions": {"plains":1, "river":1, "lake":1, "ocean":1, "nuclear_plant":-3, "coal_plant":-3, "solar_farm":-2, "wind_farm":-2, "tidal_farm":-1, "refinery":-3, "geothermal_plant":-1},
		"reqs_text": "Neighborhood must have a water tile (lake, river, ocean)."
	},
	"coal_plant": {
		"texture": "res://art/tiles/coal.png",
		"sound": "TILE_COAL_PLANT",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"neighbors_req": [["river", "lake", "ocean"]],
		"interactions": {"plains":1, "forest":1, "hill":1, "mountain":1, "river":3, "lake":3, "ocean":3, "swamp":1, "nuclear_plant":-3, "coal_plant":-3, "solar_farm":-2, "wind_farm":-2, "tidal_farm":-1, "refinery":-3, "geothermal_plant":-1},
		"reqs_text": "Neighborhood must have a water tile (lake, river, ocean)."
	},
	"solar_farm": {
		"texture": "res://art/tiles/solar.png",
		"sound": "TILE_SOLAR_FARM",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"neighbors_req": [["desert", "plain", "hill", "mountain"]],
		"neighbors_avoid": ["swamp", "forest"],
		"interactions": {"plains":1, "hill":1, "mountain":1, "farm":1, "nuclear_plant":-2, "coal_plant":-2, "solar_farm":-1, "wind_farm":-1, "tidal_farm":-1, "refinery":-2, "geothermal_plant":-1},
		"reqs_text": "Neighborhood must have one of: desert, plain, hill, mountain, and must not have any of forest or swamp."
	},
	"wind_farm": {
		"texture": "res://art/tiles/wind.png",
		"sound": "TILE_WIND_FARM",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"interactions": {"plains":1, "hill":2, "mountain":3, "nuclear_plant":-2, "coal_plant":-2, "solar_farm":-1, "wind_farm":-1, "refinery":-2},
		"reqs_text": "Place anywhere."
	},
	"tidal_farm": {
		"texture": "res://art/tiles/tidalpower.png",
		"sound": "TILE_TIDAL_FARM",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"neighbors_req": [["ocean"]],
		"interactions": {"ocean":1, "nuclear_plant":-1, "coal_plant":-1, "tidal_farm":-1, "refinery":-1},
		"reqs_text": "Neighborhood must have an ocean tile."
	},
	"refinery": {
		"texture": "res://art/tiles/refinery.png",
		"sound": "TILE_REFINERY",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"reqs_text": "Place anywhere.",
		"interactions": {"plains":1, "forest":2, "hill":1, "mountain":1, "lake":3, "ocean":2, "swamp":1},
	},
	"geothermal_plant": {
		"texture": "res://art/tiles/geothermal.png",
		"sound": "TILE_GEOTHERMAL_PLANT",
		"health_max": 4,
		"health_start": 4,
		"health_dec": 1,
		"interactions": {"plains":1, "forest":1, "hill":1, "nuclear_plant":-1, "coal_plant":-1, "tidal_farm":-1, "refinery":-1, "geothermal_plant":-1},
		"reqs_text": "Place anywhere."
	}
};


var tile_conf_2 = {
}


func get_tile_types():
	return(tile_conf.keys());


func get_random_tiles(n):
	return(UtilsMath.sample_without_replacement(tile_conf.keys(), n));


func get_tile_conf(type):
	return(tile_conf[type]);


func is_tile_type_fixed(type):
	return(get_tile_conf(type).get("fixed", false));


func is_tile_placeable(type):
	return(get_tile_conf(type).get("can_place", true));


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
