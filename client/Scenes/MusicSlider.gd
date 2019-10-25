extends "res://Scenes/VolumeSlider.gd"

func on_load():
	label.text = str(Settings.music_value)
	slider.value = Settings.music_value
	print("music value: ", slider.value)