extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text
onready var quit := $Quit
onready var rematch := $Rematch
onready var popup := $Popup

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Rematch_pressed():
	Lobby.rematch() 
	rematch.disabled = true
	popup.show() 


func _on_Quit_pressed():
	get_tree().change_scene("res://Scenes/Screens/Lobby.tscn")# Replace with function body.


func _on_Cancel_pressed():
	rematch.disabled = false
	popup.hide()	