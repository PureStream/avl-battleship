extends Node2D

signal change_screen

func _ready():
	pass # Replace with function body.

func set_position(vector:Vector2):
	position = vector
	
func set_name(name:String):
	$MenuButton/BtnLabel.text = name

func set_rotation(deg:float):
	self.rotation_degrees = deg

var ID = -1

func set_type(num):
	ID = num

func _on_MenuButton_pressed():
	emit_signal("change_screen", ID) # Replace with function body.
