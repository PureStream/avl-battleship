extends Node

var ships = {}
var ship_loc = {}
var connected_player = null
var ready = false

func _ready():
	pass # Replace with function body.

func set_id(id):
	name = str(id)
	
func init_grid(size):
	for x in range(size):
		ship_loc[x] = {}
		for y in range(size):
			ship_loc[x][y] = false
	for ship in ships:
		var is_right = false
		if int(abs(ship["angle"])) % 180 == 90:
			is_right = true
		set_grid(ship["g_pos"], ShipDB.SHIPS[ship["id"]]["size"], is_right, true)

func set_grid(pos, length, is_right, value):
	if is_right:
		for i in range(length):
			ship_loc[pos.x+i][pos.y] = value
	else:
		for i in range(length):
			ship_loc[pos.x][pos.y+i] = value