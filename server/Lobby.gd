extends Node

var server = null

var players = null
var in_game = null
var matching = null
var sessions = null
var session = preload("res://Session.tscn")
var player = preload("res://Player.tscn")

class GameMode:
	enum{
		BASIC,
		CLASSIC,
		STANDARD
	}
	
	const board_size = {
		BASIC: 8,
		CLASSIC: 10,
		STANDARD: 10
	}
var session_id = 0
var session_dict = {}
var player_dict = {}

const CONNECT_TYPE = {
	"LOGIN": "LOGIN",
	"REGISTER": "REGISTER",
	"GUEST": "GUEST",
}

func _ready():
	Firebase.Auth.connect("login_succeeded", self, "_on_FirebaseAuth_login_succeeded")
	Firebase.Auth.connect("login_failed", self, "_on_FirebaseAuth_login_failed")
	Firebase.Firestore.connect("request_succeeded", self, "_on_Firestore_request_succeeded")
	Firebase.Firestore.connect("request_failed", self, "_on_Firestore_request_failed")
	# Firebase.Auth.connect("userdata_updated", self, "_on_FirebaseAuth_userdata_updated")

remote func receive_login_data(type, email, pwd, username):
	print("receive login data")
	var id = get_tree().get_rpc_sender_id()
	var request_player = player_dict[id].get_node("AuthRequest")
	
	if (request_player): 
		match type:
			CONNECT_TYPE.GUEST:
				player_dict[id].player_name = "guest"+str(id)
				rpc_id(id, "login_succeeded", { "email": "", "displayname": "guest"+str(id) })
			CONNECT_TYPE.LOGIN:
				Firebase.Auth.login_with_email_and_password(request_player, email, pwd)
			CONNECT_TYPE.REGISTER:
				request_player.set_request_name(username)
				Firebase.Auth.signup_with_email_and_password(request_player, email, pwd)
			var unknown:
				print("UNKNOWN_TYPE: ", unknown)
	else:
		print("Player not found?")
		peer_disconnected(id)

func _on_FirebaseAuth_login_succeeded(nid, auth):
	print("LoginUser: ", auth.displayname)
	for player in players.get_children():
		if player.uid == auth.localid:
			_on_FirebaseAuth_login_failed(nid, 409, "This user already logged in.")
			return
	var player = player_dict[nid]
	player.set_profile(auth)
	rpc_id(nid, "login_succeeded", auth)

func _on_FirebaseAuth_login_failed(nid, error_code, error_msg):
	rpc_id(nid, "login_failed", error_code, error_msg)

# func _on_FirebaseAuth_userdata_updated(nid, auth):
# 	pass

func create_userdata(player, data):
	var request_player = player.get_node("FirestoreRequest")
	Firebase.Firestore.save_document(request_player, "users?documentId=%s" % player.uid, data)

func update_userdata(player, data):
	var request_player = player.get_node("FirestoreRequest")
	Firebase.Firestore.update_document(request_player, "users?documentId=%s" % player.uid, data)

remote func get_userdata():
	print("get userdata")
	var id = get_tree().get_rpc_sender_id()
	var player = player_dict[id]
	var request_player = player.get_node("FirestoreRequest")
	
	Firebase.Firestore.get_document(request_player, "users/%s" % player.uid)

func _on_Firestore_request_succeeded(nid, data):
	print("received userdata")
	var player = player_dict[nid]
	player.set_userdata(data)
	rpc_id(nid, "receive_userdata", player.userdata)

func _on_Firestore_request_failed(nid, error_code, error_msg):
	print(error_msg)

func peer_connected(id):
	var new_player = player.instance()
	new_player.set_id(id)
	player_dict[id] = new_player
	players.add_child(new_player)

func peer_disconnected(id):
	player_dict.erase(id)
	for player in players.get_children():
		if player.id == id:
			player.queue_free()
			return
	for player in matching.get_children():
		if player.id == id:
			player.queue_free()
			return
	for player in in_game.get_children():
		if player.id == id:
			var session_to_stop = player.session_id
			if session_to_stop != null:
				quit_session(session_to_stop)
			player.queue_free()
			return

