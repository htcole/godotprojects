extends Node


var game_conf = {
	"N_DAYS": 5,
	"PHASE_DURATION": 180,
	"ATTACK_PROXIMITY": 300,
	"WORLD_CONF": {
		"MAP_CONF": {
				"SIZE": Vector2(3000, 3000),
				"WATER_WIDTH": 300,
				"MINE_CONF": {
					"BERRY": {
						"clusters": [5,7],
						"mines": [4,6],
						"amount": [100,150]
					},
					"TREE": {
						"clusters": [5,7],
						"mines": [4,6],
						"amount": [100,150]
					},
					"STONE_MINE": {
						"clusters": [4,6],
						"mines": [3,4],
						"amount": [100,150]
					},
					"GOLD_MINE": {
						"clusters": [3,4],
						"mines": [2,3],
						"amount": [100,150]
					}
				}
		},
		"UNITS_START": {
			"WORKER": 5,
			"SWORDSMAN": 0,
			"MAGIC_SWORDSMAN": 0,
			"MAGIC_CHARIOT": 0,
			"ARCHER": 0,
			"CATAPULT": 0,
			"MAGIC_CATAPULT": 0,
		},
		"RESOURCES_START": {
			"FOOD": 100,
			"WOOD": 100,
			"STONE": 100,
			"GOLD": 100,
			"MAGIC": 30
		},
		"BUILDINGS_START": [
			{
				"type": "TOWN_CENTER",
				"pos": Vector2(0.5,0.5)
			}
		]
	},
	"ENEMY_CONF": [
		{
			"AQUATIC_VAMPIRE": 3,
			"SEA_MONSTER": 0,
			"CORAL_GOLUM": 0,
		},
		{
			"AQUATIC_VAMPIRE": 7,
			"SEA_MONSTER": 1,
			"CORAL_GOLUM": 0,
		},
		{
			"AQUATIC_VAMPIRE": 10,
			"SEA_MONSTER": 2,
			"CORAL_GOLUM": 0,
		},
		{
			"AQUATIC_VAMPIRE": 15,
			"SEA_MONSTER": 4,
			"CORAL_GOLUM": 1,
		},
		{
			"AQUATIC_VAMPIRE": 20,
			"SEA_MONSTER": 6,
			"CORAL_GOLUM": 3,
		},
	]
}


var unit_types_conf = {
	"WORKER": {
		"SIZE": Vector2(52,52),
		"COST": {
			"FOOD": 10
		},
		"BUILD_TIME": 10,
		"HP_MAX": 10,
		"SPEED": 50,
		"CAPACITY": 10,
		"GATHER_RATE": 1,
		"BUILD_RATE": 1,
		"BUILD_OPTIONS": ["TOWN_CENTER", "HUT", "BARRACKS", "ARCHERY_RANGE", "TEMPLE", "WOOD_TOWER", "STONE_TOWER", "MAGIC_CASTLE"],
		"ATTACK": 0,
		"RANGE": 0,
	},
	"SWORDSMAN": {
		"SIZE": Vector2(51,77),
		"COST": {
			"FOOD": 20,
			"WOOD": 10
		},
		"BUILD_TIME": 10,
		"HP_MAX": 30,
		"SPEED": 50,
		"CAPACITY": 0,
		"GATHER_RATE": 0,
		"BUILD_RATE": 0,
		"BUILD_OPTIONS": [],
		"ATTACK": 3,
		"RANGE": 0,
	},
	"MAGIC_SWORDSMAN": {
		"SIZE": Vector2(51,77),
		"COST": {
			"WOOD": 20,
			"MAGIC": 10
		},
		"BUILD_TIME": 20,
		"HP_MAX": 40,
		"SPEED": 50,
		"CAPACITY": 0,
		"GATHER_RATE": 0,
		"BUILD_RATE": 0,
		"BUILD_OPTIONS": [],
		"ATTACK": 5,
		"RANGE": 0,
	},
	"MAGIC_CHARIOT": {
		"SIZE": Vector2(51,77),
		"COST": {
			"GOLD": 20,
			"MAGIC": 20
		},
		"BUILD_TIME": 30,
		"HP_MAX": 60,
		"SPEED": 100,
		"CAPACITY": 0,
		"GATHER_RATE": 0,
		"BUILD_RATE": 0,
		"BUILD_OPTIONS": [],
		"ATTACK": 10,
		"RANGE": 0,
	},
	"ARCHER": {
		"SIZE": Vector2(51,77),
		"COST": {
			"FOOD": 30,
			"WOOD": 20
		},
		"BUILD_TIME": 10,
		"HP_MAX": 20,
		"SPEED": 50,
		"CAPACITY": 0,
		"GATHER_RATE": 0,
		"BUILD_RATE": 0,
		"BUILD_OPTIONS": [],
		"ATTACK": 2,
		"RANGE": 180,
		"PROJECTILE": "ARROW"
	},
	"CATAPULT": {
		"SIZE": Vector2(90,75),
		"COST": {
			"WOOD": 30,
			"STONE": 20
		},
		"BUILD_TIME": 20,
		"HP_MAX": 30,
		"SPEED": 50,
		"CAPACITY": 0,
		"GATHER_RATE": 0,
		"BUILD_RATE": 0,
		"BUILD_OPTIONS": [],
		"ATTACK": 3,
		"RANGE": 180,
		"PROJECTILE": "STONE"
	},
	"MAGIC_CATAPULT": {
		"SIZE": Vector2(90,75),
		"COST": {
			"GOLD": 30,
			"MAGIC": 20
		},
		"BUILD_TIME": 30,
		"HP_MAX": 40,
		"SPEED": 50,
		"CAPACITY": 0,
		"GATHER_RATE": 0,
		"BUILD_RATE": 0,
		"BUILD_OPTIONS": [],
		"ATTACK": 5,
		"RANGE": 180,
		"PROJECTILE": "MAGIC_PIECE"
	},
	"AQUATIC_VAMPIRE": {
		"SIZE": Vector2(102,156),
		"HP_MAX": 100,
		"SPEED": 50,
		"ATTACK": 1,
		"RANGE": 180,
		"PROJECTILE": "FANG",
		"BUILD_OPTIONS": [],
		"MAGIC_REWARD": {
			"MINES": 1,
			"AMOUNT": [40,60]
		}
	},
	"SEA_MONSTER": {
		"SIZE": Vector2(155,50),
		"HP_MAX": 200,
		"SPEED": 50,
		"ATTACK": 2,
		"RANGE": 0,
		"BUILD_OPTIONS": [],
		"MAGIC_REWARD": {
			"MINES": 2,
			"AMOUNT": [40,60]
		}
	},
	"CORAL_GOLUM": {
		"SIZE": Vector2(94,142),
		"HP_MAX": 500,
		"SPEED": 50,
		"ATTACK": 5,
		"RANGE": 180,
		"PROJECTILE": "BARNACLE",
		"BUILD_OPTIONS": [],
		"MAGIC_REWARD": {
			"MINES": 3,
			"AMOUNT": [40,60]
		}
	}
}


