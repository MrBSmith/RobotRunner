extends MenuBase
class_name ScreenTitleMenu

onready var save_loader_scene = preload("res://Scenes/Menus/SaveLoadMenus/LoadGameMenu/LoadGameMenu.tscn")
onready var infinite_level_scene = preload("res://Scenes/Levels/InfiniteMode/InfiniteLevel.tscn")
onready var seed_field = opt_container.get_node("InfiniteMode/SeedField")

#### ACCESSORS ####

func is_class(value: String): return value == "ScreenTitleMenu" or .is_class(value)
func get_class() -> String: return "ScreenTitleMenu"


#### BUILT-IN ####


func _ready() -> void:
	if DirNavHelper.is_dir_empty(GAME.SAVE_GAME_DIR):
		opt_container.get_node("Continue").queue_free()
		opt_container.get_node("LoadGame").queue_free()



#### LOGIC ####



#### VIRTUALS ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_menu_option_chose(option: MenuOptionsBase):
	var _err = null
	var option_name = option.name
	
	match(option_name):
		"Continue":
			_err = GameLoader.load_settings(GAME.SAVE_GAME_DIR, 1)
			GAME.goto_world_map()
		"NewGame":
			EVENTS.emit_signal("new_game")
			queue_free()
		"LoadGame": 
			_err = navigate_sub_menu(MENUS.saveloader_menu_scene.instance())
		"InfiniteMode":
			_err = get_tree().change_scene_to(infinite_level_scene)
		"Quit":
			get_tree().quit()


func _on_menu_option_focus_changed(button : Button, focus: bool):
	if focus && seed_field != null:
		seed_field.set_visible(button.name == "InfiniteMode")
	._on_menu_option_focus_changed(button, focus)
