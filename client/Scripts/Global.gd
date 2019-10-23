extends Node

var username = "avalon"
var viewing_result = false
var is_welcome = false

func _ready():
	pass # Replace with function body.

const SCREEN_PATH = {
	MenuButtonEnums.CLASSIC:{
		"path":"res://Scenes/Screens/Lobby.tscn",
		},
	MenuButtonEnums.BASIC:{
		"path":"res://Scenes/Screens/Lobby.tscn",
		},
	MenuButtonEnums.STANDARD:{
		"path":"res://Scenes/Screens/Lobby.tscn",
		},
	MenuButtonEnums.CREDITS:{
		"path":"res://Scenes/Screens/Credits.tscn",
		},
	MenuButtonEnums.DATABASE:{
		"path":"res://Scenes/Screens/Database.tscn",
		},
	MenuButtonEnums.HOW_TO_PLAY:{
		"path":"res://Scenes/Screens/HowToPlay.tscn",
		},
	MenuButtonEnums.OPTIONS:{
		"path":"res://Scenes/Screens/Options.tscn",
		},
	MenuButtonEnums.TEAM_SETUP:{
		"path":"res://Scenes/Screens/TeamSetUp.tscn",
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

class GameMode:
	enum{
		BASIC,
		CLASSIC,
		STANDARD
	}
	
	const board_size = {
		BASIC: 8,
		CLASSIC: 10,
		STANDARD: 10
	}
	
	const SCREEN_MODE = {
		MenuButtonEnums.CLASSIC:CLASSIC,
		MenuButtonEnums.BASIC:BASIC,
		MenuButtonEnums.STANDARD:STANDARD
	}

const SHIPS_DEFAULT_BASIC = ["Ship4", "Ship4", "Ship4", "Ship4"]

const SHIPS_DEFAULT_CLASSIC = ["Ship5", "Ship4", "Ship3", "Ship3", "Ship2"]

var ships_setup = []

var menu_buttons = []

#const IP_ADDRESS = "25.30.166.184"
const IP_ADDRESS = "127.0.0.1"

const PORT = 1337

