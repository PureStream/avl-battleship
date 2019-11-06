extends Node

onready var register_popup_menu = $MarginContainer2/RegisterPopUpMenu
onready var error_popup_dialog = $MarginContainer3/ErrorPopUpDialog
onready var checkbox = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer4/RememberPassword

onready var login_email := $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/UsernameTypeBox
onready var login_password := $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer3/PasswordTypeBox
onready var error_text := $MarginContainer3/ErrorPopUpDialog/MarginContainer/Error

onready var register_email := $MarginContainer2/RegisterPopUpMenu/MarginContainer/VBoxContainer/VBoxContainer/EmailTypeBox
onready var register_username := $MarginContainer2/RegisterPopUpMenu/MarginContainer/VBoxContainer/VBoxContainer2/UsernameTypeBox
onready var register_password := $MarginContainer2/RegisterPopUpMenu/MarginContainer/VBoxContainer/VBoxContainer3/PasswordTypeBox
onready var blank := $Blank

onready var ip_input := $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer6/IPTypeBox

var curr_scene = self.name
var music_value = 0

func _ready():
	Settings.play_bgm("BGM1")
	Lobby.connect("login_succeeded", self, "_on_login_succeeded")
	Lobby.connect("login_failed", self, "_on_login_failed")
	ip_input.text = Global.IP_ADDRESS
#	Settings.load_profile()
	var db = 2*log(Settings.music_value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
	blank.hide()
	if Settings.login_email != "":
		login_email.text = Settings.login_email
		login_password.text = Settings.login_password
		checkbox.pressed = Settings.is_remember_password

func _on_Guest_Login_pressed():
	blank.show()
	Lobby.guest_login()

func _on_Sign_In_pressed():
	blank.show()
	if (ip_input.text && !ip_input.text.is_valid_ip_address()):
		_on_login_failed('069', 'Invalid IP address')
	Lobby.ip_address = ip_input.text
	Lobby.email_pwd_login(login_email.text, login_password.text.md5_text())

func _on_Register_pressed():
	blank.show()
	if (ip_input.text && !ip_input.text.is_valid_ip_address()):
		_on_login_failed('069', 'Invalid IP address')
	Lobby.ip_address = ip_input.text
	var error_string = get_error_string(register_username.text, register_password.text)
	if (error_string):
		error_text.text = error_string
		error_popup_dialog.show()
		blank.hide()
		return
	Lobby.email_pwd_register(register_email.text, register_password.text.md5_text(), register_username.text)
	
func _on_login_succeeded(auth):
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
	Settings.login_email = auth.email
	if (checkbox.pressed):
		Settings.login_password = login_password.text
	else:
		Settings.login_password = ""
	Settings.is_remember_password = checkbox.pressed
	Settings.save_profile()

func _on_login_failed(error_code, message):	
	blank.hide()
	error_popup_dialog.show()
	error_text.text = message
	Lobby.disconnect_from_server()
	
func _on_Register_Popup_pressed():
	register_popup_menu.show()

func _on_CloseIcon_pressed():
	register_popup_menu.hide()

func _on_CloseIcon2_pressed():
	error_popup_dialog.hide()

func get_error_string(username, password):
	if (username.length() < 4):
		return "Username must be longer than 3 characters"
	if (password.length() < 6):
		return "Password must be longer than 5 characters"
	return null