extends Node

var network = null
const popup = preload("res://Scenes/ConnnectingPopup.tscn")
var popup_obj = null
onready var timer = $PlayerSearchTimeout

func _ready():
	Lobby.lobby = self
	Global.viewing_result = false

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
	Lobby.ready_to_match()
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
	Lobby.look_for_player(null)

func next():
	get_tree().change_scene("res://Scenes/SetShip.tscn")

func _on_PlayerSearchTimeout_timeout():
	Lobby.look_for_player(null)
	
func stop_looking():
	timer.stop()
	next()
