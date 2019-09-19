extends HTTPRequest

signal login_succeeded(auth_result)
signal login_failed
signal userdata_received(userdata)

var config = {}

var register_request_url = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key="
var login_request_url = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key="
var userdata_request_url = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/getAccountInfo?key="
var refresh_request_url = "https://securetoken.googleapis.com/v1/token?key="

const RESPONSE_SIGNIN   = "identitytoolkit#VerifyPasswordResponse"
const RESPONSE_SIGNUP   = "identitytoolkit#SignupNewUserResponse"
const RESPONSE_USERDATA = "identitytoolkit#GetAccountInfoResponse"

var needs_refresh = false
var auth = null

var login_request_body = {
    "email":"",
    "password":"",
    "returnSecureToken": true
}

var refresh_request_body = {
    "grant_type":"refresh_token",
    "refresh_token":""
}

func set_config(config_json):
    config = config_json
    register_request_url += config.apiKey
    login_request_url += config.apiKey
    refresh_request_url += config.apiKey
    userdata_request_url += config.apiKey
    connect("request_completed", self, "_on_FirebaseAuth_request_completed")

func login_with_email_and_password(email, password):
    login_request_body.email = email
    login_request_body.password = password
    request(login_request_url, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, JSON.print(login_request_body))

func signup_with_email_and_password(email, password):
    login_request_body.email = email
    login_request_body.password = password
    request(register_request_url, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, JSON.print(login_request_body))

func _on_FirebaseAuth_request_completed(result, response_code, headers, body):
    var bod = body.get_string_from_utf8()
    var json_result = JSON.parse(bod)
    if json_result.error != OK:
        print_debug("Error while parsing body json")
        return
    
    var res = json_result.result
    if response_code == HTTPClient.RESPONSE_OK:
        if not res.has("kind"):
            auth = get_clean_keys(res)
            begin_refresh_countdown()
        else:
            match res.kind:
                RESPONSE_SIGNIN, RESPONSE_SIGNUP:
                    auth = get_clean_keys(res)
                    emit_signal("login_succeeded", auth)
                    begin_refresh_countdown()
                RESPONSE_USERDATA:
                    var userdata = FirebaseUserData.new(res.users[0])
                    emit_signal("userdata_received", userdata)
    else:
        # error message would be INVALID_EMAIL, EMAIL_NOT_FOUND, INVALID_PASSWORD, USER_DISABLED or WEAK_PASSWORD
        emit_signal("login_failed", res.error.code, res.error.message)

func begin_refresh_countdown():
    var refresh_token = null
    var expires_in = 1000
    auth = get_clean_keys(auth)
    if auth.has("refreshToken"):
        refresh_token = auth.refreshToken
        expires_in = auth.expiresIn
    elif auth.has("refresh_token"):
        refresh_token = auth.refresh_token
        expires_in = auth.expires_in
    needs_refresh = true
    yield(get_tree().create_timer(float(expires_in)), "timeout")
    refresh_request_body.refresh_token = refresh_token
    request(refresh_request_url, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, JSON.print(refresh_request_body))

func get_clean_keys(auth_result):
    var cleaned = {}
    for key in auth_result.keys():
        cleaned[key.replace("_", "").to_lower()] = auth_result[key]
    return cleaned
    
func get_user_data():
    if auth == null or auth.has("idtoken") == false:
        print_debug("Not logged in")
        return
    request(userdata_request_url, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, JSON.print({"idToken":auth.idtoken}))
