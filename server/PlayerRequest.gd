extends HTTPRequest

signal firebase_request_completed(network_id, result, response_code, headers, body)

onready var refresh_timer := $RefreshTimer

var player_name = ""
var nid = -1

func _ready():
	connect("request_completed", self, "_on_request_completed")
	connect("firebase_request_completed", Firebase.Auth, "_on_FirebaseAuth_request_completed")
	refresh_timer.connect("timeout", self, "_on_refresh_timeout")

func _on_request_completed(result, response_code, headers, body):
	emit_signal("firebase_request_completed", self, result, response_code, headers, body)

func begin_refresh_countdown():
	var expires_in = 5
	var auth = get_owner().auth
	if auth:
		if auth.has("refreshToken"):
			expires_in = auth.expiresIn
		elif auth.has("refresh_token"):
			expires_in = auth.expires_in
	refresh_timer.set_wait_time(expires_in)

func _on_refresh_timeout():
	var auth = get_owner().auth
	Firebase.auth.refresh_token(self, auth)
	
func get_request_name():
	return player_name
	
func set_request_name(name):
	player_name = name
	
func get_id():
	return nid
	
func set_id(id):
	nid = id