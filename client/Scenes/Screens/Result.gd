extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text
const play = preload("res://Scenes/Screens/Play.tscn")
onready var quit := $Quit
onready var rematch := $Rematch
onready var popup := $Popup
onready var player_hit_score := $Hitbar/PlayerHit/Player_Hit_score
onready var enemy_hit_score := $Hitbar/EnemyHit/Enemy_Hit_score
onready var player_round_score := $Roundbar/PlayerScore/Player_Round_score
onready var enemy_round_score := $Roundbar/EnemyScore/Enemy_Round_score
onready var hit_bar := $Hitbar
onready var round_bar := $Roundbar
onready var time_bar := $Timebar
onready var player_name := $PlayerName
onready var enemy_name := $EnemyName

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.viewing_result = true
	Lobby.result = self
	player_hit_score.text = str(Lobby.player_score)
	enemy_hit_score.text = str(Lobby.enemy_score)
	player_round_score.text = str(Lobby.round_score)
	enemy_round_score.text = str(Lobby.enemy_round_score)
	hit_bar.max_value = Lobby.player_score + Lobby.enemy_score
	hit_bar.value = Lobby.player_score
	round_bar.max_value = Lobby.round_score + Lobby.enemy_round_score
	round_bar.value = Lobby.round_score
	player_name.text = Global.username
	enemy_name.text = Lobby.enemy_name
	

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