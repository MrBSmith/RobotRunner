extends MenuBase
class_name SaveConfirmMenu

onready var currentsave_container_node = $SaveInformations/CurrentSave
onready var lineedit_csavename_node = $SaveInformations/CurrentSave/HBoxContainer/SaveNameField

onready var targetsave_container_node = $SaveInformations/TargetSave
onready var label_tsavename_node = $SaveInformations/TargetSave/t_savename
onready var label_tsavetime_node = $SaveInformations/TargetSave/t_savetime
onready var label_tsavelevel_node = $SaveInformations/TargetSave/t_savelevel

var save_folder_path : String

#### ACCESSORS ####

func is_class(value: String): return value == "SaveConfirmMenu" or .is_class(value)
func get_class() -> String: return "SaveConfirmMenu"

#### BUILT-IN ####

func _ready():
	save_folder_path = GameLoader.find_save_slot(GAME.SAVE_GAME_DIR, GAME.save_slot)
	if save_folder_path != "":
		update_menu_labels()
	
	if "namestaken_info_node" in lineedit_csavename_node:
		lineedit_csavename_node.namestaken_info_node = $SaveInformations/CurrentSave/c_savenamestaken
	if "submitsave_button" in lineedit_csavename_node:
		lineedit_csavename_node.submitsave_button = $OptionsContainer/ConfirmAndSave


#### VIRTUAL ####

func cancel():
	get_tree().set_pause(false)
	var load_menu = MENUS.menu_dict["LoadGameMenu"].instance()
	load_menu.overwrite_mode = true
	navigate_sub_menu(load_menu)


#### LOGIC ####

func update_menu_labels():	
	# User will not overwrite any save if he confirms, hide targetsave container
	if save_folder_path == "": 
		targetsave_container_node.visible = false
	# User will overwrite a save if he confirms ! > Displ. ay target save informations
	else: 
		update_target_save_informations()

func update_target_save_informations():
	label_tsavename_node.text = "Targetted Save Name: " + GameLoader.get_save_property_value(GAME.SAVE_GAME_DIR, "save_name", GAME.save_slot)
	
	var target_cfg_save_time : Dictionary = {}
	target_cfg_save_time = GameLoader.get_save_property_value(GAME.SAVE_GAME_DIR, "time", GAME.save_slot)
	label_tsavetime_node.text = "Targetted Save Time: " + get_save_time(target_cfg_save_time)
	
	var target_save_last_visited_level : int = GameLoader.get_save_property_value(GAME.SAVE_GAME_DIR, "last_level", GAME.save_slot)
	label_tsavelevel_node.text = "Targetted Save Level: " +  GAME.current_chapter.get_level_name(target_save_last_visited_level)

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

func overwrite_slot(slot_id : int):
	GAME.save_slot = slot_id
	GAME.goto_level(0)
	queue_free()

func submit_and_overwrite_save():
	var save_name : String = lineedit_csavename_node.text
	save_name = save_name.replacen(" ", "_")
	
	if save_name == "":
		save_name = "save" + str(GAME.save_slot)

	if save_folder_path != "":
		DirNavHelper.delete_folder(save_folder_path)

	GameSaver.save_game(GAME.progression, GAME.SAVE_GAME_DIR + "/" + save_name, save_name, GAME.save_slot, GAME.save_data.settings)
	
	var save_slot_path : String = GameLoader.find_save_slot(GAME.SAVE_GAME_DIR, GAME.save_slot)
	DirNavHelper.transfer_dir_content(GAME.SAVED_LEVEL_DIR, save_slot_path)
	
	overwrite_slot(GAME.save_slot)


#### VIRTUALS ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
func _on_menu_option_chose(option) -> void:
	match(option.get_name()):
		"Cancel": cancel()
		"ConfirmAndSave": submit_and_overwrite_save()
