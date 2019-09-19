extends Node

const PORT = 1337
const MAX_PLAYERS = 200
const IP_ADDRESS = "127.0.0.1"

onready var status_label = $StatusLabel
onready var user_count_label = $UserCountLabel
onready var players = $Players
var player = preload("res://Player.tscn")

func _ready():
	var network = NetworkedMultiplayerENet.new()
	network.create_server(PORT, MAX_PLAYERS)
	get_tree().set_network_peer(network)
	Lobby.server = self
	Lobby.players = players
	Lobby.in_game = $InGame
	Lobby.sessions = $GameSession
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

func _peer_connected(id):
	status_label.text += "\n" + str(id) + " connected."
	user_count_label.text = "Total users: " +  str(get_tree().get_network_connected_peers().size())
	var new_player = player.instance()
	new_player.set_id(id)
	players.add_child(new_player)
	
func _peer_disconnected(id):
	status_label.text += "\n" + str(id) + " disconnected."
	user_count_label.text = "Total users: " +  str(get_tree().get_network_connected_peers().size())
	for player in players.get_children():
		if player.name == str(id):
			player.queue_free()