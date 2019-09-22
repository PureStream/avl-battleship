extends Node

func _ready():
	pass # Replace with function body.

var server = null

var players = null
var in_game = null
var sessions = null
var session = preload("res://Session.tscn")

var ships_left = 4
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
	print("chosen candidate is: " + str(candidate.id))
	
	if candidate.id == id:
		return
	
	var new_session = session.instance()
	sessions.add_child(new_session)
	session_dict[session_id] = new_session
	
	var opponent = null
	for player in players.get_children():
		if player.id == id || player.id == candidate.id:
			if player.id == id:
				player.connected_player = candidate
				opponent = player
			call_deferred("move_to_game", player)
			new_session.connected_players.append(player)
			rpc_id(player.id, "player_found", session_id)
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
		if player.id == id:
			player.ships = layout
			player.init_grid(curr_session.board_size)
			player.ready = true

	var ready_to_start = true
	for player in curr_session.connected_players:
		if !player.ready:
			ready_to_start = false
		
	if(ready_to_start):
		begin_game(session_id)
		for player in curr_session.connected_players:
			player.ready = false
		
func begin_game(session_id):
	var curr_session = session_dict[session_id]
	print("beginning game on: "+str(session_id))
	
	var turn = randi()%2 == 1
	rpc_id(curr_session.connected_players[0].id,"receive_game_begin", turn)
	rpc_id(curr_session.connected_players[1].id,"receive_game_begin", !turn)
	
	if turn:
		curr_session.player_turn = curr_session.connected_players[0]
	else: 
		curr_session.player_turn = curr_session.connected_players[1]
	
remote func set_ready(session_id):
	var id = get_tree().get_rpc_sender_id()
	var curr_session = session_dict[session_id]
	var turn = randi()%2 == 1
	if id != curr_session.player_turn.id:
		print("invalid turn from player: "+ str(id))
		return
	var curr_player = curr_session.player_turn
	var curr_enemy = curr_session.player_turn.connected_player
	rpc_id(curr_player.id ,"receive_round_num", curr_player.round_num)
	rpc_id(curr_enemy.id , "receive_round_num", curr_enemy.round_num)
	rpc_id(id, "receive_score", {"player":curr_player.score, "enemy":curr_enemy.score})
	rpc_id(curr_enemy.id, "receive_score", {"player":curr_enemy.score, "enemy":curr_player.score})
	rpc_id(curr_player.id ,"receive_round_score", curr_player.round_score)
	rpc_id(curr_enemy.id , "receive_round_score", curr_enemy.round_score)

#remote func set_reset(session_id):
#	var id = get_tree().get_rpc_sender_id()
#	var curr_session = session_dict[session_id]
#	var turn = randi()%2 == 1
#	if id != curr_session.player_turn.id:
#		print("invalid turn from player: "+ str(id))
#		return
#	var curr_player = curr_session.player_turn
#	var curr_enemy = curr_session.player_turn.connected_player
#	curr_player.score = 0
#	curr_player.round_score = 0 
#	curr_enemy.score = 0
#	curr_enemy.score = 0
#	rpc_id(curr_player.id ,"receive_round_num", curr_player.round_num)
#	rpc_id(curr_enemy.id , "receive_round_num", curr_enemy.round_num)
#	rpc_id(id, "receive_score", {"player":curr_player.score, "enemy":curr_enemy.score})
#	rpc_id(curr_enemy.id, "receive_score", {"player":curr_enemy.score, "enemy":curr_player.score})
#	rpc_id(curr_player.id ,"receive_round_score", curr_player.round_score)
#	rpc_id(curr_enemy.id , "receive_round_score", curr_enemy.round_score)
	
remote func set_skip(session_id):
	var id = get_tree().get_rpc_sender_id()
	var curr_session = session_dict[session_id]
	var turn = randi()%2 == 1
	if id != curr_session.player_turn.id:
		print("invalid turn from player: "+ str(id))
		return
	var curr_player = curr_session.player_turn
	var curr_enemy = curr_session.player_turn.connected_player
	curr_player.round_score += 1
	if(curr_player.round_score >= 2):
		rpc_id(curr_player.id, "set_winlost_text", "Win")
		rpc_id(curr_enemy.id, "set_winlost_text", "Lost")
		rpc_id(curr_player.id, "show_popup")
		rpc_id(curr_enemy.id, "show_popup")
		return
	rpc_id(curr_player.id,"reset_game")
	rpc_id(curr_enemy.id,"reset_game")
	rpc_id(curr_player.id,"clear_ships")
	rpc_id(curr_enemy.id,"clear_ships")	

remote func receive_target_position(session_id, pos):
	var id = get_tree().get_rpc_sender_id()
	var curr_session = session_dict[session_id]
	var turn = randi()%2 == 1
	print(str(id)+" targeting " + str(pos))
	if id != curr_session.player_turn.id:
		print("invalid turn from player: "+ str(id))
		return
	
	var value = curr_session.player_turn.connected_player.ship_loc[pos["x"]][pos["y"]]
	var curr_player = curr_session.player_turn
	var curr_enemy = curr_session.player_turn.connected_player
	var all_destroyed = false
	rpc_id(id, "receive_score", {"player":curr_player.score, "enemy":curr_enemy.score})
	rpc_id(curr_enemy.id, "receive_score", {"player":curr_enemy.score, "enemy":curr_player.score})
	if value != null:
		rpc_id(id, "receive_target_information", value)
		if value:
			curr_player.score += 1
			curr_enemy.set_damage(pos)
			all_destroyed = true
			ships_left = 4
			for ship in curr_enemy.ships:
				if ship["destroyed"] == true:
					ships_left = ships_left - 1
				if !ship["destroyed"]:
					all_destroyed = false
			print(ships_left)
			rpc_id(curr_enemy.id, "receive_ships_left", ships_left)  
			rpc_id(id, "receive_score", {"player":curr_player.score, "enemy":curr_enemy.score})
			rpc_id(curr_enemy.id, "receive_score", {"player":curr_enemy.score, "enemy":curr_player.score})
			
		rpc_id(curr_enemy.id, "receive_hit", pos, value)
		if(all_destroyed):
			curr_player.round_num += 1
			curr_enemy.round_num += 1
			curr_player.round_score += 1	
			if(curr_player.round_score >= 2):
				rpc_id(curr_player.id, "set_winlost_text", "Win")
				rpc_id(curr_enemy.id, "set_winlost_text", "Lost")
				rpc_id(curr_player.id, "show_popup")
				rpc_id(curr_enemy.id, "show_popup")
				return
			rpc_id(curr_player.id,"reset_game")
			rpc_id(curr_enemy.id,"reset_game")
			rpc_id(curr_player.id,"clear_ships")
			rpc_id(curr_enemy.id,"clear_ships")
		
remote func next_turn(session_id):
	var id = get_tree().get_rpc_sender_id()
	var curr_session = session_dict[session_id]
	
	for player in curr_session.connected_players:
		if player.id == id:
			if curr_session.player_turn != player:
				print("invalid turn advancement")
				return
		
	curr_session.player_turn = curr_session.player_turn.connected_player
	
	rpc_id(curr_session.player_turn.id, "receive_turn_start")
	
	