var mine_types_conf = {
	"TREE": {
		"RESOURCE": "WOOD",
		"AMOUNT": 20,
		"SIZE": Vector2(30,37.5)
	},
	"BERRY": {
		"RESOURCE": "FOOD",
		"AMOUNT": 20,
		"SIZE": Vector2(50,50)
	},
	"STONE_MINE": {
		"RESOURCE": "STONE",
		"AMOUNT": 20,
		"SIZE": Vector2(64,37)
	},
	"GOLD_MINE": {
		"RESOURCE": "GOLD",
		"AMOUNT": 20,
		"SIZE": Vector2(50,50)
	},
	"MAGIC_FLOWER": {
		"RESOURCE": "MAGIC",
		"AMOUNT": 20,
		"SIZE": Vector2(50,50)
	}
}


var building_types_conf = {
	"TOWN_CENTER": {
		"COST": {
			"WOOD": 200,
			"STONE": 200
		},
		"HP_MAX": 200,
		"POPULATION": 15,
		"BUILD_OPTIONS": ["WORKER"]
	},
	"HUT": {
		"COST": {
			"WOOD": 20
		},
		"HP_MAX": 20,
		"POPULATION": 5,
		"BUILD_OPTIONS": []
	},
	"BARRACKS": {
		"COST": {
			"WOOD": 100,
			"STONE": 100
		},
		"HP_MAX": 100,
		"POPULATION": 0,
		"BUILD_OPTIONS": ["SWORDSMAN", "MAGIC_SWORDSMAN", "MAGIC_CHARIOT"]
	},
	"ARCHERY_RANGE": {
		"COST": {
			"WOOD": 150,
			"STONE": 150,
		},
		"HP_MAX": 100,
		"POPULATION": 0,
		"BUILD_OPTIONS": ["ARCHER", "CATAPULT", "MAGIC_CATAPULT"]
	},
	"TEMPLE": {
		"COST": {
			"STONE": 100,
			"GOLD": 100
		},
		"HP_MAX": 100,
		"POPULATION": 0,
		"BUILD_OPTIONS": []
	},
	"WOOD_TOWER": {
		"COST": {
			"WOOD": 50
		},
		"HP_MAX": 50,
		"ATTACK": 2,
		"RANGE": 200,
		"PROJECTILE": "ARROW",
		"POPULATION": 0,
		"BUILD_OPTIONS": []
	},
	"STONE_TOWER": {
		"COST": {
			"STONE": 60
		},
		"HP_MAX": 60,
		"ATTACK": 3,
		"RANGE": 220,
		"PROJECTILE": "STONE",
		"POPULATION": 0,
		"BUILD_OPTIONS": []
	},
	"MAGIC_CASTLE": {
		"COST": {
			"MAGIC": 70
		},
		"HP_MAX": 70,
		"ATTACK": 5,
		"RANGE": 240,
		"PROJECTILE": "MAGIC_PIECE",
		"POPULATION": 0,
		"BUILD_OPTIONS": []
	},
}


var game_res = {}


var phase_names = ["Morning", "Evening"]
var phase_music = ["GAME_MUSIC_DAY", "GAME_MUSIC_NIGHT"]

var result_str = [
	"Victory!\n\nAtlantis is an advanced civilization.\nSea monsters? Now that's the stuff of legend.",
	"Defeat\n\nAtlantis? Seems like a fairytale.\nWe haven't found anything yet to prove its existence.",
]

var Mine = preload("res://scenes/Mine.tscn")
var Unit = preload("res://scenes/Unit.tscn")
var Building = preload("res://scenes/Building.tscn")
var BuildButton = preload("res://scenes/BuildButton.tscn")
var Projectile = preload("res://scenes/Projectile.tscn")

var MainMenu = preload("res://scenes/MainMenu.tscn")
var Game = preload("res://scenes/Game.tscn")
var GameOver = preload("res://scenes/GameOver.tscn")



func get_display_str(text: String) -> String:
	return(text.replace("_", " ").capitalize())


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass





