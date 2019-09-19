extends Control

signal cancel

func _ready():
	pass # Replace with function body.

func show():
	$CenterContainer/ConfirmationDialog.popup()

func _on_ConfirmationDialog_confirmed():
	emit_signal("cancel")

func connecting():
	$CenterContainer/ConfirmationDialog.dialog_text = "Connecting..."
	
func matching():
	$CenterContainer/ConfirmationDialog.dialog_text = "Looking for player..."