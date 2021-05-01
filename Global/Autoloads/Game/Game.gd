extends Node2D

onready var progression : Progression = $Progression
onready var save_data : SaveData = $SaveData

export var debug : bool = false

const SAVE_GAME_DIR : String = "res://saves"
const SAVED_LEVEL_DIR : String = "res://Scenes/Levels/SavedLevel"
const SAVEDFILE_DEFAULT_NAME : String = "save"

const TILE_SIZE := Vector2(24, 24)
const JUMP_MAX_DIST := Vector2(6, 2)

const NB_SAVE_SLOT : int = 3

var window_width = ProjectSettings.get_setting("display/window/size/width")
var window_height = ProjectSettings.get_setting("display/window/size/height")
var window_size = Vector2(window_width, window_height)
var chapters_array = []
var current_chapter : Resource = null

var player1 = preload("res://Scenes/Actor/Players/MrCold/MrCold.tscn")
var player2 = preload("res://Scenes/Actor/Players/MrStonks/MrStonks.tscn")

var world_map_scene = preload("res://Scenes/WorldMap/XL_WorldMap.tscn")

var level_array : Array
var last_level_name : String

var current_seed : int = 0 setget _set_current_seed, get_current_seed
var solo_mode : bool = false setget set_solo_mode, get_solo_mode

var save_slot : int = 0

var config_file = ConfigFile.new()




#### ACCESSORS ####

func _set_current_seed(value: int):
	current_seed = value
	seed(current_seed)

func get_current_seed() -> int: return current_seed

func set_solo_mode(value: bool):
	solo_mode = value
	if !solo_mode:
		for player in get_tree().get_nodes_in_group("Players"):
			player.set_active(true)

func get_solo_mode() -> bool: return solo_mode

#### BUILT-IN ####

func _ready():
	var _err = EVENTS.connect("level_ready", self, "_on_level_ready")
	_err = EVENTS.connect("level_finished", self, "_on_level_finished")
	_err = EVENTS.connect("seed_change_query", self, "_on_seed_change_query")
	_err = EVENTS.connect("new_game", self, "_on_new_game")

	# Generate the chapters
	ChapterGenerator.create_chapters(ChapterGenerator.chapter_dir_path, chapters_array)
	new_chapter() # Set the current chapter to be the first one


#### SCENE CHANGE ####

func new_chapter():
	progression.add_to_chapter(1)
	current_chapter = chapters_array[progression.get_chapter()]


# Try to find a save of the level to load it, if no save exits, reload the native level
func goto_last_level():
	if last_level_name == "":
		print("GAME.goto_last_level needs a previous_level. previous level is currently null")
		return

	var loaded_from_save : bool = false
	var level_scene : PackedScene
	var level_to_load_path : String = current_chapter.find_level_path(last_level_name)
	
	if level_to_load_path == "":
		level_to_load_path = find_level_in_chapter_array(last_level_name)
	
	# If no save of the current level exists, reload the same scene
	if level_to_load_path == "":
		print_debug("No level with the name " + last_level_name + " has been found in any chapter of the game")
	else:
		level_scene = load(level_to_load_path)
		loaded_from_save = true
	
	var __ = get_tree().change_scene_to(level_scene)

	if loaded_from_save:
		yield(EVENTS, "level_entered_tree")
		var level : Level = get_tree().get_current_scene()
		level.is_loaded_from_save = loaded_from_save
		LevelLoader.build_level_from_loaded_properties(SAVED_LEVEL_DIR, level)


# Change scene to the next level scene
# If the last level was not in the list, set the progression to -1
# Which means the last level will be launched again
func goto_next_level():
	var next_level : PackedScene = null
	progression.set_checkpoint(-1)
	
	if last_level_name == "":
		next_level = current_chapter.load_level(0)
	else:
		next_level = current_chapter.load_next_level(last_level_name)
	
	var _err = get_tree().change_scene_to(next_level)


