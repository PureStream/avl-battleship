extends Node

func _ready():
	Settings.load_profile()


func _on_CheckButton_toggled(button_pressed):
	pass # Replace with function body.


func _on_SoundContainer_update_value(value):
	Settings.sound_value = value
	#AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), value-45)
	Settings.save_profile()


func _on_MusicContainer_update_value(value):
	Settings.music_value = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value-45)
	Settings.save_profile()

func _on_LogOutButton_pressed():
	Lobby.disconnect_from_server()
	get_tree().change_scene("res://Scenes/Screens/LoginPage.tscn")
