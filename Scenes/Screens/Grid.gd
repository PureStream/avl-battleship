extends TextureRect
 
var items = []
 
var grid = {}
var cell_size = 96
var grid_width = 0
var grid_height = 0
 
func _ready():
	var s = get_grid_size(self)
	grid_width = s.x
	grid_height = s.y
   
	for x in range(grid_width):
		grid[x] = {}
		for y in range(grid_height):
			grid[x][y] = false
 
func insert_item(item):
	var item_pos = get_proper_position(item)
#	print(item.rect_position)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	if is_grid_space_available(g_pos.x, g_pos.y, item_size.x, item_size.y):
		set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, true)
		item.rect_position = rect_position + Vector2(g_pos.x, g_pos.y) * cell_size
		fix_position(item)
		items.append(item)
		return true
	else:
		return false
 
func swap_xy(vector:Vector2):
	var tmp = vector.x
	vector.x = vector.y
	vector.y = tmp
	return vector

func get_proper_position(item):
	var item_pos = item.rect_position + Vector2(cell_size / 2, cell_size / 2)
	match int(abs(item.rect_rotation)) % 180:
		90:
			item_pos += item.rect_pivot_offset - swap_xy(item.rect_pivot_offset)
	return item_pos

func fix_position(item):
	match int(abs(item.rect_rotation)) % 180:
		90:
			item.rect_position -= item.rect_pivot_offset - swap_xy(item.rect_pivot_offset)

func get_proper_position2(item):
	var item_pos = item.rect_position
	match int(abs(item.rect_rotation)) % 180:
		90:
			item_pos += item.rect_pivot_offset - swap_xy(item.rect_pivot_offset)
	return item_pos

func grab_item(pos):
	var item = get_item_under_pos(pos)
	if item == null:
		return null
   
	var item_pos = get_proper_position(item)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, false)
   
	items.remove(items.find(item))
	return item
 
func pos_to_grid_coord(pos):
	var local_pos = pos - rect_position
	var results = {}
	results.x = int(local_pos.x / cell_size)
	results.y = int(local_pos.y / cell_size)
	return results
 
func get_grid_size(item):
	var results = {}
	var s = item.rect_size
	results.x = clamp(int(s.x / cell_size), 1, 500)
	results.y = clamp(int(s.y / cell_size), 1, 500)
	if int(abs(item.rect_rotation)) % 180 == 90:
		var tmp = results.x
		results.x = results.y
		results.y = tmp
	return results
 
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
 
func get_item_under_pos(pos):
	for item in items:
#		print(item.get_global_rect())
		if get_actual_rect(item).has_point(pos):
			return item
	return null

func get_actual_rect(item):
#	var apparent_pos = get_proper_position2(item)
	var rect:Rect2 = item.get_global_rect()
#	rect.position = apparent_pos
	match int(abs(item.rect_rotation)) % 360:
		90:
			rect.size = swap_xy(rect.size)
			rect.position.y -= rect.size.y
		180:
			rect.position -= rect.size
		270:
			rect.size = swap_xy(rect.size)
			rect.position.x -= rect.size.x
	return rect
 
func insert_item_at_first_available_spot(item):
	for y in range(grid_height):
		for x in range(grid_width):
			if !grid[x][y]:
				item.rect_position = rect_position + Vector2(x, y) * cell_size
				if insert_item(item):
					return true
	return false
