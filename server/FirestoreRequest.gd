extends HTTPRequest

signal firebase_request_completed(request, result, response_code, headers, body)

var auth = null
var nid = -1

func _ready():
	connect("request_completed", self, "_on_request_completed")
	connect("firebase_request_completed", Firebase.Firestore, "_on_FirebaseAuth_request_completed")

func _on_request_completed(result, response_code, headers, body):
	emit_signal("firebase_request_completed", self, result, response_code, headers, body)
	
func get_auth():
	return auth
	
func set_auth(auth):
	self.auth = auth
	
func get_id():
	return nid
	
func set_id(id):
	nid = id