extends Popup

var cancel_enabled = true

onready var cancel = $Panel/VBoxContainer/Cancel
onready var label = $Panel/VBoxContainer/Label

func _ready():
	pass

func cancel_rematch():
	cancel.text = "Ok"
	cancel_enabled = false
	label.text = "Opponent has disconnected."