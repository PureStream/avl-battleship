extends Node

func _ready():
	pass # Replace with function body.

var lobby = null
var set_ship = null
var play = null
var session_id = -1

func look_for_player(info):
	rpc_id(1,"match_make", info)
	
remote func player_found(session_id):
	print("found player")
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

func send_target_position(pos):
	if session_id > -1:
		rpc_id(1, "receive_target_position", session_id, pos)
	else:
		print("session error")

remote func receive_target_information(value):
	emit_signal("target_info_received", value)

remote func receive_turn_start():
	your_turn = true
	play.new_turn()
	
remote func receive_hit(pos, value):
	play.receive_hit(pos, value)
	
func end_turn():
	your_turn = false
	rpc_id(1,"next_turn", session_id)