extends MenuBase
class_name LoadGameMenu

onready var menu_option_base_scene = preload("res://BabaGodotLib/UI/Menu/OptionButtons/MenuOptionBase.tscn")

onready var load_save_name_info_label_node= $VBoxContainer/VBoxContainer/LoadSaveName
onready var load_save_date_info_label_node = $VBoxContainer/VBoxContainer/LoadSaveDate
onready var load_save_xion_info_label_node = $VBoxContainer/VBoxContainer/LoadSaveXion
onready var load_save_gear_info_label_node = $VBoxContainer/VBoxContainer/LoadSaveGear

var overwrite_mode : bool = false

var scene_ready : bool = false
var any_button_focused : bool = false

var save_directories = DirNavHelper.fetch_dir_content(GAME.SAVE_GAME_DIR, DirNavHelper.DIR_FETCH_MODE.DIR_ONLY)
var saves_name : Array = []

#### ACCESSORS ####

func is_class(value: String): return value == "LoadSaveMenu" or .is_class(value)
func get_class() -> String: return "LoadSaveMenu"

#### BUILT-IN ####

func _ready():
	scene_ready = true

	for i in range(GAME.NB_SAVE_SLOT):
		var slot_option = menu_option_base_scene.instance()
		opt_container.call_deferred("add_child",  slot_option)
		var save_path : String = GameLoader.find_save_slot(GAME.SAVE_GAME_DIR, i + 1)
		var save_name = GameLoader.get_save_property_value(GAME.SAVE_GAME_DIR, "save_name", i + 1) if save_path != "" else ""
		if save_name == "":
			slot_option.text = "NO SAVE TO LOAD"
			slot_option.set_disabled(true)
		else:
			slot_option.text = save_name
	
	var back_to_menu_option = menu_option_base_scene.instance()
	back_to_menu_option.text = "Back To Menu"
	back_to_menu_option.name = "BackToMenu"
	opt_container.call_deferred("add_child", back_to_menu_option)
	
	yield(back_to_menu_option, "ready")
	connect_menu_options(opt_container)

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

			var target_cfg_save_time = GameLoader.get_save_property_value(GAME.SAVE_GAME_DIR, "time", slot_id)
			if typeof(target_cfg_save_time) == TYPE_DICTIONARY:
				load_save_name_info_label_node.text = "Name : " + GameLoader.find_save_slot(GAME.SAVE_GAME_DIR, slot_id).split("/")[-1]
				load_save_date_info_label_node.text = "Time : " + str(target_cfg_save_time.get("day")) + "/" + str(target_cfg_save_time.get("month"))  +  "/" + str(target_cfg_save_time.get("year")) + " " + str(target_cfg_save_time.get("hour")) + "h" + str(target_cfg_save_time.get("minute")) + ":" + str(target_cfg_save_time.get("second"))
				load_save_xion_info_label_node.text = "Xion : " + str(GameLoader.get_save_property_value(GAME.SAVE_GAME_DIR, "xion", slot_id))
				load_save_gear_info_label_node.text = "Gear : " + str(GameLoader.get_save_property_value(GAME.SAVE_GAME_DIR, "gear", slot_id))
	else:
		$VBoxContainer.visible = false



func load_save(slot_id : int):
	GAME.load_slot(slot_id)
	GAME.goto_world_map()
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
	
	var target_save_time = GameLoader.get_save_property_value(GAME.SAVE_GAME_DIR, "time", button_index + 1)
	if typeof(target_save_time) == TYPE_STRING:
		button_index = -1
	update_save_information(button_index + 1)


func _on_menu_option_chose(option: MenuOptionsBase):
	match(option.get_name()):
		"BackToMenu":
			navigate_sub_menu(MENUS.menu_dict["ScreenTitle"].instance())
		_:
			var slot_id = option.get_index() + 1
			GAME.save_slot = slot_id
#			if overwrite_mode: overwrite_slot(slot_id)
			if overwrite_mode: navigate_sub_menu(MENUS.menu_dict["SaveConfirmMenu"].instance())
			else: load_save(slot_id)
