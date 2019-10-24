extends Node

onready var bgm := $BGMPlayer
onready var settings_file = "user://settings.save"
var login_email := ""
var login_password := ""
var is_remember_password = false
var sound_value = 100
var music_value = 100
var curr_scene = self.name

	
func _ready():
	call_deferred("play", bgm)
	#play_bgm()
	
func save():
	var save_dict = {
		"email": login_email,
		"password": login_password,
		"sound_value": sound_value,
		"music_value": music_value,
		"is_remember_password": is_remember_password,
	}
	return save_dict
	
func save_profile():
	var f := File.new()
	f.open(settings_file, File.WRITE)
	var to_save = save()
	f.store_line(to_json(to_save))
	f.close()

func load_profile():
	var f := File.new()
	if not f.file_exists("user://settings.save"):
		return
	f.open(settings_file, File.READ)
	var curr_line = parse_json(f.get_line())
	login_email = curr_line["email"]
	login_password = curr_line["password"]
	is_remember_password = curr_line["is_remember_password"]
	sound_value = curr_line["sound_value"]
	music_value = curr_line["music_value"]
	f.close()

func play_bgm():
	var bgm = AudioStreamPlayer.new()
	bgm.set_bus("Music")
	self.add_child(bgm)
	bgm.stream = load("res://Sounds/Hopes and Dreams.ogg")
	bgm.play()

func stop_bgm():
	pass