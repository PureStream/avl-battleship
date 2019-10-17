extends Node

onready var greet := $GreetingPopUp

func _ready():
	pass

func show_greeting():
	if (!Global.is_welcome):
		greet.show()
		Global.is_welcome = true

func hide_greeting():
	greet.hide()
	