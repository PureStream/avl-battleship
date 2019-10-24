extends Button

onready var label := $Label
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_enemy_turn():
	disabled = true
	label.text = "Enemy's\nTurn"
	set_label_color(Color(0.7,0.7,0.7))

func set_before_target():
	disabled = true
	label.text = "Select\nLocation"
	set_label_color(Color(0.7,0.7,0.7))
	
func set_active():
	disabled = false
	label.text = "Shoot"
	set_label_color(Color(1,1,1))

func set_label_color(color):
	label.set("custom_colors/font_color", color)