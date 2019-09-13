extends Panel
 
onready var slots = $VBoxContainer.get_children()
var items = {}
 
func _ready():
	for slot in slots:
		items[slot.name] = null
 
func insert_item(item):
#	var item_pos = item.rect_global_position + item.rect_size / 2

	var item_slot = get_slot_from_id(item)
	if item_slot < 0:
		return false
	var slot_name = "Ship"+String(item_slot+1)
	if items[slot_name] != null:
		return false
	items[slot_name] = item
	var slot = slots[item_slot]
	item.rect_rotation = 0
	item.rect_global_position = slot.rect_global_position
	item.rect_global_position = realign_position(item)
	item.rect_scale = rect_scale
	item.rect_rotation = -270
	return true
 
func swap_xy(vector:Vector2):
	var tmp = vector.x
	vector.x = vector.y
	vector.y = tmp
	return vector

func realign_position(item):
	var item_pos = item.rect_global_position
	var offset = item.rect_pivot_offset - swap_xy(item.rect_pivot_offset)
	item_pos -= offset
	return item_pos

func grab_item(pos):
	var slot = get_slot_under_pos(pos)
	if slot == null:
		return null
	var item = items[slot.name]
	if item == null:
		return null
	items[slot.name] = null
	item.rect_scale = Vector2(1,1)
	return item

func get_slot_from_id(item):
	if item.has_method("get_order"):
		return item.get_order()
	else:
		return -1
	
func get_slot_under_pos(pos):
	return get_thing_under_pos(slots, pos)
 
func get_item_under_pos(pos):
	return get_thing_under_pos(items.values(), pos)
 
func get_thing_under_pos(arr, pos):
	for thing in arr:
		if thing != null and thing.get_global_rect().has_point(pos):
			return thing
	return null