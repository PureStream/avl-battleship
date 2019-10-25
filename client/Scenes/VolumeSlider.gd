extends HBoxContainer

signal update_value

onready var label = $Value
onready var slider = $HSlider

func _ready():
	on_load()

func on_load():
	label.text = str(Settings.sound_value)
	slider.value = Settings.sound_value
	print("sound value: ", slider.value)

func _on_HSlider_value_changed(value):
	label.text = str(int(value))
	emit_signal("update_value", int(value))
