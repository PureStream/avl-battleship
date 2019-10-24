extends "res://Scenes/VolumeSlider.gd"

func on_load():
	Settings.load_profile()
	label.text = str(Settings.music_value)
	slider.value = Settings.music_value