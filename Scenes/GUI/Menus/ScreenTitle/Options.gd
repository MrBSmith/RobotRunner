extends MenuOptionsBase

onready var option_menu = preload("res://Scenes/GUI/Menus/OptionsMenu/OptionsMenu.tscn")

func options_action():
	var opt_menu_node = option_menu.instance()
	owner.get_parent().add_child(opt_menu_node)
	owner.queue_free()
