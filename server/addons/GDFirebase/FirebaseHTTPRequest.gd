extends HTTPRequest

signal firebase_request_completed(network_id, result, response_code, headers, body)

class_name FirebaseHTTPRequest

var network_id = ""

func _init(id):
    network_id = id
    connect("request_completed", self, "_on_request_completed")

func _on_request_completed(result, response_code, headers, body):
    emit_signal("firebase_request_completed", network_id, result, response_code, headers, body)