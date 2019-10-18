extends "res://Scenes/VolumeSlider.gd"

func on_load():
	label.text = str(Global.music_value)
	slider.value = Global.music_value
