extends MenuBase
class_name SaveConfirmMenu

onready var currentsave_container_node = $SaveInformations/CurrentSave
onready var lineedit_csavename_node = $SaveInformations/CurrentSave/HBoxContainer/SaveNameField
onready var label_csavetime_node = $SaveInformations/CurrentSave/c_savetime
onready var label_csavelevel_node = $SaveInformations/CurrentSave/c_savelevel

onready var targetsave_container_node = $SaveInformations/TargetSave
onready var label_tsavename_node = $SaveInformations/TargetSave/t_savename
onready var label_tsavetime_node = $SaveInformations/TargetSave/t_savetime
onready var label_tsavelevel_node = $SaveInformations/TargetSave/t_savelevel

var save_id : int = 1
var save_folder_name : String

#### ACCESSORS ####

func is_class(value: String): return value == "SaveConfirmMenu" or .is_class(value)
func get_class() -> String: return "SaveConfirmMenu"

#### BUILT-IN ####

func _ready():
	save_folder_name = GameLoader.find_corresponding_save_file(GAME.SAVEGAME_DIR, save_id)
	if save_folder_name != "":
		update_menu_labels()
	
	if "namestaken_info_node" in lineedit_csavename_node:
		lineedit_csavename_node.namestaken_info_node = $SaveInformations/CurrentSave/c_savenamestaken
	if "submitsave_button" in lineedit_csavename_node:
		lineedit_csavename_node.submitsave_button = $"HBoxContainer/V_OptContainer/Confirm Save"


#### VIRTUAL ####

func cancel():
	get_tree().set_pause(false)
	queue_free()


#### LOGIC ####

func update_menu_labels():
	update_current_save_informations()
	
	# User will not overwrite any save if he confirms, hide targetsave container
	if save_folder_name == "": 
		targetsave_container_node.visible = false
	# User will overwrite a save if he confirms ! > Display target save informations
	else: 
		update_target_save_informations()


func update_current_save_informations():
	var target_cfg_save_time = GameLoader.get_cfg_property_value(GAME.SAVEGAME_DIR, "time", save_id)
	label_csavetime_node.text = get_save_time(target_cfg_save_time)
	label_csavelevel_node.text = label_csavelevel_node.text + "Level " + str(GAME.progression.get_level() + 1)


func update_target_save_informations():
	var target_cfg_save_time : Dictionary = {}
	target_cfg_save_time = GameLoader.get_cfg_property_value(GAME.SAVEGAME_DIR, "time", save_id)
	label_tsavename_node.text = get_save_time(target_cfg_save_time)

	label_tsavelevel_node.text += "Level " + str(GameLoader.get_cfg_property_value(GAME.SAVEGAME_DIR, "level_id",save_id))


func get_save_time(save_time_dict: Dictionary) -> String:
	var save_time := ""
	var time_component_array = ["day", "month", "year", "hour", "minute"]
	for component in time_component_array:
		save_time += str(save_time_dict.get(component))
		var sufix = ""
		
		match(component):
			"day", "month" : sufix = "/"
			"year": sufix = " "
			"hour": sufix = "h"
			"minute": sufix= ":"
		
		save_time += sufix
	return save_time


func submit_and_save_game():
	var save_name : String = lineedit_csavename_node.text
	save_name = save_name.replacen(" ", "_")
	
	if save_name == "":
		save_name = "save" + str(save_id)

	if save_folder_name != "":
		DirNavHelper.delete_folder(GAME.SAVEGAME_DIR + "/" + save_folder_name)
	
	DirNavHelper.create_dir(GAME.SAVEGAME_DIR, save_name)
	GameSaver.save_settings(GAME.SAVEGAME_DIR + "/" + save_name, save_name)
	
	var save_slot_path = GameLoader.find_corresponding_save_file(GAME.SAVEGAME_DIR, save_id)
	DirNavHelper.transfer_dir_content(GAME.SAVEDLEVEL_DIR, GAME.SAVEGAME_DIR + "/" + save_slot_path)
	
	cancel()


#### VIRTUALS ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
func _on_menu_option_chose(option) -> void:
	match(option.get_name()):
		"Cancel": cancel()
		"Confirm Save": submit_and_save_game()
