extends CanvasLayer

# Create an instance of the menu if it doesn't exist yet
func _input(_event):
	if Input.is_action_just_pressed("ui_cancel") && get_node_or_null("PauseMenu") == null:
		var pause_menu_node = MENUS.menu_dict["PauseMenu"].instance()
		add_child(pause_menu_node)
