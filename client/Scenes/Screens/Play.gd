extends Control

var DisplayValue = 10
const ship_base = preload("res://Scenes/ShipBase.tscn")
var count = 0

onready var timer = get_node("Timer")
onready var player_grid = $PlayerGrid
onready var enemy_grid = $EnemyGrid
onready var confirm = $Confirm
onready var time = $Time
onready var your_score := $ScorePanel/VBoxContainer/YourScore
onready var enemy_score := $ScorePanel/VBoxContainer/EnemyScore
onready var ship_status := $ScorePanel/VBoxContainer/ShipStatus
onready var round_num := $RoundNum
onready var round_score := $ScorePanel/VBoxContainer/RoundScore
onready var win_lose := $MarginContainer/WinLose
onready var win_lose_text := $MarginContainer/WinLose/VBoxContainer/WinLoseText
# Called when the node enters the scene tree for the first time.
func _ready():
	Lobby.connect("target_info_received", self, "render_hit")
	confirm.disabled = true
	Lobby.play = self
	timer.set_wait_time(1)
	var ships = ShipLayout.ships_list
	for ship in ships:
		player_grid.insert_item(ship)
	if Lobby.your_turn:
		new_turn()
	Lobby.send_on_set()	

func _on_Timer_timeout():
	if DisplayValue > 0:
		DisplayValue -= 1
		time.text = str(DisplayValue)
	else:
		Lobby.end_turn()

func _on_Confirm_pressed():
	var x = enemy_grid.reticle_pos.x 
	var y = enemy_grid.reticle_pos.y 
	confirm.disabled = true
	timer.stop()
	Lobby.send_target_position({"x":x,"y":y})
	Lobby.end_turn()
	
func render_hit(hit):
	var x = enemy_grid.reticle_pos.x 
	var y = enemy_grid.reticle_pos.y 
	if hit:
		enemy_grid.insert_mark({"id":"Hit","g_pos":{"x":x,"y":y}})
	else:
		enemy_grid.insert_mark({"id":"Miss","g_pos":{"x":x,"y":y}})
	enemy_grid.reticle.visible = false
	enemy_grid.hit_map[x][y] = false

func receive_hit(pos, value):
	var x = pos["x"] 
	var y = pos["y"] 
	if value:
		player_grid.insert_mark({"id":"Hit","g_pos":{"x":x,"y":y}})
	else:
		player_grid.insert_mark({"id":"Miss","g_pos":{"x":x,"y":y}})

func new_turn():
	DisplayValue = 10
	time.text = str(DisplayValue)
	timer.start()
	
func set_score(score):
	var p_score = score["player"]
	var e_score = score["enemy"]
	enemy_score.text = "Enemy: " + str(e_score)
	your_score.text = "You: " + str(p_score)

func receive_ships_left(ship_left):
	ship_status.text = "Ship left: " + str(ship_left)

func receive_round_num(round_number):
	round_num.text = "Round "+ str(round_number) 
	
func previous():
	get_tree().change_scene("res://Scenes/SetShip.tscn")

func to_lobby():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")

func set_round_score(round_sc):
	round_score.text = "Round Score: " + str(round_sc)

func set_winlose_text(winlost_text:String):
	win_lose_text.text = "You " + winlost_text + "!"

func show_popup():
	win_lose.show()

func clear():
	ShipLayout.clear_ship()

func _on_Button_pressed():
	to_lobby()


func _on_Skip_pressed():
	Lobby.send_on_skip()
