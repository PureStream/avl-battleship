extends Node

onready var char_select_container = $MarginContainer/VBoxContainer/CharSelectContainer
onready var displayname := $MarginContainer/VBoxContainer/NameContainer/DisplayName

func _ready():
	displayname.text = Global.username


