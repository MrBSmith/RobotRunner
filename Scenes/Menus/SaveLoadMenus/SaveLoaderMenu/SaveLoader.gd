extends MenuBase
class_name SaveLoader

onready var load_slot1_node = $HBoxContainer/V_OptContainer/LOAD_1
onready var load_slot2_node = $HBoxContainer/V_OptContainer/LOAD_2
onready var load_slot3_node = $HBoxContainer/V_OptContainer/LOAD_3

onready var load_save_name_info_label_node= $VBoxContainer/LoadSaveName
onready var load_save_date_info_label_node = $VBoxContainer/LoadSaveDate
onready var load_save_xion_info_label_node = $VBoxContainer/LoadSaveXion
onready var load_save_gear_info_label_node = $VBoxContainer/LoadSaveGear

var scene_ready : bool = false
var any_button_focused : bool = false

var load_slot_button_nodes_array : Array

var save_directories = GameSaver.find_all_saves_directories()
var saves_name : Array = []

#### ACCESSORS ####

func is_class(value: String):
	return value == "" or .is_class(value)

func get_class() -> String:
	return ""

#### BUILT-IN ####

func _ready():
	scene_ready = true
	load_slot_button_nodes_array = [load_slot1_node, load_slot2_node, load_slot3_node]

	for i in range(0,3):
		var save_name : String = GameSaver.get_save_cfg_property_value_by_name_and_cfgid("save_name",i+1)
		if save_name == "":
			load_slot_button_nodes_array[i].text = "NO SAVE TO LOAD"
		else:
			load_slot_button_nodes_array[i].text = save_name

#### LOGIC ####

func update_save_information(slot_id : int):
	if !save_directories.empty():
		if !scene_ready:
			yield(self, "ready")
		if slot_id == -1:
			$VBoxContainer.visible = false
		else:
			$VBoxContainer.visible = true

			var target_cfg_save_time = GameSaver.get_save_cfg_property_value_by_name_and_cfgid("time",slot_id)
			if typeof(target_cfg_save_time) == TYPE_DICTIONARY:
				load_save_name_info_label_node.text = "Name : " + GameSaver.find_corresponding_save_file(save_directories, slot_id)
				load_save_date_info_label_node.text = "Time : " + str(target_cfg_save_time.get("day")) + "/" + str(target_cfg_save_time.get("month"))  +  "/" + str(target_cfg_save_time.get("year")) + " " + str(target_cfg_save_time.get("hour")) + "h" + str(target_cfg_save_time.get("minute")) + ":" + str(target_cfg_save_time.get("second"))
				load_save_xion_info_label_node.text = "Xion : " + str(GameSaver.get_save_cfg_property_value_by_name_and_cfgid("xion", slot_id))
				load_save_gear_info_label_node.text = "Gear : " + str(GameSaver.get_save_cfg_property_value_by_name_and_cfgid("gear", slot_id))
	else:
		$VBoxContainer.visible = false

func load_save(slot_id : int):
	var save_path : String = str(GameSaver.load_settings(slot_id))
	var tscn_path : String = save_path + "SavedLevel.tscn"

	if save_path != "Null" or save_path != "":
		var file = File.new()
		var _err = file.open(tscn_path, File.READ)

		if _err != OK:
			return

		_err = get_tree().change_scene(tscn_path)
		queue_free()

#### VIRTUALS ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

# When a button is aimed (with a mouse for exemple)
func _on_menu_option_focus_changed(_button : Button, focus: bool) -> void:
	any_button_focused = true
	if focus && choice_sound_node != null:
		choice_sound_node.play()

	var buttonindex = _button.get_index()+1
	var target_save_time = GameSaver.get_save_cfg_property_value_by_name_and_cfgid("time", buttonindex)
	if typeof(target_save_time) == TYPE_STRING:
		buttonindex = -1
	update_save_information(buttonindex)

func _on_menu_option_chose(option: MenuOptionsBase):
	match(option.get_name()):
		"BackToMenu":
			navigate_sub_menu(MENUS.title_screen_scene.instance())
		_:
			load_save(option.get_index()+1)
