extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text
const play = preload("res://Scenes/Screens/Play.tscn")
onready var quit := $MarginContainer/VBoxContainer/Buttons/Quit/Quit
onready var rematch := $MarginContainer/VBoxContainer/Buttons/Rematch
onready var popup := $MarginContainer2/Popup
onready var player_name := $MarginContainer/VBoxContainer/NameContainer/PlayerName
onready var enemy_name := $MarginContainer/VBoxContainer/NameContainer/EnemyName

onready var bar_container = $MarginContainer/VBoxContainer/BarMargin/BarContainer
onready var score_bar = bar_container.get_node("ScoreBar")
onready var round_bar = bar_container.get_node("RoundBar")
onready var time_bar = bar_container.get_node("TimeBar")

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.viewing_result = true
	Lobby.result = self
	for bar in bar_container.get_children():
		bar.set_colors(Color("#2ee2ff"), Color("#ff5e39"))
	score_bar.set_label("Shots hit")
	score_bar.set_values(Lobby.player_score, Lobby.enemy_score)
	round_bar.set_label("Rounds won")
	round_bar.set_values(Lobby.round_score, Lobby.enemy_round_score)
	time_bar.set_label("Time taken")
	time_bar.set_values(Lobby.time_used, Lobby.enemy_time_used)
	player_name.text = Global.username
	enemy_name.text = Lobby.enemy_name
	
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