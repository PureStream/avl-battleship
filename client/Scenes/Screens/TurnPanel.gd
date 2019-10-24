extends Panel

signal animation_completed

onready var animation = $TurnAnimation
onready var turn_label = $VBoxContainer/TurnLabel
onready var subtitle = $VBoxContainer/SubtitleLabel
onready var timer = $Timer

var max_width = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	max_width = rect_size.x

func set_turn(turn, yours):
	turn_label.text = "Turn " + str(turn)
	if yours:
		subtitle.text = "Your turn"
	else:
		subtitle.text = "Enemy's turn"
	
func set_round_begin(round_num):
	turn_label.text = "Round " + str(round_num)

func set_round_end(win:bool, round_num):
	if win:
		turn_label.text = "You win"
	else:
		turn_label.text = "You lose"
	subtitle.text = " "

func set_end_game(win:bool):
	if win:
		turn_label.text = "Victory"
	else:
		turn_label.text = "Defeat"
	subtitle.text = "Click anywhere to continue."

func play_begin_animation(yours):
	self.yours = yours
	animation.play("Begin")
	
var yours = false
	
func play_begin2_animation():
	set_turn(1, yours)
	animation.play("Begin2")
	timer.start()
	yield(timer, "timeout")
	animation.play("Out")

func play_end_animation():
	animation.play("End")

func play_animation():
	animation.play("In")
	timer.start()
	yield(timer, "timeout")
	animation.play("Out")

func _on_TurnAnimation_animation_finished(anim_name):
	match(anim_name):
		"Out" :
			emit_signal("animation_completed")
