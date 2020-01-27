extends Control

class_name MenuBase

onready var opt_container = get_node("HBoxContainer/V_OptContainer")
onready var choice_sound_node = get_node("OptionChoiceSound")
onready var options_array = opt_container.get_children()

var opt_index : int = 0 # Get the index where the player aim
var prev_opt_index : int = 0 # Get the index where the player aimed before changing
var count_not_clickable_options : int # Count how many options are not clickable

func _ready():
	check_clickable_options()


func _physics_process(_delta):
	highlight_menuopt()


func _unhandled_input(event):
	if event is InputEventKey:
		# If the player hit confirm
		if Input.is_action_just_pressed("ui_accept"):
			options_array[opt_index].options_action()
		
		# If the player hit up or down
		elif Input.is_action_just_pressed("ui_up"):
			choice_sound_node.play()
			prev_opt_index = opt_index
			options_up()
			while(!options_array[opt_index]._clickable):
				options_up()
		elif Input.is_action_just_pressed("ui_down"):
			choice_sound_node.play()
			prev_opt_index = opt_index
			options_down()
			while(!options_array[opt_index]._clickable):
				options_down()


func check_clickable_options():
	for opt in options_array:
		if (!opt._clickable):
			count_not_clickable_options+=1
	if(count_not_clickable_options == len(options_array)):
		print("There are no clickable options. Exiting...")
		get_tree().quit()


func options_up():
	opt_index -= 1
	if(opt_index < 0):
		opt_index = len(options_array)-1


func options_down():
	opt_index += 1
	if(opt_index > len(options_array)-1):
		opt_index = 0

# Change the color of menu option according if it is selected by a player or not
func highlight_menuopt():
	options_array[prev_opt_index].set_self_modulate(Color(1,1,1,1)) # WHITE COLOR = Not selected
	options_array[opt_index].set_self_modulate(Color(1,0,0,1)) # RED COLOR = SELECTED