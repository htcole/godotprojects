extends Node


# Vars
var level_curr = 1;


# Config
var config = {
	"N_TILE_CHOICE": 3,
	"TILE_SELECT_COOLDOWN": 1,
	"DYNAMIC_HEALTH": false,
	"ENABLE_HEALTH_DEC": false,
	"ENABLE_PLACEMENT_REQS": true,
	"REMOVE_DEAD_TILES": true,
	"ENABLE_TERRAIN_PLACEMENT_REQS": true,
	"ENABLE_CORNER_NEIGHBORS_INTERACT": true,
	"ENABLE_CORNER_NEIGHBORS_PLACEMENT": true,
	"CELL_SIZE": Vector2(80,80),
	"GRID_SIZE": Vector2(7,7),
	"POS_START": Vector2(3,3),
	"POS_END": Vector2(16,3),
	#"POS_END": Vector2(5,3),
	"MUST_CONNECT_START": true,
	#"GOAL_TYPE": "CONNECT",
	"GOAL_TYPE": "FILL_GRID",
	"FILL_FRACTION": 1,
	"RESULT_TEXT": ["Victory!", ""],
};

var level_config = [
	{
		"TARGET_ALIVE_FRACTION":0.5,
		"RESULT_MESSAGE": [
			"Your choices prevented the world from collapsing.\nCan you do better if the challenge increases?",
			"The world has collapsed.\nMake better choices. Tread carefully."
		]
	},
	{
		"TARGET_ALIVE_FRACTION":0.7,
		"RESULT_MESSAGE": [
			"Your choices prevented the world from collapsing.\nCan you do better if the challenge increases?",
			"The world has collapsed.\nMake better choices. Tread carefully."
		]
	},
	{
		"TARGET_ALIVE_FRACTION":0.9,
		"RESULT_MESSAGE": [
			"Your choices demonstrated mastery in preventing the world from collapsing.\nCan you do this in the real world?",
			"The world has collapsed.\nMake better choices. Tread carefully."
		]
	}
];



# Scenes
var Tile = preload("res://scenes/Tile.tscn");

var MainMenu = preload("res://scenes/MainMenu.tscn");
var GameMenu = preload("res://scenes/GameMenu.tscn");
var Settings = preload("res://scenes/Settings.tscn");
var Credits = preload("res://scenes/Credits.tscn");
var Game = preload("res://scenes/Game.tscn");
var Comet = preload("res://scenes/Comet.tscn");


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



