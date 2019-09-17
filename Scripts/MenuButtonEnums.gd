extends Node

func _ready():
	pass
	
enum {
	HOW_TO_PLAY,
	BASIC,
	CLASSIC,
	BLITZ,
	TEAM_SETUP,
	OPTIONS,
	CREDITS
}

const BUTTON_NAMES = {
	HOW_TO_PLAY:"How To Play",
	BASIC:"Basic",
	CLASSIC:"Classic",
	BLITZ:"Blitz",
	TEAM_SETUP:"Team Setup",
	OPTIONS:"Options",
	CREDITS:"Credits"}

static func get_button_names():
	return BUTTON_NAMES