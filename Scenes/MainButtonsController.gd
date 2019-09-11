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

func _process(delta):
	
	if !Input.is_action_pressed("ui_down") or !Input.is_action_pressed("ui_up"):
		if Input.is_action_pressed("ui_down"):
			if rotating == false:
				rotate(-1)
	
		if Input.is_action_pressed("ui_up"):
			if rotating == false:
				rotate(1)

var direction = 0
const ANIM_LENGTH = 0.25
onready var tween = $MainButtonTween


func rotate(dir:int):
	rotating = true
	direction = dir
	if dir == 1:
		var tmp = button_instances.pop_back()
		button_instances.push_front(tmp)
		
		tween.interpolate_method(self, "rotate_to", 0, 
		rad_increment, ANIM_LENGTH, Tween.TRANS_BACK, Tween.EASE_OUT,0)
		
		tween.interpolate_property(cog, "rotation_degrees", cog.rotation_degrees, 
		cog.rotation_degrees+rad2deg(rad_increment), ANIM_LENGTH, 
		Tween.TRANS_BACK, Tween.EASE_OUT,0)
	elif dir == -1:
		tween.interpolate_method(self, "rotate_to", 0, 
		-rad_increment, ANIM_LENGTH, Tween.TRANS_BACK, Tween.EASE_OUT,0)
		
		tween.interpolate_property(cog, "rotation_degrees", cog.rotation_degrees, 
		cog.rotation_degrees+rad2deg(-rad_increment), ANIM_LENGTH, 
		Tween.TRANS_BACK, Tween.EASE_OUT,0)
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

func _on_MainButtonTween_tween_completed(object, key):
	rotating = false
	#print("finished tween")
	if object == self:
		if direction == -1:
			var tmp = button_instances.pop_front()
			button_instances.push_back(tmp)
