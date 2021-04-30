extends MenuBase
class_name LoadGameMenu

onready var load_slot1_node = $VBoxContainer/VBoxContainer2/Slot1
onready var load_slot2_node = $VBoxContainer/VBoxContainer2/Slot2
onready var load_slot3_node = $VBoxContainer/VBoxContainer2/Slot3

onready var load_save_name_info_label_node= $VBoxContainer/VBoxContainer/LoadSaveName
onready var load_save_date_info_label_node = $VBoxContainer/VBoxContainer/LoadSaveDate
onready var load_save_xion_info_label_node = $VBoxContainer/VBoxContainer/LoadSaveXion
onready var load_save_gear_info_label_node = $VBoxContainer/VBoxContainer/LoadSaveGear

var overwrite_mode : bool = false

var scene_ready : bool = false
var any_button_focused : bool = false

var load_slot_button_nodes_array : Array

var save_directories = DirNavHelper.fetch_dir_content(GAME.SAVE_GAME_DIR, DirNavHelper.DIR_FETCH_MODE.DIR_ONLY)
var saves_name : Array = []

#### ACCESSORS ####

func is_class(value: String): return value == "LoadSaveMenu" or .is_class(value)
func get_class() -> String: return "LoadSaveMenu"

#### BUILT-IN ####

func _ready():
	scene_ready = true
	load_slot_button_nodes_array = [load_slot1_node, load_slot2_node, load_slot3_node]

	for i in range(3):
		var save_name : String = save_directories[i] if i < save_directories.size() else ""
		if save_name == "":
			load_slot_button_nodes_array[i].text = "NO SAVE TO LOAD"
			load_slot_button_nodes_array[i].set_disabled(true)
		else:
			load_slot_button_nodes_array[i].text = save_name

#### LOGIC ####

func update_save_information(slot_id : int):
	if !save_directories.empty():
		if !scene_ready:
			yield(self, "ready")
		
		var slot_path = GameLoader.find_save_slot(GAME.SAVE_GAME_DIR, slot_id)
		
		if slot_id == -1 or slot_path == "":
			$VBoxContainer.visible = false
		else:
			$VBoxContainer.visible = true

			var target_cfg_save_time = GameLoader.get_cfg_property_value(GAME.SAVE_GAME_DIR, "time", slot_id)
			if typeof(target_cfg_save_time) == TYPE_DICTIONARY:
				load_save_name_info_label_node.text = "Name : " + GameLoader.find_save_slot(GAME.SAVE_GAME_DIR, slot_id).split("/")[-1]
				load_save_date_info_label_node.text = "Time : " + str(target_cfg_save_time.get("day")) + "/" + str(target_cfg_save_time.get("month"))  +  "/" + str(target_cfg_save_time.get("year")) + " " + str(target_cfg_save_time.get("hour")) + "h" + str(target_cfg_save_time.get("minute")) + ":" + str(target_cfg_save_time.get("second"))
				load_save_xion_info_label_node.text = "Xion : " + str(GameLoader.get_cfg_property_value(GAME.SAVE_GAME_DIR, "xion", slot_id))
				load_save_gear_info_label_node.text = "Gear : " + str(GameLoader.get_cfg_property_value(GAME.SAVE_GAME_DIR, "gear", slot_id))
	else:
		$VBoxContainer.visible = false



func load_save(slot_id : int):
	var save_path : String = str(GameLoader.load_settings(GAME.SAVE_GAME_DIR, slot_id))

	if save_path != "Null" or save_path != "":
		GAME.goto_world_map()


func overwrite_slot(slot_id : int):
	var chosen_slot_path = GameLoader.find_save_slot(GAME.SAVE_GAME_DIR, slot_id)
	DirNavHelper.delete_folder(chosen_slot_path)
	GAME.save_slot = slot_id
	GAME.goto_level(0)
	queue_free()

#### VIRTUALS #### 



#### INPUTS ####



#### SIGNAL RESPONSES ####

# When a button is aimed (with a mouse for exemple)
func _on_menu_option_focus_changed(button : Button, focus: bool) -> void:
	if button.name == "BackToMenu":
		return
	
	any_button_focused = true
	if focus && choice_sound_node != null:
		choice_sound_node.play()

	var button_index = button.get_index()
	if button_index > save_directories.size():
		return
	
	var target_save_time = GameLoader.get_cfg_property_value(GAME.SAVE_GAME_DIR, "time", button_index + 1)
	if typeof(target_save_time) == TYPE_STRING:
		button_index = -1
	update_save_information(button_index + 1)


func _on_menu_option_chose(option: MenuOptionsBase):
	match(option.get_name()):
		"BackToMenu":
			navigate_sub_menu(MENUS.title_screen_scene.instance())
		_:
			var slot_id = option.get_index() + 1
			if overwrite_mode: overwrite_slot(slot_id)
			else: load_save(slot_id)
