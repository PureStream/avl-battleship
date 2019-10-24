extends MarginContainer

onready var name_label = $Scoreboard/NameLabel
onready var counter = $Scoreboard/RoundCounters
onready var ship = $Scoreboard/ShipCountContainer/ShipCount
onready var score = $Scoreboard/ScoreMargin/ScoreLabel

var counter_amt = 2

func _ready():
	pass

func set_username(name):
	name_label.text = name

func set_ship_left(num):
	ship.text = str(num)

func set_score(num):
	if num <= 1:
		score.text = str(num) + " pt."
	else:
		score.text = str(num) + " pts."

func set_max_counter(num):
	num = num if num <= 3 else 3
	num = num if num > 0 else 1
	counter_amt = num
	var counters = counter.get_children()
	for i in range(3):
		if i < counter_amt:
			counters[i].visible = true
		else:
			counters[i].visible = false

func set_win_count(num):
	num = num if num > 0 else 0
	num = num if num <= counter_amt else counter_amt
	var counters = counter.get_children()
	for i in range(3):
		if i < num:
			counters[i].set_state(true)
		else: 
			counters[i].set_state(false)