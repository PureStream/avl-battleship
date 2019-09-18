extends Control

onready var ships_obj = get_node("/root/ShipLayout")
onready var confirm = get_node("../Confirm")
var ships = []

const ship_base = preload("res://Scenes/ShipBase.tscn")
const hit_or_miss = preload("res://Scenes/HitOrMiss.tscn")


var hit_map = []
var cell_size = 96
var grid_width = 0
var grid_height = 0
var reticle_pos = null
var reticle = null

func _ready():
	var s = get_grid_size(self)
	grid_width = s.x
	grid_height = s.y
	for x in range(grid_width):
		hit_map.append([])
		for y in range(grid_height):
			hit_map[x].append(true)
	confirm.disabled = true


func _input(event):
	if event.is_action_pressed("inv_grab"):
		if get_global_rect().has_point(event.position):
			select_target(event.position)
		
func select_target(pos):
#	var cursor_pos = get_global_mouse_position()
	var grid_pos = pos_to_grid_coord(pos)
	if reticle == null:
		reticle = hit_or_miss.instance()
		reticle.texture = load(ShipDB.get_mark("Reticle"))
		add_child(reticle)
	if hit_map[grid_pos.x][grid_pos.y]:
		confirm.disabled = false
		if reticle.visible == false:
			reticle.visible = true
		reticle.rect_position = Vector2(grid_pos.x, grid_pos.y) * cell_size
		reticle_pos = grid_pos
	
	

func pos_to_grid_coord(pos):
	var local_pos = pos - rect_global_position
	var results = {}
	results.x = int(local_pos.x / cell_size)
	results.y = int(local_pos.y / cell_size)
	return results

func insert_item(ship):
	var ship_obj = ship_base.instance()
	var ship_id = ship["id"]
	ship_obj.rect_rotation = ship["angle"]
	ship_obj.texture = load(ShipDB.get_ship(ship_id)["icon"])
	ship_obj.rect_pivot_offset = ship_obj.texture.get_size()/2
	var grid_pos = ship["g_pos"]
	ship_obj.rect_position = Vector2(grid_pos.x, grid_pos.y) * cell_size
	fix_position(ship_obj)
	add_child(ship_obj)
	ships.append(ship_obj)

func insert_mark(mark):
	var mark_obj = hit_or_miss.instance()
	var mark_id = mark["id"]
	var grid_pos = mark["g_pos"]
	mark_obj.texture = load(ShipDB.get_mark(mark_id))
	mark_obj.rect_position = Vector2(grid_pos.x, grid_pos.y) * cell_size
	add_child(mark_obj)



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



func _on_Confirm_pressed():
	var x = reticle_pos.x 
	var y = reticle_pos.y 
	if ships_obj.ships[x][y] == true:
		insert_mark({"id":"Hit","g_pos":{"x":x,"y":y}})
	else:
		insert_mark({"id":"Miss","g_pos":{"x":x,"y":y}})
	reticle.visible = false
	hit_map[x][y] = false
		
			

				
				
