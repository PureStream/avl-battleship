extends Control
 
var ships = []

const ship_base = preload("res://Scenes/ShipBase.tscn")
const hit_or_miss = preload("res://Scenes/HitOrMiss.tscn")

var cell_size = 48
var grid_width = 0
var grid_height = 0

var grid_offset = 0
 
func _ready():
	pass
 
func set_grid_size(x,y):
	grid_width = x
	grid_height = y

func insert_item(ship):
	var ship_obj = ship_base.instance()
	var ship_id = ship["id"]
	ship_obj.rect_rotation = ship["angle"]
	ship_obj.texture = load(ShipDB.get_ship(ship_id)["icon"])
	ship_obj.rect_scale = Vector2(0.5,0.5)
	ship_obj.rect_pivot_offset = ship_obj.texture.get_size()/2
	var grid_pos = ship["g_pos"]
	ship_obj.rect_position = Vector2(grid_pos.x + grid_offset, grid_pos.y + grid_offset) * cell_size
	fix_position(ship_obj)
	add_child(ship_obj)
	ships.append(ship_obj)

func insert_mark(mark):
	var mark_obj = hit_or_miss.instance()
	var mark_id = mark["id"]
	var grid_pos = mark["g_pos"]
	mark_obj.texture = load(ShipDB.get_mark(mark_id))
	mark_obj.rect_scale = Vector2(0.5,0.5)
	mark_obj.rect_position = Vector2(grid_pos.x + grid_offset, grid_pos.y + grid_offset) * cell_size
	add_child(mark_obj)

func swap_xy(vector:Vector2):
	var tmp = vector.x
	vector.x = vector.y
	vector.y = tmp
	return vector

func fix_position(item):
	match int(abs(item.rect_rotation)) % 180:
		90:
			item.rect_position -= item.rect_pivot_offset - swap_xy(item.rect_pivot_offset)/2
		0: 
			item.rect_position -= item.rect_pivot_offset/2
 
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

