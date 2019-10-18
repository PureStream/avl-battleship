extends Node

onready var greet := $GreetingPopUp
onready var greet_text := $GreetingPopUp/GreetingText

func _ready():
	greet_text.text = "Welcome Back,\n"+Global.username

func show_greeting():
	if (!Global.is_welcome):
		greet.show()
		Global.is_welcome = true

func hide_greeting():
	greet.hide()
	