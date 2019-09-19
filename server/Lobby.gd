extends Node

func _ready():
	pass # Replace with function body.

var server = null

var players = null
var in_game = null
var sessions = null
var session = preload("res://Session.tscn")

var session_id = 0
var session_dict = {}

# warning-ignore:unused_argument
remote func match_make(info):
	randomize()
	var id = get_tree().get_rpc_sender_id()
	print(str(id) + " is looking for match")
	var filtered_player = players.get_children()
	
	if(filtered_player.size() == 0):
		return
	
	var candidate = filtered_player[randi()%filtered_player.size()]
	print("chosen candidate is: " + candidate.name)
	
	if candidate.name == str(id):
		return
	
	var new_session = session.instance()
	sessions.add_child(new_session)
	session_dict[session_id] = new_session
	
	var opponent = null
	for player in players.get_children():
		if player.name == str(id) || player.name == candidate.name:
			if player.name == str(id):
				player.connected_player = candidate
				opponent = player
			call_deferred("move_to_game", player)
			new_session.connected_players.append(player)
			rpc_id(int(player.name), "player_found", session_id)
	candidate.connected_player = opponent
	session_id += 1
	
func move_to_game(node):
	node.get_parent().remove_child(node)
	in_game.add_child(node)
	
func remove_from_game(node):
	node.get_parent().remove_child(node)
	players.add_child(node)
	
remote func receive_ship_layout(session_id, layout):
	var id = get_tree().get_rpc_sender_id()
	var curr_session = session_dict[session_id]
	
	print("received layout from: "+str(id)+"\n"+str(layout))
	
	for player in curr_session.connected_players:
		if player.name == str(id):
			player.ships = layout
			player.init_grid(curr_session.board_size)
			player.ready = true

	var ready_to_start = true
	for player in curr_session.connected_players:
		if !player.ready:
			ready_to_start = false
		
	if(ready_to_start):
		begin_game(session_id)
		
func begin_game(session_id):
	var curr_session = session_dict[session_id]
	print("beginning game on: "+str(session_id))
	
	var turn = randi()%2 == 1
	rpc_id(int(curr_session.connected_players[0].name),"receive_game_begin", turn)
	rpc_id(int(curr_session.connected_players[1].name),"receive_game_begin", !turn)
	if turn:
		curr_session.player_turn = curr_session.connected_players[0]
	else: 
		curr_session.player_turn = curr_session.connected_players[1]

remote func receive_target_position(session_id, pos):
	var id = get_tree().get_rpc_sender_id()
	var curr_session = session_dict[session_id]
	print(str(id)+" targeting " + str(pos))
	if id != int(curr_session.player_turn.name):
		print("invalid turn from player: "+ id)
		return
	
	var value = curr_session.player_turn.connected_player.ship_loc[pos["x"]][pos["y"]]
	if value != null:
		rpc_id(id, "receive_target_information", value)
		rpc_id(int(curr_session.player_turn.connected_player.name), "receive_hit", pos, value)
		
remote func next_turn(session_id):
	var id = get_tree().get_rpc_sender_id()
	var curr_session = session_dict[session_id]
	
	for player in curr_session.connected_players:
		if player.name == str(id):
			if curr_session.player_turn != player:
				print("invalid turn advancement")
				return
	
	curr_session.player_turn = curr_session.player_turn.connected_player
	
	rpc_id(int(curr_session.player_turn.name), "receive_turn_start")
	
	