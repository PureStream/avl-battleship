extends Control

var buttons = []
onready var panel_label = $HBoxContainer/Panel/Label

var is_show = false

signal select_mode
signal disable_button

# Called when the node enters the scene tree for the first time.
func _ready():
	for btn in $HBoxContainer/VBoxContainer.get_children():
		btn.connect("pressed", self, "select_mode", [btn])
		buttons.append(btn)
	hide_buttons()

func select_mode(btn):
	if btn.get_meta("mode") != Global.game_mode || is_show:
		emit_signal("select_mode", btn.get_meta("mode"))
		hide_buttons()
	else:
		show_buttons()
		emit_signal("disable_button")

func hide_buttons():
	is_show = false
	panel_label.text = "<"
	for i in range(1,3):
		buttons[i].visible = false
	
func show_buttons():
	is_show = true
	panel_label.text = "v"
	for i in range(3):
		buttons[i].visible = true
		
func set_buttons(arr):
	for i in range(3):
		buttons[i].text = arr[i].text
		buttons[i].set_meta("mode", arr[i].mode)