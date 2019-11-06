extends Control

onready var player := $ResultContainer/ProgressContainer/MarginContainer/Player
onready var enemy := $ResultContainer/ProgressContainer/MarginContainer/Enemy

onready var text_label := $ResultContainer/LabelMargin/Label

onready var progress_back := $ResultContainer/ProgressContainer/ProgressBack
onready var progress_front := $ResultContainer/ProgressContainer/ProgressFront

func _ready():
	pass # Replace with function body.

func set_label(string):
	text_label.text = string

func set_colors(col1:Color, col2:Color):
	progress_back.tint_progress = col1
	progress_front.tint_progress = col2

func set_values(num1, num2):
	var value = 50
	if num1 + num2 != 0:
		value = float(num2) / (num1 + num2) * 100
	progress_front.value = value
	if typeof(num1) == TYPE_INT:
		player.text = str(num1)
	else:
		player.text = "%.2f" % num1
	if typeof(num2) == TYPE_INT:	
		enemy.text = str(num2)
	else: 
		enemy.text = "%.2f" % num2