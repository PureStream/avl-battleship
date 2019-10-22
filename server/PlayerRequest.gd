extends HTTPRequest

signal firebase_request_completed(network_id, result, response_code, headers, body)

var player_name = ""
var nid = -1

func _ready():
	connect("request_completed", self, "_on_request_completed")
	connect("firebase_request_completed", Firebase.Auth, "_on_FirebaseAuth_request_completed")

func _on_request_completed(result, response_code, headers, body):
	emit_signal("firebase_request_completed", self, result, response_code, headers, body)
	
func get_request_name():
	return player_name
	
func set_request_name(name):
	player_name = name
	
func get_id():
	return nid
	
func set_id(id):
	nid = id