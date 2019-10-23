extends Control

const ship_base = preload("res://Scenes/ShipBase.tscn")

onready var control_container := $MainMarginContainer/MainBoxContainer/PlayerContainer/PlayerThings/ControlContainer
onready var player_grid = control_container.get_node("PlayerGrid")
onready var enemy_grid = $MainMarginContainer/MainBoxContainer/EnemyContainer/EnemyGrid
onready var shoot = control_container.get_node("ShootButton")
onready var timer = control_container.get_node("Timer")
onready var score_container = $MainMarginContainer/MainBoxContainer/PlayerContainer/ScorePanel/ScoreContainer
onready var player_score = score_container.get_node("PScoreboard")
onready var enemy_score = score_container.get_node("EScoreboard")
onready var delay = $Delay
onready var turn_panel = $TurnPanel

export (Texture) var grid8
export (Texture) var grid10
export (Texture) var grid8_s
export (Texture) var grid10_s
 
func _ready():
	Lobby.connect("target_info_received", self, "render_hit")
	shoot.disabled = true
	enemy_grid.shoot = shoot
	Lobby.play = self
	
	#change to variable rule: Bo1, Bo3, Bo5
	player_score.set_max_counter(2)
	enemy_score.set_max_counter(2)
	
	set_round_score(Lobby.round_score, Lobby.enemy_round_score)
	
	player_score.set_ship_left(Lobby.max_ship)
	enemy_score.set_ship_left(Lobby.max_ship)
	
	set_player_names()
	set_board_size()
	player_grid.call_deferred("_ready")
	enemy_grid.call_deferred("_ready")
	var ships = ShipLayout.ships_list
	for ship in ships:
		player_grid.insert_item(ship)
	start_game(Lobby.your_turn)

func _input(event):
	if event.is_action_pressed("inv_grab"):
		if click_to_exit:
			clear()
			to_result()
	if event.is_action_pressed("debug_insert_all_ships"):
		_on_Skip_pressed()

func start_game(yours):
	turn_panel.set_round_begin(Lobby.round_num)
	turn_panel.play_begin_animation(yours)
	if !yours:
		shoot.set_enemy_turn()
	else:
		shoot.set_before_target()

func set_board_size():
	player_grid.set_grid_size(Lobby.boardsize, Lobby.boardsize)
	enemy_grid.set_grid_size(Lobby.boardsize, Lobby.boardsize)
	if Lobby.boardsize == 8:
		player_grid.texture = grid8_s
		enemy_grid.texture = grid8
		player_grid.grid_offset = 1
		enemy_grid.grid_offset = 1
	else:
		player_grid.texture = grid10_s
		enemy_grid.texture = grid10
		player_grid.grid_offset = 0
		enemy_grid.grid_offset = 0

func _on_Confirm_pressed():
	var x = enemy_grid.reticle_pos.x 
	var y = enemy_grid.reticle_pos.y 
	Lobby.send_target_position({"x":x,"y":y})
	shoot.disabled = true

func render_hit(hit):
	var x = enemy_grid.reticle_pos.x 
	var y = enemy_grid.reticle_pos.y 
	if hit:
		enemy_grid.insert_mark({"id":"Hit","g_pos":{"x":x,"y":y}})
	else:
		enemy_grid.insert_mark({"id":"Miss","g_pos":{"x":x,"y":y}})
	enemy_grid.reticle.visible = false
	enemy_grid.hit_map[x][y] = false

	end_turn()

func receive_hit(pos, value):
	var x = pos["x"] 
	var y = pos["y"] 
	if value:
		player_grid.insert_mark({"id":"Hit","g_pos":{"x":x,"y":y}})
	else:
		player_grid.insert_mark({"id":"Miss","g_pos":{"x":x,"y":y}})
	#play hit animation before sending ready signal
	end_turn()

func new_turn():
	turn_panel.set_turn(Lobby.turn_num, Lobby.your_turn)
	turn_panel.play_animation()
	timer.reset()
	if !Lobby.your_turn:
		shoot.set_enemy_turn()
	else:
		shoot.set_before_target()

func end_turn():
	shoot.disabled = true
	if Lobby.your_turn:
		enemy_grid.deactivate()
	Lobby.your_turn = false #not really needed
	timer.stop_timer()
	Lobby.end_turn_ready()

func _on_TurnPanel_animation_completed():
	if Lobby.your_turn:
		enemy_grid.activate()
	timer.start_timer()

func set_score(score):
	var p_score = score["player"]
	var e_score = score["enemy"]
	enemy_score.set_score(e_score)
	player_score.set_score(p_score)
	
func set_round_score(score, enemy_score):
	player_score.set_win_count(score)
	self.enemy_score.set_win_count(enemy_score)

func set_player_names():
	player_score.set_username(Global.username)
	enemy_score.set_username(Lobby.enemy_name)

func receive_ships_left(p_ship, e_ship):
	player_score.set_ship_left(p_ship)
	enemy_score.set_ship_left(e_ship)

func previous():
	get_tree().change_scene("res://Scenes/SetShip.tscn")

func to_lobby():
	get_tree().change_scene("res://Scenes/Screens/Lobby.tscn")

var click_to_exit = false

func end_game(win:bool):
	turn_panel.set_end_game(win)
	turn_panel.play_end_animation()
	delay.start()
	timer.stop_timer()
	yield(delay, "timeout")
	click_to_exit = true
	
func end_round(win:bool):
	turn_panel.set_round_end(win, Lobby.round_num)
	turn_panel.play_end_animation()
	timer.stop_timer()
	delay.start()
	yield(delay, "timeout")
	clear()
	previous()

func to_result():
	get_tree().change_scene("res://Scenes/Screens/Result.tscn")

func clear():
	ShipLayout.clear_ship()

func _on_Button_pressed():
	to_lobby()

func _on_Skip_pressed():
	timer.stop_timer()
	Lobby.concede()

func _on_Timer_timeout():
#	print("timeout")
	if Lobby.your_turn:
		Lobby.timeout()
		end_turn()

func _on_EnemyGrid_target_selected():
	shoot.set_active()
