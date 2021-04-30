extends MenuOptionsBase

func on_pressed():
	var _err = get_tree().change_scene_to(MENUS.menu_dict["ScreenTitle"])
	get_tree().paused = false
