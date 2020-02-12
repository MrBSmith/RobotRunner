extends MenuOptionsBase

onready var title_screen = "res://Scenes/GUI/Menus/ScreenTitle/ScreenTitle.tscn"

func options_action():
	var _err = get_tree().change_scene(title_screen)
	get_tree().paused = false
