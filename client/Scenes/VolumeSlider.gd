extends HBoxContainer

signal update_value

onready var label = $Value
onready var slider = $HSlider

func _ready():
	on_load()
	pass # Replace with function body.

func on_load():
	label.text = str(Settings.sound_value)
	slider.value = Settings.sound_value

func _on_HSlider_value_changed(value):
	label.text = str(int(value))
	emit_signal("update_value", int(value))
