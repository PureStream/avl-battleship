extends TextureRect
 
var ships = []
 
var grid = {}
var ship_type = []
var cell_size = 96
var grid_width = 0
var grid_height = 0
onready var ships_node = get_node("/root/ShipLayout")
export (Texture) var grid8
export (Texture) var grid10
	
func _ready():
	var s = get_grid_size(self)
	grid_width = s.x
	grid_height = s.y
	print (grid_height)
   
	for x in range(grid_width):
		grid[x] = {}
		for y in range(grid_height):
			grid[x][y] = false

func insert_ship(ship):
	var ship_pos = get_proper_position(ship)
#	print(ship.rect_position)
	var g_pos = pos_to_grid_coord(ship_pos)
	var ship_size = get_grid_size(ship)
	if is_grid_space_available(g_pos.x, g_pos.y, ship_size.x, ship_size.y):
		set_grid_space(g_pos.x, g_pos.y, ship_size.x, ship_size.y, true)
		ship.rect_position = rect_position + Vector2(g_pos.x, g_pos.y) * cell_size
		fix_position(ship)
		ships.append(ship)
		ship.set_meta("grid_pos",g_pos)
		return true
	else:
		return false
 
func swap_xy(vector:Vector2):
	var tmp = vector.x
	vector.x = vector.y
	vector.y = tmp
	return vector

func get_proper_position(ship):
	var ship_pos = ship.rect_position + Vector2(cell_size / 2, cell_size / 2)
	match int(abs(ship.rect_rotation)) % 180:
		90:
			ship_pos += ship.rect_pivot_offset - swap_xy(ship.rect_pivot_offset)
	return ship_pos

func fix_position(ship):
	match int(abs(ship.rect_rotation)) % 180:
		90:
			ship.rect_position -= ship.rect_pivot_offset - swap_xy(ship.rect_pivot_offset)

func get_proper_position2(ship):
	var ship_pos = ship.rect_position
	match int(abs(ship.rect_rotation)) % 180:
		90:
			ship_pos += ship.rect_pivot_offset - swap_xy(ship.rect_pivot_offset)
	return ship_pos

func grab_ship(pos):
	var ship = get_ship_under_pos(pos)
	if ship == null:
		return null
   
	var ship_pos = get_proper_position(ship)
	var g_pos = pos_to_grid_coord(ship_pos)
	var ship_size = get_grid_size(ship)
	set_grid_space(g_pos.x, g_pos.y, ship_size.x, ship_size.y, false)
   
	ships.remove(ships.find(ship))
	return ship
 
func pos_to_grid_coord(pos):
	var local_pos = pos - rect_position
	var results = {}
	results.x = int(local_pos.x / cell_size)
	results.y = int(local_pos.y / cell_size)
	return results
 
func get_grid_size(ship):
	var results = {}
	var s = ship.rect_size
	results.x = clamp(int(s.x / cell_size), 1, 500)
	results.y = clamp(int(s.y / cell_size), 1, 500)
	if int(abs(ship.rect_rotation)) % 180 == 90:
		var tmp = results.x
		results.x = results.y
		results.y = tmp
	return results

func insert_ship_at_first_available_spot(ship):
	for y in range(grid_height):
		for x in range(grid_width):
			if !grid[x][y]:
				ship.rect_position = rect_position + Vector2(x, y) * cell_size
				if insert_ship(ship):
					return true
	return false
 
func is_grid_space_available(x, y, w ,h):
	if x < 0 or y < 0:
		return false
	if x + w > grid_width or y + h > grid_height:
		return false
	for i in range(x, x + w):
		for j in range(y, y + h):
			if grid[i][j]:
				return false
	return true
 
func set_grid_space(x, y, w, h, state):
	for i in range(x, x + w):
		for j in range(y, y + h):
			grid[i][j] = state
 
func get_ship_under_pos(pos):
	for ship in ships:
#		print(ship.get_global_rect())
		if get_actual_rect(ship).has_point(pos):
			return ship
	return null

func get_actual_rect(ship):
#	var apparent_pos = get_proper_position2(ship)
	var rect:Rect2 = ship.get_global_rect()
#	rect.position = apparent_pos
	match int(abs(ship.rect_rotation)) % 360:
		90:
			rect.size = swap_xy(rect.size)
			rect.position.y -= rect.size.y
		180:
			rect.position -= rect.size
		270:
			rect.size = swap_xy(rect.size)
			rect.position.x -= rect.size.x
	return rect
		
func ship_to_dict(ship):
	var grid_pos = ship.get_meta("grid_pos")
	var id = ship.get_meta("id")
	var angle = ship.rect_rotation
	return {"id":id, "g_pos":grid_pos, "angle":angle}
