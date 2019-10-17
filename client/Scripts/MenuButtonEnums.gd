extends Node

func _ready():
	pass
	
enum {
	HOW_TO_PLAY,
	BASIC,
	CLASSIC,
	STANDARD,
	TEAM_SETUP,
	DATABASE,
	OPTIONS,
	CREDITS
}

const BUTTON_NAMES = {
	HOW_TO_PLAY:"How To Play",
	BASIC:"Basic",
	CLASSIC:"Classic",
	STANDARD:"Standard",
	TEAM_SETUP:"Team Setup",
	DATABASE:"Database",
	OPTIONS:"Options",
	CREDITS:"Credits"}

static func get_button_names():
	return BUTTON_NAMES