extends HBoxContainer

signal timeout

var resetting = false

onready var anim = $TimerIcon/TimerAnim

func _ready():
	pass # Replace with function body.

func start_timer():
	resetting = false
	anim.playback_speed = 1
	anim.play("TimerAnimation")

func stop_timer():
	resetting = true
	anim.stop(false)
#	print("stopped animation")

func _on_TimerAnim_animation_finished(anim_name):
	if !resetting:
#		print("animation finished")
		emit_signal("timeout")

func reset():
	resetting = true
	var length = anim.current_animation_length
	anim.playback_speed = length / 1.5
	anim.play_backwards("TimerAnimation")