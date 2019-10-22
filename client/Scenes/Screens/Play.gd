extends Control

var DisplayValue = 10
const ship_base = preload("res://Scenes/ShipBase.tscn")
var count = 0

onready var timer = get_node("Timer")
onready var player_grid = $PlayerGrid
onready var enemy_grid = $EnemyGrid
onready var confirm = $Confirm
onready var time = $MainMarginContainer/ScorePanel/HBoxContainer/VBoxContainer/Time
onready var your_score := $MainMarginContainer/ScorePanel/HBoxContainer/VBoxContainer2/HBoxContainer/YourScore
onready var enemy_score := $MainMarginContainer/ScorePanel/HBoxContainer/VBoxContainer2/HBoxContainer2/EnemyScore
onready var ship_status := $MainMarginContainer/ScorePanel/HBoxContainer/VBoxContainer2/ShipStatus
onready var round_num := $MainMarginContainer/ScorePanel/HBoxContainer/VBoxContainer/RoundNum
onready var round_score := $MainMarginContainer/ScorePanel/HBoxContainer/VBoxContainer2/RoundScore
onready var win_lose := $MarginContainer/WinLose
onready var win_lose_text := $MarginContainer/WinLose/VBoxContainer/WinLoseText
onready var player_name := $MainMarginContainer/ScorePanel/HBoxContainer/VBoxContainer2/HBoxContainer/PlayerNickname
onready var enemy_name := $MainMarginContainer/ScorePanel/HBoxContainer/VBoxContainer2/HBoxContainer2/EnemyNickname
export (Texture) var grid8
export (Texture) var grid10

 
func _ready():
	Lobby.connect("target_info_received", self, "render_hit")
	confirm.disabled = true
	Lobby.play = self
	timer.set_wait_time(1)
	round_num.text = "Round "+ str(Lobby.round_num) 
	round_score.text = "Round Score: " + str(Lobby.round_score)
	enemy_score.text = ": " + str(Lobby.enemy_score)
	your_score.text = ": " + str(Lobby.player_score)
	set_player_names()
	set_board_size()
	yield(get_tree().create_timer(0.1),"timeout")
	player_grid._ready()
	enemy_grid._ready()
	var ships = ShipLayout.ships_list
	for ship in ships:
		player_grid.insert_item(ship)
	if Lobby.your_turn:
		new_turn()

func set_board_size():
	if Lobby.boardsize == 8:
		player_grid.texture = grid8
		enemy_grid.texture = grid8
	else:
		player_grid.texture = grid10
		enemy_grid.texture = grid10
	print(Lobby.boardsize)	

func _on_Timer_timeout():
	if DisplayValue > 0:
		DisplayValue -= 1
		time.text = str(DisplayValue)
	else:
		Lobby.end_turn()
		timer.stop()

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
	Lobby.player_score = score["player"]
	Lobby.enemy_score = score["enemy"]
	enemy_score.text = ": " + str(Lobby.player_score)
	your_score.text = ": " + str(Lobby.enemy_score)

func set_player_names():
	player_name.text = Global.username
	enemy_name.text = Lobby.enemy_name 
	
func receive_ships_left(ship_left):
	ship_status.text = "Ship left: " + str(ship_left)

func previous():
	get_tree().change_scene("res://Scenes/SetShip.tscn")

func to_lobby():
	get_tree().change_scene("res://Scenes/Screens/Lobby.tscn")

func set_winlose_text(winlost_text:String):
	win_lose_text.text = "You " + winlost_text + "!"

func show_popup():
	win_lose.show()

func to_result():
	get_tree().change_scene("res://Scenes/Screens/Result.tscn")

func clear():
	ShipLayout.clear_ship()

func _on_Button_pressed():
	to_lobby()

func _on_Skip_pressed():
	Lobby.concede()
