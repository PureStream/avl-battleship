extends Node

signal listed_documents(documents)
signal request_succeeded(nid, data)
signal request_failed(nid, error_code, error_msg)

var v1_request_url := "https://firestore.googleapis.com/v1/projects/[PROJECT_ID]/databases/(default)/documents/"

var config = {}

var collections = {}

func set_config(config_json):
	config = config_json
	# extended_url = extended_url.replace("[PROJECT_ID]", config.projectId)
	v1_request_url = v1_request_url.replace("[PROJECT_ID]", config.projectId)

func _on_FirebaseAuth_request_completed(player, result, response_code, headers, body):
	var res := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	
	if player:
		var nid = player.get_id()
		if response_code == HTTPClient.RESPONSE_OK:
			emit_signal("request_succeeded", nid, res.fields)
		else:
			emit_signal("request_failed", nid, res.error.code, res.error.message)
	
func save_document(player: HTTPRequest, path: String, fields: Dictionary) -> void:
	var document := { "fields": fields }
	var body := to_json(document)
	var url := v1_request_url + path
	player.request(url, _get_request_headers(player.auth), true, HTTPClient.METHOD_POST, body)

func get_document(player: HTTPRequest, path: String) -> void:
	var url := v1_request_url + path
	if (player):
		player.request(url, _get_request_headers(player.auth), true, HTTPClient.METHOD_GET)

func update_document(player: HTTPRequest, path: String, fields: Dictionary) -> void:
	var document := { "fields": fields }
	var body := to_json(document)
	var url := v1_request_url + path
	player.request(url, _get_request_headers(player.auth), true, HTTPClient.METHOD_PATCH, body)

func delete_document(player: HTTPRequest, path: String) -> void:
	var url := v1_request_url + path
	player.request(url, _get_request_headers(player.auth), true, HTTPClient.METHOD_DELETE)

func _get_request_headers(auth) -> PoolStringArray:
	return PoolStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer %s" % auth.idtoken
	])

# func collection(path):
#     if !collections.has(path):
#         var coll = preload("res://addons/GDFirebase/FirebaseFirestoreCollection.gd")
#         var node = Node.new()
#         node.set_script(coll)
#         node.extended_url = extended_url
#         node.base_url = base_url
#         node.config = config
#         node.auth = auth
#         node.collection_name = path
#         collections[path] = node
#         add_child(node)
#         return node
#     else:
#         return collections[path]

# func list(path):
#     if path:
#         var url = base_url + extended_url + path + "?auth=" + auth.idtoken
#         request_list_node.request(url, PoolStringArray(), true, HTTPClient.METHOD_GET)

# func on_list_request_completed(result, response_code, headers, body):
#     pass

# func _on_FirebaseAuth_login_succeeded(auth_result):
#     auth = auth_result
#     for collection_key in collections.keys():
#         collections[collection_key].auth = auth
#     pass