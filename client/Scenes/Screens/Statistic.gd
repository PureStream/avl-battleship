extends Control

onready var username = $VBoxContainer/Username
onready var hit_rate_node = $VBoxContainer/HitRate
onready var win_rate_node = $VBoxContainer/Winrate

var hit = 0
var miss = 0 
var shot_fired = 0
var hit_rates = 0
var win = 0
var lose = 0
var total_round = 0
var win_rate = 0

var userdata = {}

func _ready():
	username.text = "Username: " + Global.username
	userdata = Global.userdata
	hit_rate_node.text = "Hit rate: " + get_hit_rate() +"%"
	win_rate_node.text = "Win rate: " + get_win_rate() +"%"

# func receive_player_profile(profile):
# 	hit = profile["hit"]
# 	miss = profile["miss"]
# 	shot_fired = profile["shot_fired"]
# 	win = profile["win"]
# 	lose = profile["lose"]
# 	total_round = profile["total_round"]

func get_hit_rate():
	hit_rates = float(userdata.hit/shot_fired*100)
	return hit_rates
	
func get_win_rate():
	win_rate = float(userdata.win/total_round)
	return win_rate