remote func ready_to_match(info):
	var id = get_tree().get_rpc_sender_id()
	for player in players.get_children(): #make it O(1) with dictionary
		if player.id == id:
#			print("starting matching for " + str(id))
			player.matching_info = info
			call_deferred("move_to_matching", player)
			rpc_id(id, "start_matching")

# warning-ignore:unused_argument
remote func match_make():
	randomize()
	var id = get_tree().get_rpc_sender_id()
	print(str(id) + " is looking for match")
	var info = null
	var unfiltered_player = matching.get_children()
	
	for player in matching.get_children(): #make it O(1) with dictionary
		if player.id == id:
			info = player.matching_info
	
	if info == null:
		return
	

	var filtered_player = []
	for i in range(unfiltered_player.size()):
		if unfiltered_player[i].matching_info["mode"] == info["mode"]:
			filtered_player.append(unfiltered_player[i])

	if(filtered_player.size() == 0):
		return
	
	var candidate = filtered_player[randi()%filtered_player.size()]
	print("chosen candidate is: " + str(candidate.id))
	
	if candidate.id == id:
		return
	
	var new_session = create_session(info)
	
	var opponent = null
	for player in matching.get_children():
		if player.id == id || player.id == candidate.id:
			if player.id == id:
				player.connected_player = candidate
				opponent = player
			call_deferred("move_to_game", player)
			new_session.connected_players.append(player)
			player.session_id = session_id
	candidate.connected_player = opponent
	
	rpc_id(candidate.id, "player_found", session_id, opponent.player_name if opponent.player_name != "" else "Guest")
	rpc_id(opponent.id, "player_found", session_id, candidate.player_name if candidate.player_name != "" else "Guest")
	rpc_id(candidate.id,"receive_board_and_ship", new_session.board_size, new_session.max_ship)
	rpc_id(opponent.id,"receive_board_and_ship", new_session.board_size, new_session.max_ship)
	
	session_id += 1

func create_session(info):
	var mode = info["mode"]
	var new_session = session.instance()
	new_session.id = session_id
	new_session.board_size = GameMode.board_size[mode]
	new_session.max_ship = 4 if mode == GameMode.BASIC else 5
	sessions.add_child(new_session)
	new_session.button = server.add_session_button(session_id)
	session_dict[session_id] = new_session
	return new_session

func move_to_game(node):
	node.get_parent().remove_child(node)
	in_game.add_child(node)

func move_to_matching(node):
	node.get_parent().remove_child(node)
	matching.add_child(node)

func remove_from_game(node):
	node.get_parent().remove_child(node)
	players.add_child(node)

remote func create_set_ship(session_id):
	var id = get_tree().get_rpc_sender_id()
	var curr_session = session_dict[session_id]
	
remote func receive_ship_layout(session_id, layout):
	var id = get_tree().get_rpc_sender_id()
	var curr_session = session_dict[session_id]
	
#	print("received layout from: "+str(id)+"\n"+str(layout))
	
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

remote func rematch(session_id):
	var id = get_tree().get_rpc_sender_id()
	var curr_session = session_dict[session_id]
		
	for player in curr_session.connected_players:
		if player.id == id:
			player.ready = true

	var ready_to_start = true
	for player in curr_session.connected_players:
		if !player.ready:
			ready_to_start = false
		
	if(ready_to_start):
		reset_session(session_id)
		for player in curr_session.connected_players:
			player.ready = false

remote func cancel_rematch(session_id):
	var id = get_tree().get_rpc_sender_id()
	var curr_session = session_dict[session_id]
	for player in curr_session.connected_players:
		if player.id == id:
			player.ready = false

remote func quit_session(session_id):
	var id = get_tree().get_rpc_sender_id()
	if session_dict.has(session_id) :
		var curr_session = session_dict[session_id]
		
		for player in curr_session.connected_players:
			player.reset_session()
			if player.id != id:
				rpc_id(player.id, "end_session")
			remove_from_game(player)
		
		if server.selected_session == session_id:
			server.deselect()
		curr_session.reset()
		curr_session.button.queue_free()
		curr_session.queue_free()
		session_dict.erase(session_id)

