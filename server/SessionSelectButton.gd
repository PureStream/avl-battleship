extends Button

signal session_select

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_SessionSelectButton_pressed():
	emit_signal("session_select", self.get_meta("id"))
