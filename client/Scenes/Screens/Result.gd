extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text
onready var quit := $Quit
onready var rematch := $Rematch
onready var popup := $Popup

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.viewing_result = true
	Lobby.result = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func disable_rematch():
	if popup.visible:
		popup.cancel_rematch()
	rematch.disabled = true

func _on_Rematch_pressed():
	Lobby.rematch() 
	rematch.disabled = true
	popup.show() 

func _on_Quit_pressed():
	get_tree().change_scene("res://Scenes/Screens/Lobby.tscn")# Replace with function body.
	Lobby.quit()

func _on_Cancel_pressed():
	if popup.cancel_enabled:
		rematch.disabled = false
		Lobby.cancel_rematch()
	popup.hide()