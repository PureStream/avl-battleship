extends Node

func _ready():
	pass # Replace with function body.

const SCREEN_PATH = {
	MenuButtonEnums.CLASSIC:{
		"path":"res://Scenes/Screens/Lobby.tscn",
		"iden":"CLASSIC"
		},
	MenuButtonEnums.TEAM_SETUP:{
		"path":"res://Scenes/Screens/TeamSetUp.tscn",
		"iden":"TEAM_SETUP"
		},
	MenuButtonEnums.CREDITS:{
		"path":"res://Scenes/Screens/Credits.tscn",
		"iden":"CREDITS"
		},
	}

var menu_buttons = []

const IP_ADDRESS = "127.0.0.1"
const PORT = 1337