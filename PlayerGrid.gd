extends Control
 
var ships = []
 
var cell_size = 96
var grid_width = 0
var grid_height = 0
 
func _ready():
	var s = get_grid_size(self)
	grid_width = s.x
	grid_height = s.y
 
func insert_item(item):
	var grid_pos = get_meta("grid_pos")
	item.rect_position = rect_position + Vector2(grid_pos.x, grid_pos.y) * cell_size
	fix_position(item)
	ships.append(item)

func swap_xy(vector:Vector2):
	var tmp = vector.x
	vector.x = vector.y
	vector.y = tmp
	return vector

func fix_position(item):
	match int(abs(item.rect_rotation)) % 180:
		90:
			item.rect_position -= item.rect_pivot_offset - swap_xy(item.rect_pivot_offset)
 
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
 
func get_item_under_pos(pos):
	for item in ships:
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

