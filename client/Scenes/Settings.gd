extends Node

#onready var bgm := $BGMPlayer
onready var settings_file = "user://settings.save"
var login_email := ""
var login_password := ""
var is_remember_password = false
var sound_value = 100
var music_value = 100
var bgm = null
var sound = null
var curr_music = " "
	
func _ready():
	load_profile()
	#call_deferred("play", bgm)
	bgm = AudioStreamPlayer.new()
	bgm.set_bus("Music")
	self.add_child(bgm)
	sound = AudioStreamPlayer.new()
	sound.set_bus("Sound")
	self.add_child(sound)
	
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

var music_list = {
	"BGM1": "res://Sounds/Hopes and Dreams.ogg"
}

var sound_list = {
	"On_Hit": "res://Sounds/On_Hit.wav",
	"On_Hit2": "res://Sounds/On_Hit2.wav",
	"On_Miss": "res://Sounds/On_Missed.wav",
	"Ship_Destroyed": "res://Sounds/Ship_Destroyed.wav",
	"Target_Locked": "res://Sounds/Target_Locked.wav",
	"Button_Pressed": "res://Sounds/Tiny Button Push-SoundBible.com-513260752.wav"
}
	
func play_bgm(key):
	if key in music_list.keys() && curr_music != key:
		curr_music = key
		bgm.stream = load(music_list[key])
		bgm.play()

func stop_bgm():
	bgm.stop()
	
func play_sound(key):
	if key in sound_list.keys():
		sound.stream = load(sound_list[key])
		sound.play()
		
func stop_sound():
	sound.stop()