func begin_game(session_id):
	var curr_session = session_dict[session_id]
	print("beginning game on: session "+str(session_id))
	
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
	curr_session.soft_reset()
	for player in curr_session.connected_players:
		player.soft_reset()
		rpc_id(player.id,"reset_game")
	
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
		curr_player.shot_fired += 1
		if value:
			curr_player.score += 1
			curr_enemy.set_damage(pos)
			all_destroyed = true
			var ships_left = curr_session.max_ship
			for ship in curr_enemy.ships:
				if ship["destroyed"] == true:
					ships_left = ships_left - 1
				if !ship["destroyed"]:
					all_destroyed = false
					
			var p_ships_left = curr_session.max_ship
			for ship in curr_player.ships:
				if ship["destroyed"] == true:
					p_ships_left = p_ships_left - 1
			rpc_id(curr_player.id, "receive_ships_left", p_ships_left,  ships_left)
			rpc_id(curr_enemy.id, "receive_ships_left", ships_left, p_ships_left)
		rpc_id(curr_enemy.id, "receive_hit", pos, value)
		if(all_destroyed):
			round_over(curr_player, curr_enemy, curr_session)
	rpc_id(id, "receive_score", {"player":curr_player.score, "enemy":curr_enemy.score})
	rpc_id(curr_enemy.id, "receive_score", {"player":curr_enemy.score, "enemy":curr_player.score})

func round_over(curr_player, curr_enemy, curr_session):
	curr_session.prev_winner = curr_player
	curr_session.round_num += 1
	curr_session.turn_num = 1
	curr_player.round_score += 1
#	print("round over")
	var game_over = curr_player.round_score >= 2 #make it a variable instead?
	
	for player in curr_session.connected_players:
		var enemy = player.connected_player
		
		player.ready = false
		player.all_scores.append(player.score)
		player.score = 0
		
		var round_info = {
			"round":curr_session.round_num,
			"round_score": player.round_score, 	
			"enemy_round_score": enemy.round_score
		}
		
		var round_won = player == curr_player

		if game_over:
			var is_first_time = player.is_first_time()
			var userdata = player.userdata
			var hit_value = userdata.hit
			for val in player.all_scores:
				hit_value += val
			var win_value = userdata.win + 1 if round_won else userdata.win
			var lose_value = userdata.lose + 1 if !round_won else userdata.lose
			var miss_value = userdata.miss + (player.shot_fired - hit_value)
			player.map_userdata(win_value, lose_value, hit_value, miss_value)

			var update_data = {
				"win": { "integerValue": userdata.win },
				"lose": { "integerValue": userdata.lose },
				"hit": { "integerValue": userdata.hit },
				"miss": { "integerValue": userdata.miss },
			}
			if is_first_time:
				create_userdata(player, update_data)
			else:
				pass	

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
remote func end_turn_ready(session_id):
	var id = get_tree().get_rpc_sender_id()
	var curr_session = session_dict[session_id]
	print(str(id) + " is ready") 
	
	for player in curr_session.connected_players:
		if player.id == id:
			player.ready = true

	var ready_to_end = true
	for player in curr_session.connected_players:
		if !player.ready:
			ready_to_end = false
	
	if(ready_to_end):
		for player in curr_session.connected_players:
			player.ready = false
		next_turn(session_id)

remote func timeout(session_id):
	var id = get_tree().get_rpc_sender_id()
	var curr_session = session_dict[session_id]
	
	if id != curr_session.player_turn.id:
		print("invalid turn from player: "+ str(id))
		return
	
	rpc_id(curr_session.player_turn.connected_player.id, "force_turn_end")

func next_turn(session_id):
	var curr_session = session_dict[session_id]
	curr_session.turn_num += 1
	curr_session.player_turn = curr_session.player_turn.connected_player
	for player in curr_session.connected_players:
		var turn = curr_session.player_turn == player
#		print("sent turn start")
		rpc_id(player.id, "receive_turn_start", turn, curr_session.turn_num)
