extends Node

onready var register_popup_menu = $MarginContainer2/RegisterPopUpMenu
onready var error_popup_dialog = $MarginContainer3/ErrorPopUpDialog

onready var login_email := $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/UsernameTypeBox
onready var login_password := $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer3/PasswordTypeBox
onready var error_text := $MarginContainer3/ErrorPopUpDialog/MarginContainer/Error

onready var register_email := $MarginContainer2/RegisterPopUpMenu/MarginContainer/VBoxContainer/VBoxContainer/EmailTypeBox
onready var register_username := $MarginContainer2/RegisterPopUpMenu/MarginContainer/VBoxContainer/VBoxContainer2/UsernameTypeBox
onready var register_password := $MarginContainer2/RegisterPopUpMenu/MarginContainer/VBoxContainer/VBoxContainer3/PasswordTypeBox

func _ready():
	Lobby.connect("login_succeeded", self, "_on_login_succeeded")
	Lobby.connect("login_failed", self, "_on_login_failed")
	Settings.load_email()
	if Settings.login_email != "":
		login_email.text = Settings.login_email

func _on_Guest_Login_pressed():
	Lobby.guest_login()

func _on_Sign_In_pressed():
	Lobby.email_pwd_login(login_email.text, login_password.text)

func _on_Register_pressed():
	Lobby.email_pwd_register(register_email.text, register_password.text, register_username.text)

func _on_login_succeeded():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
	Settings.login_email = auth.email
	Settings.save_email()

func _on_login_failed(error_code, message):		
	error_popup_dialog.show()
	error_text.text = message
	Lobby.disconnect_from_server()
	
func _on_Register_Popup_pressed():
	register_popup_menu.show()

func _on_CloseIcon_pressed():
	register_popup_menu.hide()

func _on_CloseIcon2_pressed():
	error_popup_dialog.hide()
