extends MenuBase
class_name SlotSaverMenu

#### ACCESSORS ####

func is_class(value: String): return value == "SlotSaverMenu" or .is_class(value)
func get_class() -> String: return "SlotSaverMenu"

#### BUILT-IN ####

#### LOGIC ####

func save_game_into_slot(slot_saved_id : int):
	GAME.save_data.settings["system"]["slot_id"] = slot_saved_id
	navigate_sub_menu(MENUS.menu_dict["SaveConfirmMenu"].instance())


func resume_game():
	get_tree().set_pause(false)
	queue_free()

#### VIRTUALS ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
func _on_menu_option_chose(option: MenuOptionsBase):
	match(option.get_name()):
		"Resume":
			resume_game()
		_:
			save_game_into_slot(option.get_index() + 1)
