extends Node

var buttons = ["How To Play", "Basic", "Classic", "Blitz", "Team Setup", "Options", "Credits"]

export (PackedScene) var btn_default

var screen_height:float = ProjectSettings.get("display/window/size/height")
var radius = Vector2(screen_height*0.66, 0)
const STARTING_RAD = deg2rad(-48)
var rad_increment:float = deg2rad(24)
var centerpoint:Vector2 = Vector2(-70, screen_height*0.5)

var button_instances = []

onready var cog = $Cog

func _ready():
	print(screen_height)
	var target_position = centerpoint
	var target_radius = radius.rotated(STARTING_RAD)
	cog.position = centerpoint
	for btn in buttons:
		var new_button:MenuButton = btn_default.instance()
		new_button.set_name(btn)
		new_button.set_position(target_position+target_radius)
		#new_button.set_rotation(rad2deg(target_radius.angle()))
		target_radius = target_radius.rotated(rad_increment)
		add_child(new_button)
		button_instances.append(new_button)
	$Cog

var rotating = false

var scroll_rotate_count:int = 0
var time_since_last_scroll:float = 0
const SCROLL_LIMIT = 0.08

func _input(event):
    # Wheel Up Event
	if event.is_action_pressed("ui_scroll_down") or event.is_action_pressed("ui_scroll_up"):
		if event.is_action_pressed("ui_scroll_down"):
			if(scroll_rotate_count> -1):
				scroll_rotate_count-=1
	    # Wheel Down Event
		elif event.is_action_pressed("ui_scroll_up"):
			if(scroll_rotate_count< 1):
				scroll_rotate_count+=1

		if scroll_rotate_count != 0:
			if rotating == false:
				time_since_last_scroll = SCROLL_LIMIT if time_since_last_scroll < SCROLL_LIMIT else time_since_last_scroll
				rotate_speed(sign(scroll_rotate_count),1.3+0.2/time_since_last_scroll)
				scroll_rotate_count-=sign(scroll_rotate_count)
		time_since_last_scroll = 0



func _process(delta):
	if(time_since_last_scroll<1):
		time_since_last_scroll+=delta
		
	if !Input.is_action_pressed("ui_down") or !Input.is_action_pressed("ui_up"):
		if Input.is_action_pressed("ui_down"):
			if rotating == false:
				rotate_speed(-1,1.5)
	
		if Input.is_action_pressed("ui_up"):
			if rotating == false:
				rotate_speed(1,1.5)


var direction = 0
const ANIM_LENGTH = 0.25
onready var tween = $MainButtonTween

func rotate(dir:int):
	rotate_speed(dir,1)

func rotate_speed(dir:int, speed_scale:float):
	rotating = true
	direction = dir
	if dir == 1:
		var tmp = button_instances.pop_back()
		button_instances.push_front(tmp)
		
		tween.interpolate_method(self, "rotate_to", 0, 
		rad_increment, ANIM_LENGTH/speed_scale, Tween.TRANS_BACK, Tween.EASE_OUT,0)
		
		tween.interpolate_property(cog, "rotation_degrees", cog.rotation_degrees, 
		cog.rotation_degrees+rad2deg(rad_increment), ANIM_LENGTH/speed_scale, 
		Tween.TRANS_BACK, Tween.EASE_OUT,0)
	elif dir == -1:
		tween.interpolate_method(self, "rotate_to", 0, 
		-rad_increment, ANIM_LENGTH/speed_scale, Tween.TRANS_BACK, Tween.EASE_OUT,0)
		
		tween.interpolate_property(cog, "rotation_degrees", cog.rotation_degrees, 
		cog.rotation_degrees+rad2deg(-rad_increment), ANIM_LENGTH/speed_scale, 
		Tween.TRANS_BACK, Tween.EASE_OUT,0)
	else:
		return
	tween.start()

func rotate_to(rad):
	var starting_rad = STARTING_RAD - rad_increment if direction == 1 else STARTING_RAD
	starting_rad += rad
	var target_position = centerpoint
	var target_radius = radius.rotated(starting_rad)
	for btn in button_instances:
		btn.set_position(target_position+target_radius)
		#btn.set_rotation(rad2deg(target_radius.angle()))
		target_radius = target_radius.rotated(rad_increment)

func _on_MainButtonTween_tween_all_completed():
	rotating = false
	#print("finished tween")
	if direction == -1:
		var tmp = button_instances.pop_front()
		button_instances.push_back(tmp)