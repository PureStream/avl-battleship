extends Node

func _ready():
	pass # Replace with function body.

var lobby = null
var set_ship = null
var play = null
var session_id = -1
var enemy_name = ""

var round_num = 1
var round_score = 0
var enemy_round_score = 0

remote func receive_username(username):
	print(username)
	Global.username = username

func look_for_player(info):
	rpc_id(1,"match_make", info)
	
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

var your_turn = false
signal target_info_received

remote func receive_game_begin(player_turn:bool):
	set_ship.next()
	your_turn = player_turn

remote func reset_game():
	#reset everything
	play.previous() #make compatible with resetting from ship layout screen

func send_target_position(pos):
	if session_id > -1:
		rpc_id(1, "receive_target_position", session_id, pos)
	else:
		print("session error")

func concede():
	if session_id >-1:
		rpc_id(1, "concede", session_id)
	else:
		print("session error")

remote func receive_target_information(value):
	emit_signal("target_info_received", value)

remote func receive_turn_start():
	your_turn = true
	play.new_turn()
	
remote func receive_ships_left(ship_left):
	play.receive_ships_left(ship_left)

func receive_round_num(round_number):
	play.set_round_num(round_number)
	
remote func receive_hit(pos, value):
	play.receive_hit(pos, value)

remote func receive_score(score):
	play.set_score(score)

remote func receive_round_result(result:bool, game_over:bool, round_info):
	round_num = round_info["round"]
	round_score = round_info["round_score"]
	enemy_round_score = round_info["enemy_round_score"]
	if game_over:
		if result:
			play.set_winlose_text("Win")
		else:
			play.set_winlose_text("Lose")
		play.clear()
		play.show_popup()
		return
		#move to result screen
	#show round result
	play.clear()
	play.previous()

func end_turn():
	your_turn = false
	rpc_id(1,"next_turn", session_id)