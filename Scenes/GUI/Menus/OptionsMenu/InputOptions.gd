extends MenuOptionsBase

onready var controls_scene = preload("res://Scenes/GUI/Menus/OptionsMenu/Controls/InputMenu.tscn")
onready var children_array = get_children()

func options_action():
	var input_menu_node = controls_scene.instance()
	owner.get_parent().add_child(input_menu_node)
	owner.queue_free()
	
func on_option_selected():
	for child in children_array:
		child.visible = true

func on_option_unselected():
	for child in children_array:
		child.visible = false
