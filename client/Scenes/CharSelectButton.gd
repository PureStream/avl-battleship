extends TextureButton

onready var label = $Label
onready var glow = $SelectedGlow

signal selected
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_label(num:int):
	label.text = str(num)

func select():
	glow.visible = true #maybe select animation

func highlight():
	glow.visible = true #just highlight it

func deselect():
	glow.visible = false

func _on_CharSelectButton_pressed():
	select()
	emit_signal("selected", self)
	pass # Replace with function body.
