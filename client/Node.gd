extends Node

onready var clicksound := $ClickSound

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_Button_pressed():
	clicksound.play()