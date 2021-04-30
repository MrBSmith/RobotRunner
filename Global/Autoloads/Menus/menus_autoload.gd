extends Node

onready var game_over_scene = preload("res://Scenes/Menus/GameOverScene/GameOver.tscn")
onready var pause_menu_scene = preload("res://Scenes/Menus/PauseMenu/PauseMenu.tscn")
onready var option_menu_scene = preload("res://Scenes/Menus/OptionsMenu/OptionsMenu.tscn")
onready var title_screen_scene = preload("res://Scenes/Menus/ScreenTitle/ScreenTitle.tscn")
onready var sounds_menu_scene = preload("res://Scenes/Menus/OptionsMenu/SoundMenu/SoundMenu.tscn")
onready var controls_menu_scene = preload("res://Scenes/Menus/OptionsMenu/Controls/InputMenu.tscn")
onready var saveloader_menu_scene = preload("res://Scenes/Menus/SaveLoadMenus/LoadGameMenu/LoadGameMenu.tscn")
onready var slotsaver_menu_scene = preload("res://Scenes/Menus/SaveLoadMenus/SlotSaverMenu/SlotSaverMenu.tscn")
onready var saveconfirm_menu_scene = preload("res://Scenes/Menus/SaveLoadMenus/SaveConfirmMenu/SaveConfirmMenu.tscn")

# Triggers the game over scene
func gameover():
	var _err = get_tree().change_scene_to(game_over_scene)
