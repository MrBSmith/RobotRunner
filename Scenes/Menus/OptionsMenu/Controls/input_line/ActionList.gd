extends Control

const InputLine = preload("res://Scenes/Menus/OptionsMenu/Controls/input_line/InputLine.tscn")

#### LOGIC ####

func clear():
	for child in get_children():
		child.free()

#This function will add a new line to the ActionList node, so that all the actions will be displayed
func add_input_line(action_name, key, is_customizable=false):
	var line = InputLine.instance()
	line.initialize(action_name, key, is_customizable)	
	add_child(line)
	return line
