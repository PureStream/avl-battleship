extends TextureRect

onready var ships = get_node("/root/ShipLayout")
var PlayerShips = {}
var grid = {}
var cell_size = 96
var grid_width = 0
var grid_height = 0 
var coord = Vector2(0,0)

 
func _ready():
	PlayerShips = ships.ships
	var s = get_grid_size(self)
	grid_width = s.x
	grid_height = s.y	   
	for x in range(grid_width):
		grid[x] = {}
		for y in range(grid_height):
			grid[x][y] = false
	set_process_input(true)
	set_process(true)
	print(PlayerShips)
				
				

func _process(delta):
    pass
			
func _input(event):
	if event is InputEventMouseMotion:
		var pos = Vector2(int(grid_width/cell_size),int(grid_height/cell_size))
		if pos != coord:
			coord = pos
			print(coord)

#func insert_ship_at_first_available_spot(ship):
#	for y in range(grid_height):
#		for x in range(grid_width):
#			if !grid[x][y]:
#				ship.rect_position = rect_position + Vector2(x, y) * cell_size
#				if insert_ship(ship):
#					return true
#	return false
#
#func insert_ship(ship):
#	var ship_pos = get_proper_position(ship)
##	print(ship.rect_position)
#	var g_pos = pos_to_grid_coord(ship_pos)
#	var ship_size = get_grid_size(ship)
#	if is_grid_space_available(g_pos.x, g_pos.y, ship_size.x, ship_size.y):
#		set_grid_space(g_pos.x, g_pos.y, ship_size.x, ship_size.y, true)
#		ship.rect_position = rect_position + Vector2(g_pos.x, g_pos.y) * cell_size
#		fix_position(ship)
#		ships.append(ship)
#		return true
#	else:
#		return false
#
#func pos_to_grid_coord(pos):
#	var local_pos = pos - rect_position
#	var results = {}
#	results.x = int(local_pos.x / cell_size)
#	results.y = int(local_pos.y / cell_size)
#	return results
#
#func swap_xy(vector:Vector2):
#	var tmp = vector.x
#	vector.x = vector.y
#	vector.y = tmp
#	return vector
#
#func set_grid_space(x, y, w, h, state):
#	for i in range(x, x + w):
#		for j in range(y, y + h):
#			grid[i][j] = state
#
#func fix_position(ship):
#	match int(abs(ship.rect_rotation)) % 180:
#		90:
#			ship.rect_position -= ship.rect_pivot_offset - swap_xy(ship.rect_pivot_offset)
#
#func is_grid_space_available(x, y, w ,h):
#	if x < 0 or y < 0:
#		return false
#	if x + w > grid_width or y + h > grid_height:
#		return false
#	for i in range(x, x + w):
#		for j in range(y, y + h):
#			if grid[i][j]:
#				return false
#	return true
#
#func get_proper_position(ship):
#	var ship_pos = ship.rect_position + Vector2(cell_size / 2, cell_size / 2)
#	match int(abs(ship.rect_rotation)) % 180:
#		90:
#			ship_pos += ship.rect_pivot_offset - swap_xy(ship.rect_pivot_offset)
#	return ship_pos
#
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