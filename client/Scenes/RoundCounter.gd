extends TextureRect

export (Texture) var empty
export (Texture) var filled

func _ready():
	pass

func set_state(state:bool):
	if state:
		set("texture", filled)
	else: 
		set("texture", empty)