# Go to the level designated by the given level_index in the given chapter, designated by its id
# By default, the chapter is the current one
func goto_level(level_index : int, chapter_id: int = progression.get_chapter()):
	var level : PackedScene = null

	progression.set_checkpoint(-1)

	level = chapters_array[chapter_id].load_level(level_index)
	var level_name = current_chapter.get_level_name(level_index)
	LevelSaver.delete_level_temp_saves(SAVED_LEVEL_DIR, level_name)

	var _err = get_tree().change_scene_to(level)


func goto_level_by_path(level_scene_path: String):
	var level_chapter_id : int = -1
	var level_id : int = -1
	
	for i in range(chapters_array.size()):
		var chapter = chapters_array[i]
		level_id = chapter.get_level_id_by_path(level_scene_path)
		if level_id != -1:
			level_chapter_id = i
			break
	
	if level_chapter_id != -1:
		current_chapter = chapters_array[level_chapter_id]
	else:
		print_debug("The given path: " + level_scene_path + " can't be found in any chapter")
	
	goto_level(level_id)


func goto_world_map() -> void:
	var _err = get_tree().change_scene_to(world_map_scene)


# Triggers the timer before the gameover is triggered
# Called when a player die
func gameover():
	var current_scene = get_tree().get_current_scene()
	if !current_scene is Level:
		return
	
	current_scene.set_process(false)
	add_child(MENUS.menu_dict["GameOver"].instance())


#### LOGIC ####

func find_level_in_chapter_array(level_name: String) -> String:
	for chapter in chapters_array:
		var level_path = chapter.find_level_path(level_name) 
		if level_path != "":
			return level_path
	return ""


# Check if the current level index is the right one when a new level is ready
# Usefull when testing a level standalone to keep track of the progression
func update_current_level_index(level : Level):
	var level_name = level.get_name()
	var level_index = current_chapter.find_level_id(level_name)
	GAME.progression.set_last_level_id(level_index)


func load_slot(slot_id: int):
	GameLoader.load_save_slot(SAVE_GAME_DIR, slot_id, progression)
	save_slot = GameLoader.get_cfg_property_value(SAVE_GAME_DIR, "slot_id", slot_id)


#### INPUTS ####

# Manage the robot switching in solo mode
func _input(_event):
	if !solo_mode:
		return

	var players_array = get_tree().get_nodes_in_group("Players")
	var target : int = -1

	if Input.is_action_just_pressed("both_chara"):
		target = 0
	elif Input.is_action_just_pressed("chara1"):
		target = 1
	elif Input.is_action_just_pressed("chara2"):
		target = 2
	else:
		return

	for player in players_array:
		# In case the player wants every robots active
		if target == 0:
			player.set_active(true)
			continue

		# In case the player wants one robot active only,
		# set it to active and every other one to inactive
		var id = player.get_player_id()
		player.set_active(id == target)


#### SIGNAL RESPONSES ####


# Called when a level is finished: wait for the transition to be finished
func _on_level_finished(level : Level):
	progression.append_visited_level(level)
	GameSaver.save_game_in_slot(progression, SAVE_GAME_DIR, save_slot, save_data.settings)
	goto_world_map()


# Called when the level is ready, correct
func _on_level_ready(level : Level):
	last_level_name = level.get_name()
	update_current_level_index(level)


# When a player reach a checkpoint
func _on_checkpoint_reached(level: Level, checkpoint_id: int):
	if checkpoint_id + 1 > GAME.progression.checkpoint:
		progression.checkpoint = checkpoint_id + 1
	
	LevelSaver.save_level_properties_as_json(save_data.level_property_to_serialize, SAVED_LEVEL_DIR, level)


func _on_seed_change_query(new_seed: int):
	_set_current_seed(new_seed)


func _on_new_game():
	goto_level(0)
	save_slot = GameLoader.find_first_slot_available(SAVED_LEVEL_DIR, NB_SAVE_SLOT)
