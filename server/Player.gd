extends Node

onready var auth_request := $AuthRequest
onready var firestore_request := $FirestoreRequest

var session_id = -1
var matching_info = {}
var ships = {}
var ship_loc = {}
var id = -1
var connected_player = null
var score = 0
var all_scores = []
var round_score = 0
var ready = false
var uid = ""
var player_name = ""

var needs_refresh = false
var auth = null
var userdata = null

func _ready():
	auth_request.set_id(id)
	firestore_request.set_id(id)

func set_id(id):
	self.id = id
	self.name = str(id)
	
func set_profile(auth):
	self.auth = auth
	uid = auth.localid
	player_name = auth.displayname

func soft_reset():
	score = 0
	all_scores = []
	round_score = 0 
	ready = false

func reset_session():
	matching_info = {}
	ships = {}
	ship_loc = {}
	connected_player = null
	score = 0
	all_scores = []
	round_score = 0
	ready = false
	
func init_grid(size):
	for x in range(size):
		ship_loc[x] = {}
		for y in range(size):
			ship_loc[x][y] = false
	for ship in ships:
		var is_right = false
		ship["damage"] = []
		ship["destroyed"] = false
		for y in range(ShipDB.SHIPS[ship["id"]]["size"]):
			ship["damage"].append(false)
		if int(abs(ship["angle"])) % 180 == 90:
			is_right = true
		set_grid(ship["g_pos"], ShipDB.SHIPS[ship["id"]]["size"], is_right, true)

func set_damage(target_pos):
	for ship in ships:
		var damage_pos = contain_pos(ship, target_pos)
		if damage_pos < 0:
			continue
		else:
			ship["damage"][damage_pos] = true
			var destroy = true
			for x in ship["damage"]:
				if !x:
					destroy = false 
			ship["destroyed"] = destroy
			
	print(ships)
		
func contain_pos(ship, target_pos):
	var ship_length = ShipDB.SHIPS[ship["id"]]["size"]
	if int(abs(ship["angle"])) % 180 == 90:
		if (target_pos.y == ship["g_pos"].y):
			if target_pos.x - ship["g_pos"].x < ship_length:
				return target_pos.x - ship["g_pos"].x  
			else: 
				return -1
	elif (target_pos.x == ship["g_pos"].x):
			if target_pos.y - ship["g_pos"].y   < ship_length:
				return target_pos.y - ship["g_pos"].y 
			else:
				return -1
	return -1 
	
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