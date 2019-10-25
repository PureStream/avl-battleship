extends Node

signal login_succeeded(auth)
signal login_failed(error_code, error_msg)

func _ready():
	pass # Replace with function body.

var lobby = null
var set_ship = null
var play = null
var result = null
var session_id = -1
var enemy_name = ""
var boardsize = -1
var game_mode = -1
var max_ship = -1

var turn_num = 1
var round_num = 1
var round_score = 0
var enemy_round_score = 0
var player_score = 0
var enemy_score = 0
var time_used = 0
var enemy_time_used = 0

var connect_type
var connect_email
var connect_username
var connect_pwd

const CONNECT_TYPE = {
	"LOGIN": "LOGIN",
	"REGISTER": "REGISTER",
	"GUEST": "GUEST",
}

func guest_login():
	connect_to_server(CONNECT_TYPE.GUEST, '', '', '')

func email_pwd_login(email, pwd):
	connect_to_server(CONNECT_TYPE.LOGIN, email, pwd, '')

func email_pwd_register(email, pwd, username):
	connect_to_server(CONNECT_TYPE.REGISTER, email, pwd, username)

func connect_to_server(type, email, pwd, username):
	connect_type = type
	connect_email = email
	connect_pwd = pwd
	connect_username = username

	var network = NetworkedMultiplayerENet.new()
	network.create_client(Global.IP_ADDRESS, Global.PORT)
	get_tree().set_network_peer(network)
	print("connecting to server")
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_success")

func disconnect_from_server():
	get_tree().set_network_peer(null)

func _on_connection_failed():
	print("Error connecting to server")
	disconnect_from_server()

func _on_connection_success():
	print("connect success!")
	rpc_id(1, "receive_login_data", connect_type, connect_email, connect_pwd, connect_username)

remote func login_succeeded(auth):
	print("login success: " + auth.displayname)
	set_username(auth.displayname)
	emit_signal("login_succeeded", auth)

remote func login_failed(error_code, message):
	print("error code: " + str(error_code))
	print("message: " + message)
	emit_signal("login_failed", str(error_code), message)

func set_username(name):
	Global.username = name

var your_turn = false
signal target_info_received

remote func receive_username(username):
	set_username(username)

func ready_to_match(info):
	rpc_id(1,"ready_to_match", info)

remote func start_matching():
	lobby.start_matching()

func look_for_player():
	rpc_id(1,"match_make")
	
remote func player_found(session_id, enemy_name):
	print("found player: " + enemy_name)
	self.enemy_name = enemy_name
	self.session_id = session_id
	if lobby != null:
		lobby.stop_looking()

func send_ship_layout(layout):
	if session_id > -1:
		rpc_id(1, "receive_ship_layout", session_id, layout)
	else:
		print("session error")

remote func receive_game_begin(player_turn:bool):
	turn_num = 1
	set_ship.next()
	your_turn = player_turn

remote func reset_game():
	round_num = 1
	round_score = 0
	enemy_round_score = 0
#	if play != null:
#		receive_score({"player":0,"enemy":0})
	ShipLayout.clear_ship()
	get_tree().change_scene("res://Scenes/SetShip.tscn") #make compatible with resetting from ship layout screen

func clear_variables():
	session_id = -1
	enemy_name = ""
	round_num = 1
	round_score = 0
	enemy_round_score = 0
	boardsize = -1
	max_ship = -1

func send_target_position(pos, time):
	if session_id > -1:
		rpc_id(1, "receive_target_position", session_id, pos, time)
	else:
		print("session error")

func concede(time_used):
	if session_id >-1:
		rpc_id(1, "concede", session_id, time_used)
	else:
		print("session error")

remote func receive_target_information(value):
	emit_signal("target_info_received", value)

remote func receive_turn_start(turn, turn_num):
	print("turn start")
	your_turn = turn
	self.turn_num = turn_num
	play.new_turn()

func end_turn_ready():
	rpc_id(1, "end_turn_ready", session_id)

#remote func receive_turn_end():
#	play.end_turn()

remote func receive_ships_left(p_ship, e_ship):
	play.receive_ships_left(p_ship, e_ship)
	
remote func receive_hit(pos, value):
	play.receive_hit(pos, value)

remote func receive_score(score):
	play.set_score(score)

remote func receive_round_result(result:bool, game_over:bool, round_info):
	round_num = round_info["round"]
	round_score = round_info["round_score"]
	enemy_round_score = round_info["enemy_round_score"]
	enemy_time_used = round_info["enemy_time_used"]
	play.set_round_score(round_score, enemy_round_score)
	if game_over:
		play.end_game(result)
		return
	play.end_round(result)

remote func receive_board_and_ship(board_size, max_ship):
	self.boardsize = board_size
	self.max_ship = max_ship

func rematch():
	if session_id >-1:
		rpc_id(1, "rematch", session_id)
	else:
		print("session error")

remote func send_time_used():
	if session_id >-1:
		print("time used sent:" + str(time_used))
		rpc_id(1, "receive_time_used", session_id, Lobby.time_used)
	else:
		print("session error")
		
func cancel_rematch():
	if session_id >-1:
		rpc_id(1, "cancel_rematch", session_id)
	else:
		print("session error")

func quit():
	if session_id >-1:
		rpc_id(1, "quit_session", session_id)
		clear_variables()
	else:
		print("session error")

func timeout():
	rpc_id(1, "timeout", session_id)

remote func force_turn_end():
	print("force turn end")
	play.end_turn()

#func end_turn():
#	your_turn = false
#	rpc_id(1,"next_turn", session_id)

remote func end_session():
	var curr_scene = get_tree().root
	clear_variables()
	if Global.viewing_result:
		result.disable_rematch()
	else:
		get_tree().change_scene("res://Scenes/Screens/Lobby.tscn")
		#notify session having ended unexpectedly