extends Control

const item_base = preload("res://Scenes/ShipBase.tscn")

onready var grid = $Grid
onready var ship_slots = $ShipSlots

var item_held:TextureRect = null
var item_offset = Vector2()
var last_container = null
var last_pos = Vector2()
var last_rot = 0

func _ready():
	pickup_item("Ship5")
	pickup_item("Ship4")
	pickup_item("Ship3")
	pickup_item("Ship3")
	pickup_item("Ship2")

var grab_toggle = false

func _process(delta):
	var cursor_pos = get_global_mouse_position()
	if Input.is_action_just_pressed("inv_grab"):
		if !grab_toggle:
			grab(cursor_pos)
		else:
			release(cursor_pos)
		grab_toggle = !grab_toggle
	if item_held != null:
		item_held.rect_global_position = cursor_pos + item_offset

func _input(event):
	if event.is_action_pressed("inv_rotate"):
		if grab_toggle:
			rotate_held_item()

func grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_item"):
		item_held = c.grab_item(cursor_pos)
		if item_held != null:
			last_container = c
			last_pos = realign_position(item_held)
			last_rot = item_held.rect_rotation
			item_offset = -item_held.rect_pivot_offset
			move_child(item_held, get_child_count())

func realign_position(item):
	var item_pos = item.rect_global_position
	match int(abs(item.rect_rotation)) % 360:
		90:
			item_pos.y -= item.rect_size.x
			item_pos -= item.rect_pivot_offset - swap_xy(item.rect_pivot_offset)
		180:
			item_pos -= item.rect_size
		270:
			item_pos.x -= item.rect_size.y
			item_pos -= item.rect_pivot_offset - swap_xy(item.rect_pivot_offset)
	return item_pos

func swap_xy(vector:Vector2):
	var tmp = vector.x
	vector.x = vector.y
	vector.y = tmp
	return vector

func release(cursor_pos):
	if item_held == null:
		return
	var c = get_container_under_cursor(cursor_pos)
	if c == null:
		return_item()
	elif c.has_method("insert_item"):
		if c.insert_item(item_held):
			item_held = null
		else:
			return_item()
	else:
		return_item()

func rotate_held_item():
	if item_held != null:
		item_held.rect_rotation -= 90
		if item_held.rect_rotation < -359:
			item_held.rect_rotation = 0

func get_container_under_cursor(cursor_pos):
	var containers = [grid, ship_slots]
	for c in containers:
		if c.get_global_rect().has_point(cursor_pos):
			return c
	return null

func drop_item():
	item_held.queue_free()
	item_held = null

func return_item():
	item_held.rect_global_position = last_pos
	item_held.rect_rotation = last_rot
	last_container.insert_item(item_held)
	item_held = null
	
var count = 0

func pickup_item(item_id):
	var item = item_base.instance()
	item.set_meta("id", item_id)
	item.set_order(count)
	count += 1
	item.texture = load(ShipDB.get_item(item_id)["icon"])
	item.rect_pivot_offset = item.texture.get_size()/2
	add_child(item)
	ship_slots.insert_item(item)
#	if !grid.insert_item_at_first_available_spot(item):
#		item.queue_free()
#		return false
	return true