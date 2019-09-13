extends Node

func _ready():
	pass
	
class MenuButtonEnum:
	enum Menu{
		HOW_TO_PLAY,
		BASIC,
		CLASSIC,
		BLITZ,
		TEAM_SETUP,
		OPTIONS,
		CREDITS
	}
	
	const BUTTON_NAMES = {
		Menu.HOW_TO_PLAY:"How To Play",
		Menu.BASIC:"Basic",
		Menu.CLASSIC:"Classic",
		Menu.BLITZ:"Blitz",
		Menu.TEAM_SETUP:"Team Setup",
		Menu.OPTIONS:"Options",
		Menu.CREDITS:"Credits"}

	static func get_button_names():
		return BUTTON_NAMES