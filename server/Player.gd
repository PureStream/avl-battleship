extends Node

var ships = {}
var ship_loc = {}
var ship_damage = {}
var id = -1
var connected_player = null
var score = 0
var ready = false

func _ready():
	pass # Replace with function body.

func set_id(id):
	self.id = id
	self.name = str(id)
	
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

func get_damage(target_pos):
	for ship in ships:
		set_damage(ship)
		if !contain_pos(ship, target_pos):
			return
		else:
			ship_damage[ship["id"]]["damage"].pop_front()
			ship_damage[ship["id"]]["damage"].append(true)

func set_damage(ship):
		for x in range(ships.size()):
			ship_damage[ship["id"]] = {}
			ship_damage[ship["id"]]["damage"] = []
			for y in range(ship["id"]["size"]):
				ship_damage[ship["id"]]["damage"].append(false)
		
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
			
func reset():
	pass
	#set everything back to zero or empty array/dict