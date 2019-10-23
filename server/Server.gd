extends Node

var session_id = -1
const PORT = 1337
const MAX_PLAYERS = 200
const IP_ADDRESS = "127.0.0.1"

onready var status_label = $HBoxContainer/Labels/StatusLabel
onready var user_count_label = $HBoxContainer/Labels/UserCountLabel
onready var players = $Players
onready var session_container = $HBoxContainer/VBoxContainer/SessionContainer/SessionButtonContainer
onready var session_label = $HBoxContainer/VBoxContainer/SelectedSessionLabel
var player = preload("res://Player.tscn")
var session_btn = preload("res://SessionSelectButton.tscn")

func _ready():
	var network = NetworkedMultiplayerENet.new()
	network.create_server(PORT, MAX_PLAYERS)
	get_tree().set_network_peer(network)
	Lobby.server = self
	Lobby.players = players
	Lobby.in_game = $InGame
	Lobby.sessions = $GameSession
	Lobby.matching = $Matching
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

func _peer_connected(id):
	status_label.text += "\n" + str(id) + " connected."
	user_count_label.text = "Total users: " +  str(get_tree().get_network_connected_peers().size())
	Lobby.peer_connected(id)
	
func _peer_disconnected(id):
	status_label.text += "\n" + str(id) + " disconnected."
	user_count_label.text = "Total users: " +  str(get_tree().get_network_connected_peers().size())
	Lobby.peer_disconnected(id)

func _on_Reset_pressed(): 
	if selected_session >= 0:
		Lobby.reset_session(selected_session)

var selected_session = -1

func add_session_button(session_id):
	var new_btn = session_btn.instance()
	new_btn.text = str("%05d" % session_id)
	new_btn.set_meta("id", session_id)
	new_btn.connect("session_select", self, "select_session")
	session_container.add_child(new_btn)
	return new_btn
	
func select_session(session_id):
	selected_session = session_id
	session_label.text = "Selected session " + "%05d" % selected_session
	
func deselect():
	selected_session = -1
	session_label.text = "Not selected"