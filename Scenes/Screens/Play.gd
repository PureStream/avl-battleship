extends Control

var DisplayValue = 10
const ship_base = preload("res://Scenes/ShipBase.tscn")
var count = 0

onready var timer = get_node("Timer")
onready var player_grid = $PlayerGrid
onready var enemy_grid = $EnemyGrid
onready var confirm = $Confirm
onready var time = $Time
# Called when the node enters the scene tree for the first time.
func _ready():
	Lobby.connect("target_info_received", self, "render_hit")
	confirm.disabled = true
	Lobby.play = self
	timer.set_wait_time(1)
	var ships = ShipLayout.ships_list
	for ship in ships:
		player_grid.insert_item(ship)
	if Lobby.your_turn:
		new_turn()

func _on_Timer_timeout():
	if DisplayValue > 0:
		DisplayValue -= 1
		time.text = str(DisplayValue)
	else:
		Lobby.end_turn()

func _on_Confirm_pressed():
	var x = enemy_grid.reticle_pos.x 
	var y = enemy_grid.reticle_pos.y 
	timer.stop()
	Lobby.send_target_position({"x":x,"y":y})
	Lobby.end_turn()
	
func render_hit(hit):
	var x = enemy_grid.reticle_pos.x 
	var y = enemy_grid.reticle_pos.y 
	if hit:
		enemy_grid.insert_mark({"id":"Hit","g_pos":{"x":x,"y":y}})
	else:
		enemy_grid.insert_mark({"id":"Miss","g_pos":{"x":x,"y":y}})
	enemy_grid.reticle.visible = false
	enemy_grid.hit_map[x][y] = false

func receive_hit(pos, value):
	var x = pos["x"] 
	var y = pos["y"] 
	if value:
		player_grid.insert_mark({"id":"Hit","g_pos":{"x":x,"y":y}})
	else:
		player_grid.insert_mark({"id":"Miss","g_pos":{"x":x,"y":y}})

func new_turn():
	DisplayValue = 10
	time.text = str(DisplayValue)
	timer.start()