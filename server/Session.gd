extends Node

var id = -1
var connected_players = []
var max_ship = 4
var board_size = 8
var player_turn = null
var round_num = 1
var turn_num = 1
var prev_winner = null
var button = null
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func soft_reset():
	prev_winner = null
	player_turn = null
	round_num = 1
	turn_num = 1

func reset():
	var id = -1
	var connected_players = []
	var max_ship = 4
	var board_size = 8
	var player_turn = null
	var round_num = 1
	var turn_num = 1
	var prev_winner = null
	var button = null