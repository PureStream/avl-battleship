extends Panel
 
onready var slots = $VBoxContainer.get_children()
var ships = {}
 
func _ready():
	slots.remove(0)
	for slot in slots:
		ships[slot.name] = null
 
func insert_ship(ship):
#	var ship_pos = ship.rect_global_position + ship.rect_size / 2

	var ship_slot = get_slot_from_id(ship)
	if ship_slot < 0:
		return false
	var slot_name = "Ship"+String(ship_slot+1)
	if ships[slot_name] != null:
		return false
	ships[slot_name] = ship
	var slot = slots[ship_slot]
	ship.rect_rotation = 0
	ship.rect_global_position = slot.rect_global_position
	ship.rect_global_position = realign_position(ship)
	ship.rect_rotation = -270
	return true
 
func swap_xy(vector:Vector2):
	var tmp = vector.x
	vector.x = vector.y
	vector.y = tmp
	return vector

func realign_position(ship):
	var ship_pos = ship.rect_global_position
	ship_pos -= ship.rect_pivot_offset - swap_xy(ship.rect_pivot_offset)
	return ship_pos

func grab_ship(pos):
	var slot = get_slot_under_pos(pos)
	if slot == null:
		return null
	var ship = ships[slot.name]
	if ship == null:
		return null
	ships[slot.name] = null
	return ship

func get_slot_from_id(ship):
	if ship.has_method("get_order"):
		return ship.get_order()
	else:
		return -1
	
func get_slot_under_pos(pos):
	return get_thing_under_pos(slots, pos)
 
func get_ship_under_pos(pos):
	return get_thing_under_pos(ships.values(), pos)
 
func get_thing_under_pos(arr, pos):
	for thing in arr:
		if thing != null and thing.get_global_rect().has_point(pos):
			return thing
	return null