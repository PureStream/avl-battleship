extends Node

const ICON_PATH = "res://Images/Ships/"
const SHIPS = {
	"Ship2": {
		"icon": ICON_PATH + "Ship2.png",
		"size": 2
	},
	"Ship3": {
		"icon": ICON_PATH + "Ship3.png",
		"size": 3
	},
	"Ship4": {
		"icon": ICON_PATH + "Ship4.png",
		"size": 4
	},
		"Ship5": {
		"icon": ICON_PATH + "Ship5.png",
		"size": 5
	}
}

func get_item(ship_id):
	if ship_id in SHIPS:
		return SHIPS[ship_id]
	else:
		return SHIPS["Ship3.png"]
