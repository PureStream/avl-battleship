extends TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var order = -1

func set_order(order:int):
	self.order = order
	
func get_order():
	return order