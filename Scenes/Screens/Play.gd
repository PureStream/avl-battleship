extends Control

var DisplayValue = 10
const ship_base = preload("res://Scenes/ShipBase.tscn")
var count = 0

onready var timer = get_node("Timer")
onready var player_grid = $PlayerGrid
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.set_wait_time(1)
	timer.start()
	var ships = ShipLayout.ships_list
	for ship in ships:
		player_grid.insert_item(ship)


func _on_Timer_timeout():
	if DisplayValue > 0:
		DisplayValue -= 1


