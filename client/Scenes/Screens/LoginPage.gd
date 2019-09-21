extends Node

onready var registerPopUpMenu = $MarginContainer2/RegisterPopUpMenu

onready var login_email := $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/UsernameTypeBox
onready var login_password := $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer3/PasswordTypeBox
onready var error_text := $MarginContainer2/RegisterPopUpMenu/MarginContainer/VBoxContainer/Error

onready var register_email := $MarginContainer2/RegisterPopUpMenu/MarginContainer/VBoxContainer/VBoxContainer/UsernameTypeBox
onready var register_password := $MarginContainer2/RegisterPopUpMenu/MarginContainer/VBoxContainer/VBoxContainer2/PasswordTypeBox

func _ready():
	Firebase.Auth.connect("login_succeeded", self, "_on_FirebaseAuth_login_succeeded")
	Firebase.Auth.connect("login_failed", self, "_on_login_failed")
#	registerPopUpMenu 

func _on_Sign_In_pressed():
	Firebase.Auth.login_with_email_and_password(login_email.text, login_password.text)

func _on_Register_pressed():
	Firebase.Auth.signup_with_email_and_password(register_email.text, register_password.text)

func _on_FirebaseAuth_login_succeeded(auth):
	print("login success: " + auth.email)
	get_tree().change_scene("res://Scenes/MainMenu.tscn")

func _on_login_failed(error_code, message):
	error_text.text = message
	print("error code: " + str(error_code))
	print("message: " + str(message))

func _on_Register_Popup_pressed():
	registerPopUpMenu.show()

func _on_CloseIcon_pressed():
	registerPopUpMenu.hide()
