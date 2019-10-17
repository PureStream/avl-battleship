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
var session_array = []

func send_username(id, name):
	rpc_id(id, "receive_username", name)

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
	candidate.connected_player = opponent
	
	rpc_id(candidate.id, "player_found", session_id, opponent.player_name if opponent.player_name != "" else "Guest")
	rpc_id(opponent.id, "player_found", session_id, candidate.player_name if candidate.player_name != "" else "Guest")
	
	server.add_session_button(session_id)
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
	
	if curr_session.prev_winner == null:
		var turn = randi()%2 == 1
		for player in curr_session.connected_players:
			rpc_id(player.id,"receive_game_begin", turn)
			if turn:
				curr_session.player_turn = player
			turn = !turn
	else:
		for player in curr_session.connected_players:
			var turn = player == curr_session.prev_winner
			rpc_id(player.id,"receive_game_begin", turn)
			if turn:
				curr_session.player_turn = player

#remote func set_ready(session_id):
#	var id = get_tree().get_rpc_sender_id()
#	var curr_session = session_dict[session_id]
#	if id != curr_session.player_turn.id:
#		print("invalid turn from player: "+ str(id))
#		return
#	var curr_player = curr_session.player_turn
#	var curr_enemy = curr_session.player_turn.connected_player
#	update_score(curr_player, curr_enemy, curr_session)

#func update_score(curr_player, curr_enemy, curr_session):
#	rpc_id(curr_player.id ,"receive_round_num", curr_session.round_num)
#	rpc_id(curr_enemy.id , "receive_round_num", curr_session.round_num)
#	rpc_id(curr_player.id, "receive_score", {"player":curr_player.score, "enemy":curr_enemy.score})
#	rpc_id(curr_enemy.id, "receive_score", {"player":curr_enemy.score, "enemy":curr_player.score})
#	rpc_id(curr_player.id ,"receive_round_score", curr_player.round_score)
#	rpc_id(curr_enemy.id , "receive_round_score", curr_enemy.round_score)

func reset():
	for session_id in session_dict.keys():
		reset_session(session_id)

func reset_session(session_id):
	var curr_session = session_dict[session_id]
	for player in curr_session.connected_players:
		player.score = 0
		player.all_scores = []
		player.round_score = 0 
		player.ready = false
		rpc_id(player.id,"receive_round_num", 1)
		rpc_id(player.id,"receive_round_score", 0)
		rpc_id(player.id,"reset_game")
		rpc_id(player.id,"clear_ships")
	
remote func concede(session_id):
	var id = get_tree().get_rpc_sender_id()
	print(str(id)+" conceded")
	var curr_session = session_dict[session_id]
	for player in curr_session.connected_players:
		if player.id == id:
			round_over(player.connected_player, player, curr_session)

remote func receive_target_position(session_id, pos):
	var id = get_tree().get_rpc_sender_id()
	var curr_session = session_dict[session_id]
	
	print(str(id)+" targeting " + str(pos))
	if id != curr_session.player_turn.id:
		print("invalid turn from player: "+ str(id))
		return
	
	var value = curr_session.player_turn.connected_player.ship_loc[pos["x"]][pos["y"]]
	var curr_player = curr_session.player_turn
	var curr_enemy = curr_session.player_turn.connected_player
	var all_destroyed = false

	if value != null:
		rpc_id(id, "receive_target_information", value)
		#check for round completion
		if value:
			curr_player.score += 1
			curr_enemy.set_damage(pos)
			all_destroyed = true
			ships_left =  4 #make it dynamic for different modes
			for ship in curr_enemy.ships:
				if ship["destroyed"] == true:
					ships_left = ships_left - 1
				if !ship["destroyed"]:
					all_destroyed = false
			print(ships_left)
			rpc_id(curr_player.id, "receive_ships_left", ships_left)  
		rpc_id(curr_enemy.id, "receive_hit", pos, value)
		if(all_destroyed):
			round_over(curr_player, curr_enemy, curr_session)
	rpc_id(id, "receive_score", {"player":curr_player.score, "enemy":curr_enemy.score})
	rpc_id(curr_enemy.id, "receive_score", {"player":curr_enemy.score, "enemy":curr_player.score})

func round_over(curr_player, curr_enemy, curr_session):
	curr_session.prev_winner = curr_player
	curr_session.round_num += 1
	curr_player.round_score += 1
	var game_over = curr_player.round_score >= 2 #make it a variable instead?
	
	for player in curr_session.connected_players:
		var enemy = player.connected_player
		
		player.ready = false
		player.all_scores.append(player.score)
		player.score = 0
		
		var round_info = {
		"round":curr_session.round_num,
		"round_score": player.round_score, 
		"enemy_round_score": enemy.round_score}
		
		var round_won = player == curr_player
		rpc_id(player.id, "receive_round_result", round_won, game_over, round_info)
	
#	if(curr_player.round_score >= 2):
#		rpc_id(curr_player.id, "set_winlost_text", "Win")
#		rpc_id(curr_enemy.id, "set_winlost_text", "Lose")
#		rpc_id(curr_player.id, "show_popup")
#		rpc_id(curr_enemy.id, "show_popup")
#		rpc_id(curr_player.id,"clear_ships")
#		rpc_id(curr_enemy.id,"clear_ships")
#		return
#	rpc_id(curr_player.id,"reset_game")
#	rpc_id(curr_enemy.id,"reset_game")
#	rpc_id(curr_player.id,"clear_ships")
#	rpc_id(curr_enemy.id,"clear_ships")

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
	
	