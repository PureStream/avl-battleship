extends Node

var network = null
const popup = preload("res://Scenes/ConnnectingPopup.tscn")
var popup_obj = null
onready var timer = $PlayerSearchTimeout
onready var mode_button = $MarginContainer/HBoxContainer/ModePanel/MarginContainer/ModeButton
onready var other_button_container = $MarginContainer/HBoxContainer/ModePanel/VBoxContainer

var mode_text = {
		Global.GameMode.BASIC: "Basic",
		Global.GameMode.CLASSIC: "Classic",
		Global.GameMode.STANDARD: "Standard"
	}

class mode_data:
	var text
	var mode

func _ready():
	Lobby.lobby = self
	Global.viewing_result = false
	change_mode(Lobby.game_mode)

func change_mode(mode):
	var mode_arr = []
	var new_data = mode_data.new()
	new_data.text = mode_text[mode]
	new_data.mode = mode
	mode_arr.append(new_data)
	for key in mode_text.keys():
		if key != mode:
			new_data = mode_data.new()
			new_data.text = mode_text[key]
			new_data.mode = key
			mode_arr.append(new_data)
	mode_button.set_buttons(mode_arr)
	Lobby.game_mode = mode
	enable_buttons()

func disable_buttons():
	for btn in other_button_container.get_children():
		btn.visible = false

func enable_buttons():
	for btn in other_button_container.get_children():
		btn.visible = true

func _process(delta):
	pass

func _on_BackButton_pressed():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")

# func _on_connection_failed():
# 	print("Error connecting to server")
# 	_on_disconnect()

func _on_Connection_pressed():
	print("ready to match")
	popup_obj = popup.instance()
	add_child(popup_obj)
	popup_obj.show()
	# popup_obj.connecting()
	popup_obj.matching()
	Lobby.ready_to_match({"mode": Lobby.game_mode})
	# var network = NetworkedMultiplayerENet.new()
	# network.create_client(Global.IP_ADDRESS, Global.PORT)
	# get_tree().set_network_peer(network)
	# network.connect("connection_failed", self, "_on_connection_failed")
	# network.connect("connection_succeeded", self, "_proceed")
	
# func _on_disconnect():
# 	get_tree().set_network_peer(null)
# 	popup_obj.queue_free()

# func _proceed():
# 	popup_obj.connect("cancel", self, "_on_disconnect")
# 	Lobby.ready_to_match()

func start_matching():
	# popup_obj.matching()
	timer.start()
	Lobby.look_for_player()

func next():
	get_tree().change_scene("res://Scenes/SetShip.tscn")
	Settings.stop_bgm()

func _on_PlayerSearchTimeout_timeout():
	Lobby.look_for_player()
	
func stop_looking():
	timer.stop()
	next()

func _on_ModeButton_pressed():
	pass # Replace with function body.


func disable_button():
	pass # Replace with function body.
