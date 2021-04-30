extends MenuBase
class_name MenuOptions

func cancel():
	navigate_sub_menu(MENUS.menu_dict["PauseMenu"].instance())

func _on_menu_option_chose(option):
	match(option.name):
		"Graphics":
			pass
		"Sounds": 
			var _err = navigate_sub_menu(MENUS.menu_dict["SoundMenu"].instance())
		"Inputs": 
			var _err = navigate_sub_menu(MENUS.menu_dict["InputMenu"].instance())
