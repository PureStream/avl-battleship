extends Node

var username = ""
var viewing_result = false
var is_welcome = false

func _ready():
	pass # Replace with function body.

const SCREEN_PATH = {
	MenuButtonEnums.CLASSIC:{
		"path":"res://Scenes/Screens/Lobby.tscn",
		"iden":"CLASSIC"
		},
	MenuButtonEnums.CREDITS:{
		"path":"res://Scenes/Screens/Credits.tscn",
		"iden":"CREDITS"
		},
	MenuButtonEnums.DATABASE:{
		"path":"res://Scenes/Screens/Database.tscn",
		"iden":"DATABASE"
		},
	MenuButtonEnums.HOW_TO_PLAY:{
		"path":"res://Scenes/Screens/HowToPlay.tscn",
		"iden":"HOW_TO_PLAY"
		},
	MenuButtonEnums.OPTIONS:{
		"path":"res://Scenes/Screens/Options.tscn",
		"iden":"OPTIONS"
		},
	MenuButtonEnums.TEAM_SETUP:{
		"path":"res://Scenes/Screens/TeamSetUp.tscn",
		"iden":"TEAM_SETUP"
		},
	}

class Characters:
	enum {
		A,
		B,
		C,
		D,
		E,
		Total
	}

var menu_buttons = []

#const IP_ADDRESS = "25.30.166.184"
const IP_ADDRESS = "127.0.0.1"

const PORT = 1337

