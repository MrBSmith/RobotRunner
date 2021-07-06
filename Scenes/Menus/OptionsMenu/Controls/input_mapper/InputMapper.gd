extends Node
class_name InputMapper

func is_class(value: String): return value == "InputMapper" or .is_class(value)
func get_class() -> String: return "InputMapper"

signal profile_changed(new_profile, is_customizable)

enum PROFILES_PRESET{AZERTY, QWERTY, CUSTOM}
export(PROFILES_PRESET) var default_profile_id

var profiles : Dictionary
var current_profile_id : int = default_profile_id
var custom_profile_id : int = PROFILES_PRESET.CUSTOM

#### ACCESSORS ####

#### BUILT-IN ####

#Init all necessary variables and profiles
func _init():
	var input_profile_config_file = ConfigFile.new()
	var err = input_profile_config_file.load(GAME.DEFAULT_INPUT_PATH)
	if err == OK:
		for section in input_profile_config_file.get_sections():
			profiles[section] = Dictionary()
			for key in input_profile_config_file.get_section_keys(section):
				profiles[section][key] = input_profile_config_file.get_value(section, key)
	else:
		push_error("Failed to load input profile config file. Error code : " + str(err))
		return

#### LOGIC ####

#Get the selected profile id to change it. Refer to profile var for more information about IDs
func _change_profile(id : int) -> void:
	current_profile_id = id
	var profiles_values = profiles.values()
	var profile = profiles_values[id]
	var is_customizable = true if id == 2 else false #Currently, the customizable profile is the 3rd one, so ID(2).
	
	emit_signal('profile_changed', profile, is_customizable)


# This function will remove the current action from the settings and add a new key as an event
func _change_action_key(action_name : String, key_scancode : int):
	_erase_action_events(action_name)

	var new_event = InputEventKey.new()
	new_event.set_scancode(key_scancode)
	InputMap.action_add_event(action_name, new_event)
	_get_selected_profile()[action_name] = key_scancode


# This function will remove the selected action from the settings (InputMap)
func _erase_action_events(action_name):
	var input_events = InputMap.get_action_list(action_name)
	for event in input_events:
		InputMap.action_erase_event(action_name, event)

func _get_selected_profile() -> Dictionary:
	return profiles.values()[current_profile_id]

#### INPUT ####

#### SIGNALS RESPONSES ####

func _on_ProfilesMenu_item_selected(id :int):
	_change_profile(id)
