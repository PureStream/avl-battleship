extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text
const play = preload("res://Scenes/Screens/Play.tscn")
onready var quit := $Quit
onready var rematch := $Rematch
onready var popup := $Popup
onready var player_hit_score := $Player_Hit_score
onready var enemy_hit_score := $Enemy_Hit_score

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.viewing_result = true
	Lobby.result = self
	player_hit_score.text = ": " + str(Lobby.player_score)
	enemy_hit_score.text = ": " + str(Lobby.enemy_score)

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