extends Node2D

func _ready():
	pass # Replace with function body.

func set_position(vector:Vector2):
	position = vector
	
func set_name(name:String):
	$MenuButton/BtnLabel.text = name

func set_rotation(deg:float):
	self.rotation_degrees = deg