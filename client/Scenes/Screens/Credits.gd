extends Node

onready var credit := $MarginContainer/credits/text

var credits = [
	"PRODUCED & CREATED BY\nAVALON PRODUCTION",
	"PROGRAMMING\nNUKE\nOAT\nEARTH\nBAIPO",
	"GRAPHIC DESIGNER\nNUKE",
	"UX & UI DESIGNER\nBAIPO",
	"SOUND ENGINEERING\nEARTH",
	"SPEACIAL THANKS\nOAT"
]
var counter = 0

func _ready():
	pass # Replace with function body.

func next_credit():
	if (counter > -1):
		credit.text = credits[counter%6]
		counter += 1