extends Node

onready var settings_file = "user://settings.save"
var login_email := ""
var password := ""
var sound_value = 50
var music_value = 50

func _ready():
	pass # Replace with function body.
	
func save():
	var save_dict = {
		"email": login_email,
		"password": password,
		"sound_value": sound_value,
		"music_value": music_value
	}
	return save_dict
	
func save_email():
	var f := File.new()
	f.open(settings_file, File.WRITE)
	var to_save = save()
	f.store_line(to_json(to_save))
	f.close()

func load_email():
	var f := File.new()
	if not f.file_exists("user://settings.save"):
		return
	f.open(settings_file, File.READ)
	var curr_line = parse_json(f.get_line())
	login_email = curr_line["email"]
	f.close()
