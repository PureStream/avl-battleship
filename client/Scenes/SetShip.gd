extends Control

const ship_base = preload("res://Scenes/ShipBase.tscn")
const play = preload("res://Scenes/Screens/Play.tscn")

onready var grid = $Grid
onready var ship_slots = $ShipSlots
onready var confirm = $Button
onready var nickname = $Nickname

var ship_held:TextureRect = null
var ship_offset = Vector2()
var last_container = null
var last_pos = Vector2()
var last_rot = 0

func _ready():
	Lobby.set_ship = self
	pickup_ship("Ship4")
	pickup_ship("Ship4")
	pickup_ship("Ship4")
	pickup_ship("Ship4")

var grab_toggle = false

func _process(delta):
	var cursor_pos = get_global_mouse_position()
	if Input.is_action_just_pressed("inv_grab"):
		if !grab_toggle:
			grab(cursor_pos)
		else:
			release(cursor_pos)
		grab_toggle = !grab_toggle
	if ship_held != null:
		ship_held.rect_global_position = cursor_pos + ship_offset

func _input(event):
	if event.is_action_pressed("inv_rotate"):
		if grab_toggle:
			rotate_held_ship()

func grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_ship"):
		ship_held = c.grab_ship(cursor_pos)
		if ship_held != null:
			last_container = c
			last_pos = realign_position(ship_held)
			last_rot = ship_held.rect_rotation
			ship_offset = -ship_held.rect_pivot_offset
			move_child(ship_held, get_child_count())

func realign_position(ship):
	var ship_pos = ship.rect_global_position
	match int(abs(ship.rect_rotation)) % 360:
		90:
			ship_pos.y -= ship.rect_size.x
			ship_pos -= ship.rect_pivot_offset - swap_xy(ship.rect_pivot_offset)
		180:
			ship_pos -= ship.rect_size
		270:
			ship_pos.x -= ship.rect_size.y
			ship_pos -= ship.rect_pivot_offset - swap_xy(ship.rect_pivot_offset)
	return ship_pos

func swap_xy(vector:Vector2):
	var tmp = vector.x
	vector.x = vector.y
	vector.y = tmp
	return vector

func release(cursor_pos):
	if ship_held == null:
		return
	var c = get_container_under_cursor(cursor_pos)
	if c == null:
		return_ship()
	elif c.has_method("insert_ship"):
		if c.insert_ship(ship_held):
			ship_held = null
		else:
			return_ship()
	else:
		return_ship()

func rotate_held_ship():
	if ship_held != null:
		ship_held.rect_rotation -= 90
		if ship_held.rect_rotation < -359:
			ship_held.rect_rotation = 0

func get_container_under_cursor(cursor_pos):
	var containers = [grid, ship_slots]
	for c in containers:
		if c.get_global_rect().has_point(cursor_pos):
			return c
	return null

func drop_ship():
	ship_held.queue_free()
	ship_held = null

func return_ship():
	ship_held.rect_global_position = last_pos
	ship_held.rect_rotation = last_rot
	last_container.insert_ship(ship_held)
	ship_held = null
	
var count = 0

func pickup_ship(ship_id):
	var ship = ship_base.instance()
	ship.set_meta("id", ship_id)
	ship.set_order(count)
	count += 1
	ship.texture = load(ShipDB.get_ship(ship_id)["icon"])
	ship.rect_pivot_offset = ship.texture.get_size()/2
	add_child(ship)
	ship_slots.insert_ship(ship)
#	if !grid.insert_ship_at_first_available_spot(ship):
#		ship.queue_free()
#		return false
	return true
	
func _on_Button_pressed():
	if grid.ships.size() == 4:
		for ship in grid.ships:
			var dict = grid.ship_to_dict(ship)
			ShipLayout.ships_list.append(dict)
		ShipLayout.ships = grid.grid
		confirm.disabled = true	
		Lobby.send_ship_layout(ShipLayout.ships_list, nickname.text)

func next():
	get_tree().change_scene("res://Scenes/Screens/Play.tscn")

