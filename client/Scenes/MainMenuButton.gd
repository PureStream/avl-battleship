extends Node2D

signal change_screen

#for demo build
const disable_buttons = [MenuButtonEnums.STANDARD, MenuButtonEnums.DATABASE, MenuButtonEnums.TEAM_SETUP, MenuButtonEnums.HOW_TO_PLAY]

func _ready():
	print(disable_buttons)
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
	print("num is " + str(num)) 
	#demo
	if num in disable_buttons:
		$MenuButton.disabled = true
		$Button.disabled = true

func _on_MenuButton_pressed():
	emit_signal("change_screen", ID) # Replace with function body.
