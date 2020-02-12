extends MenuOptionsBase

onready var children_array = get_children()

func options_action():
	pass

func on_option_selected():
	for child in children_array:
		child.visible = true

func on_option_unselected():
	for child in children_array:
		child.visible = false
