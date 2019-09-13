extends Control

var DisplayValue = 10

onready var timer = get_node("Timer")
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.set_wait_time(0.5)
	timer.start()



func _on_Timer_timeout():
	if DisplayValue > 0:
		DisplayValue -= 1
