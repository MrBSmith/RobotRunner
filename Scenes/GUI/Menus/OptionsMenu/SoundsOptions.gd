extends MenuOptionsBase

onready var children_array = get_children()
	
func on_option_selected():
	for child in children_array:
		child.visible = true

func on_option_unselected():
	for child in children_array:
		child.visible = false
