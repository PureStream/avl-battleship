extends Node

onready var email : LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/UsernameTypeBox
onready var password : LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer2/PasswordTypeBox

func _ready():
	Firebase.Auth.connect("login_succeeded", self, "_on_FirebaseAuth_login_succeeded")
	Firebase.Auth.connect("login_failed", self, "_on_login_failed")

func _on_Sign_In_pressed():
	Firebase.Auth.login_with_email_and_password(email.text, password.text)

func _on_Sign_Up_pressed():
	Firebase.Auth.signup_with_email_and_password(email.text, password.text)

func _on_FirebaseAuth_login_succeeded(auth):
	print("login success: " + auth.email)
	get_tree().change_scene("res://Scenes/MainMenu.tscn")

func _on_login_failed(error_code, message):
	print("error code: " + str(error_code))
	print("message: " + str(message))
