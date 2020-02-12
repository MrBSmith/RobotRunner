extends MenuBase

var game_scene = "res://Scenes/Main/Game.tscn"

var screen_width : float = ProjectSettings.get("display/window/size/width")
var screen_height : float = ProjectSettings.get("display/window/size/height")


# Set the GUI layer to be at the origin of the screen
func _ready():
	margin_left = -screen_width
	margin_top = -screen_height

func _unhandled_input(event):
	if event is InputEvent:
		if event.is_action_pressed("ui_cancel"):
			get_tree().paused = false
			queue_free()

#FUNCTION OVERWRITE
# Change the color of menu option according if it is selected by a player or not
func highlight_menuopt():
	options_array[prev_opt_index].set_self_modulate(WHITE) # WHITE COLOR = Not selected
	options_array[opt_index].set_self_modulate(CYAN) # RED COLOR = SELECTED$
	
	if options_array[prev_opt_index].has_method("on_option_unselected"):
		options_array[prev_opt_index].on_option_unselected()
		
	if options_array[opt_index].has_method("on_option_selected"):
		options_array[opt_index].on_option_selected()
