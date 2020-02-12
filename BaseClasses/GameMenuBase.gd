extends Control

class_name MenuBase

onready var opt_container = get_node("HBoxContainer/V_OptContainer")
onready var choice_sound_node = get_node("OptionChoiceSound")
onready var options_array = opt_container.get_children()

var opt_index : int = 0 # Get the index where the player aim
var prev_opt_index : int = 0 # Get the index where the player aimed before changing
var count_not_clickable_options : int # Count how many options are not clickable

const WHITE := Color(1, 1, 1, 1)
const GREY := Color(0.25, 0.25, 0.25, 1)
const RED := Color(1, 0, 0, 1)
const BLUE := Color(0, 0, 1, 1)
const CYAN := Color(0, 0.9, 1, 1)
# Check the options when the scenes is ready, to get sure at least one of them is clickable
# Change the color of the option accordingly to their state
func _ready():	
	check_clickable_options()
	highlight_menuopt()


# Main Navigation handling
func _unhandled_input(event):
	if event is InputEventKey:
		# If the player hit confirm
		if Input.is_action_just_pressed("ui_accept"):
			options_array[opt_index].options_action()
		
		# Play the sound and set the previous option to be the opti
		if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
			choice_sound_node.play()
			prev_opt_index = opt_index
			
			# If the player hit up -> Navigate up
			if Input.is_action_just_pressed("ui_up"):
				options_up()
				while(!options_array[opt_index]._clickable):
					options_up()
			
			# If the player hit down -> Navigate down
			elif Input.is_action_just_pressed("ui_down"):
				options_down()
				while(!options_array[opt_index]._clickable):
					options_down()
			
			# Change the color of the options
			highlight_menuopt()


# Exit the game if there is no clickable option
func check_clickable_options():
	for opt in options_array:
		if (!opt._clickable):
			count_not_clickable_options += 1
	if(count_not_clickable_options == len(options_array)):
		print("There are no clickable options. Exiting...")
		get_tree().quit()
	
	for n in range(len(options_array)):
		if(!options_array[n]._clickable):
			options_array[n].set_self_modulate(GREY)


# Navigate the menu up
func options_up():
	opt_index -= 1
	if(opt_index < 0):
		opt_index = len(options_array)-1


# Navigate the menu down
func options_down():
	opt_index += 1
	if(opt_index > len(options_array)-1):
		opt_index = 0

# Change the color of menu option according if it is selected by a player or not
func highlight_menuopt():
	options_array[prev_opt_index].set_self_modulate(WHITE) # WHITE COLOR = Not selected
	options_array[opt_index].set_self_modulate(RED) # RED COLOR = SELECTED$
	
	if options_array[prev_opt_index].has_method("on_option_unselected"):
		options_array[prev_opt_index].on_option_unselected()
		
	if options_array[opt_index].has_method("on_option_selected"):
		options_array[opt_index].on_option_selected()
