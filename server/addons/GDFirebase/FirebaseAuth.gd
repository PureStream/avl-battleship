extends HTTPRequest

signal login_succeeded(nid, auth_result)
signal register_succeeded(nid, auth_result)
signal login_failed(nid, error_code, error_msg)
signal userdata_received(nid, userdata)
signal userdata_updated(nid, auth_result)

var config = {}

var register_request_url = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key="
var login_request_url = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key="
var login_guest_request_url = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key="
var userdata_request_url = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/getAccountInfo?key="
var update_profile_request_url ="https://identitytoolkit.googleapis.com/v1/accounts:update?key="
var refresh_request_url = "https://securetoken.googleapis.com/v1/token?key="

const RESPONSE_SIGNIN   = "identitytoolkit#VerifyPasswordResponse"
const RESPONSE_SIGNUP   = "identitytoolkit#SignupNewUserResponse"
const RESPONSE_USERDATA = "identitytoolkit#GetAccountInfoResponse"
const RESPONSE_UPDATE = "identitytoolkit#SetAccountInfoResponse"

# var needs_refresh = false
# var auth = null
# var userdata = null

var login_request_body = {
	"email":"",
	"password":"",
	"returnSecureToken": true
}

var update_profile_body = {
	"idToken":"",
	"displayName":"",
	"returnSecureToken":true,
}

func set_config(config_json):
	config = config_json
	register_request_url += config.apiKey
	login_request_url += config.apiKey
	login_guest_request_url += config.apiKey
	update_profile_request_url += config.apiKey
	refresh_request_url += config.apiKey
	userdata_request_url += config.apiKey

func _ready():
	connect("register_succeeded", self, "_on_registered_request_succeeded")

func login_with_email_and_password(player, email, password):
	login_request_body.email = email
	login_request_body.password = password
	player.request(login_request_url, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, JSON.print(login_request_body))

func signup_with_email_and_password(player, email, password):
	login_request_body.email = email
	login_request_body.password = password
	player.request(register_request_url, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, JSON.print(login_request_body))

func _on_registered_request_succeeded(player, auth):
	var username = player.get_request_name()
	player.request(update_profile_request_url, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, JSON.print({
		"idToken":auth.idtoken,
		"displayName":username,
		"returnSecureToken":true,
	}))
	yield(self, "userdata_updated")
	auth.displayname = username
	emit_signal("login_succeeded", player.get_id(), auth)

func login_as_guest():
	request(login_guest_request_url, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, JSON.print({"returnSecureToken": true}))

func _on_FirebaseAuth_request_completed(player, result, response_code, headers, body):
	var bod = body.get_string_from_utf8()
	var json_result = JSON.parse(bod)
	if json_result.error != OK:
		print_debug("Error while parsing body json")
		return
	
	var auth
	var res = json_result.result
	var nid = player.get_id()
	if response_code == HTTPClient.RESPONSE_OK:
		if not res.has("kind"):
			auth = get_clean_keys(res)
			begin_refresh_countdown(player, auth)
		else:
			match res.kind:
				RESPONSE_SIGNIN:
					auth = get_clean_keys(res)
					emit_signal("login_succeeded", nid, auth)
					begin_refresh_countdown(player, auth)
				RESPONSE_SIGNUP:
					auth = get_clean_keys(res)
					if (auth.has("email")):
						emit_signal("register_succeeded", player, auth)
					# Guest Login case
					else:
						emit_signal("login_succeeded", nid, auth)
				RESPONSE_USERDATA:
					var userdata = FirebaseUserData.new(res.users[0])
					emit_signal("userdata_received", nid, userdata)
				RESPONSE_UPDATE:
					auth = get_clean_keys(res)
					emit_signal("userdata_updated", nid, auth)
					begin_refresh_countdown(player, auth)
				var RESPONSE_KIND:
					print("RESPONSE_KIND: " + RESPONSE_KIND)
	else:
		# error message would be INVALID_EMAIL, EMAIL_NOT_FOUND, INVALID_PASSWORD, USER_DISABLED or WEAK_PASSWORD
		emit_signal("login_failed", nid, res.error.code, res.error.message)

func begin_refresh_countdown(player, auth):
	var refresh_token = null
	var expires_in = 1000
	auth = get_clean_keys(auth)
	if auth.has("refreshToken"):
		refresh_token = auth.refreshToken
		expires_in = auth.expiresIn
	elif auth.has("refresh_token"):
		refresh_token = auth.refresh_token
		expires_in = auth.expires_in
	# needs_refresh = true
	yield(get_tree().create_timer(float(expires_in)), "timeout")
	player.request(refresh_request_url, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, JSON.print({
		"grant_type": "refresh_token",
		"refresh_token": refresh_token
	}))

func get_clean_keys(auth_result):
	var cleaned = {}
	for key in auth_result.keys():
		cleaned[key.replace("_", "").to_lower()] = auth_result[key]
	return cleaned
	
func get_user_data(player, auth):
	if auth == null or auth.has("idtoken") == false:
		print_debug("Not logged in")
		return
	player.request(userdata_request_url, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, JSON.print({"idToken":auth.idtoken}))

func update_user_data(player, auth, data):
	player.request(update_profile_request_url, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, JSON.print(update_profile_body))
