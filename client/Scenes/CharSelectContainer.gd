extends HBoxContainer


var char_amt = int(Global.Characters.Total)
var char_view = 3
var char_select_btns = []

var current_view = 0
var max_page = int(floor(char_amt/char_view))

var selected = 0

onready var char_list = $CharSelectList
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(char_view):
		char_select_btns.append(char_list.get_child(i))
		char_select_btns[i].connect("selected", self, "_on_Character_pressed")
		char_select_btns[i].set_label(i) #replace with setting image and IDs
	char_select_btns[selected].select()

func _input(event):
    # Wheel Up Event
	if event.is_action_pressed("ui_next") or event.is_action_pressed("ui_prev"):
		if event.is_action_pressed("ui_next"):
			select_step(1)
		elif event.is_action_pressed("ui_prev"):
			select_step(-1)

func _on_PrevBtn_pressed():
	step(-1)

func _on_NextBtn_pressed():
	step(1)

func _on_Character_pressed(obj):
	for i in range(char_view):
		var btn = char_select_btns[i]
		if btn != obj:
			btn.deselect()
		else:
			selected = i+current_view*char_view

func select_step(dir:int):
	var frame = int(floor(selected/char_view))
	selected += dir
	var btn = char_select_btns[selected%char_view]
	if selected < 0:
		selected = char_amt-1
		btn = char_select_btns[selected%char_view]
		step(-1)
		btn.select()
		_on_Character_pressed(btn)
		return
	elif selected >= char_amt:
		selected = 0
		btn = char_select_btns[0]
		step(1)
		btn.select()
		_on_Character_pressed(btn)
		return
	var new_frame = int(floor(selected/char_view))
	step(new_frame-frame)
	btn.select()
	_on_Character_pressed(btn)

func step(dir:int):
	if dir == 0:
		return
	for btn in char_select_btns:
		btn.deselect()
	current_view += dir
	if current_view < 0:
		current_view = max_page
	elif current_view > max_page:
		current_view = 0
	if selected < (current_view+1)*char_view && selected >= current_view*char_view:
		char_select_btns[selected%char_view].highlight()
	for i in range(char_view):
		#replace with setting image and IDs
		if(i+current_view*char_view >= char_amt):
			char_select_btns[i].set_label(-1)
			char_select_btns[i].disabled = true #make texture empty instead
		else:
			char_select_btns[i].set_label(i+current_view*char_view)
			char_select_btns[i].disabled = false