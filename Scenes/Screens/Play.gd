extends Control

var DisplayValue = 10
const ship_base = preload("res://Scenes/ShipBase.tscn")
var count = 0

onready var timer = get_node("Timer")
onready var playerGrid = $PlayerGrid
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.set_wait_time(1)
	timer.start()

#func _input(event):
#	if event is InputEventMouseButton:
#		print("Mouse Click at", event.position)
#	elif event is InputEventMouseMotion:
#		print("Mouse Motion at: ", event.position)

#func pickup_ship(ship_id):
#	var ship = ship_base.instance()
#	ship.set_meta("id", ship_id)
#	ship.set_order(count)
#	count += 1
#	ship.texture = load(ShipDB.get_ship(ship_id)["icon"])
#	ship.rect_pivot_offset = ship.texture.get_size()/2
#	add_child(ship)
##	ship_slots.insert_ship(ship)
#	if !playerGrid.insert_ship_at_first_available_spot(ship):
#		ship.queue_free()
#		return false
#	return true

func _on_Timer_timeout():
	if DisplayValue > 0:
		DisplayValue -= 1
