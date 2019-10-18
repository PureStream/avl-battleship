extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CheckButton_toggled(button_pressed):
	pass # Replace with function body.


func _on_SoundContainer_update_value(value):
	Global.sound_value = value


func _on_MusicContainer_update_value(value):
	Global.music_value = value
