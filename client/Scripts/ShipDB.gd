extends Node

const MARK_PATH = "res://Images/UI/"
const ICON_PATH = "res://Images/Ships/"
const MARKS = {
	"Hit": MARK_PATH + "hit.png",
	"Miss": MARK_PATH + "miss.png",
	"Reticle": MARK_PATH + "reticle.png"
}

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

func get_ship(ship_id):
	if ship_id in SHIPS:
		return SHIPS[ship_id]
	else:
		return SHIPS["Ship3"]

func get_mark(mark_id):
	if mark_id in MARKS:
		return MARKS[mark_id]
	else:
		return MARKS["Miss"]
