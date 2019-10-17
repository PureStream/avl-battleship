extends Node2D

onready var click := $ClickSound

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	position = get_global_mouse_position()
	if Input.is_action_just_pressed("Left_Mouse"):
		click.play()

