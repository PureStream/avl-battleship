extends Node

var ships = {}
var ship_loc = {}
var ship_damage = {}
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

func set_damage(target_pos):
	for ship in ships:
		if !contain_pos(ship, target_pos):
			return -1
		else:
			return ship["g_pos"]
		
		
func contain_pos(ship, target_pos):
	var ship_length = ShipDB.SHIPS[ship["id"]]["size"]
	if int(abs(ship["angle"])) % 180 == 90:
		if (target_pos.y == ship["g_pos"].y):
			if abs(target_pos.x - ship["g_pos"].x) < ship_length:
				return true
			else:
				return false
	elif (target_pos.x == ship["g_pos"].x):
			if abs(target_pos.y - ship["g_pos"].y) < ship_length:
				return true
			else:
				return false
		
func set_grid(pos, length, is_right, value):
	if is_right:
		for i in range(length):
			ship_loc[pos.x+i][pos.y] = value
	else:
		for i in range(length):
			ship_loc[pos.x][pos.y+i] = value