extends Control

signal cancel

onready var dialog := $CenterContainer/ConfirmationDialog

func _ready():
	pass # Replace with function body.

func show():
	dialog.popup()
	
func hide():
	dialog.hide()

func _on_ConfirmationDialog_confirmed():
	emit_signal("cancel")

func connecting():
	dialog.dialog_text = "Connecting..."
	
func matching():
	dialog.dialog_text = "Looking for player..."

func _on_ConnnectingPopup_cancel():
	self.queue_free()
