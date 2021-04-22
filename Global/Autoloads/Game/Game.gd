extends Node2D

onready var gameover_timer_node = $GameoverTimer
onready var transition_timer_node = $TransitionTimer
onready var progression = $Progression

export var debug : bool = false

export var transition_time : float = 1.0

const SAVEGAME_DIR : String = "res://saves"
const SAVEDLEVEL_DIR : String = "res://Scenes/Levels/SavedLevel"
const SAVEDFILE_DEFAULT_NAME : String = "save"

const TILE_SIZE := Vector2(24, 24)
const JUMP_MAX_DIST := Vector2(6, 2)

var window_width = ProjectSettings.get_setting("display/window/size/width")
var window_height = ProjectSettings.get_setting("display/window/size/height")
var window_size = Vector2(window_width, window_height)

var chapters_array = []
var current_chapter : Resource = null

var player1 = preload("res://Scenes/Actor/Players/MrCold/MrCold.tscn")
var player2 = preload("res://Scenes/Actor/Players/MrStonks/MrStonks.tscn")

var level_array : Array
var last_level_name : String

var current_seed : int = 0 setget _set_current_seed, get_current_seed
var solo_mode : bool = false setget set_solo_mode, get_solo_mode

var music_bus_id = AudioServer.get_bus_index("Music")
var sound_bus_id = AudioServer.get_bus_index("Sounds")

var _config_file = ConfigFile.new()

#var save_thread : Thread = null

var _settings ={
		"system":{
			"slot_id": 1,
			"save_name": "none",
			"time": "unknown"
		},
		"audio":{
			"music": AudioServer.get_bus_volume_db(music_bus_id),
			"sounds": AudioServer.get_bus_volume_db(sound_bus_id)
		},
		"controls":{
			"jump_player1": InputMap.get_action_list("jump_player1")[0].scancode,
			"move_left_player1": InputMap.get_action_list("move_left_player1")[0].scancode,
			"move_right_player1": InputMap.get_action_list("move_right_player1")[0].scancode,
			"teleport_player1": InputMap.get_action_list("teleport_player1")[0].scancode,
			"action_player1": InputMap.get_action_list("action_player1")[0].scancode,
				
			"jump_player2": InputMap.get_action_list("jump_player2")[0].scancode,
			"move_left_player2": InputMap.get_action_list("move_left_player2")[0].scancode,
			"move_right_player2": InputMap.get_action_list("move_right_player2")[0].scancode,
			"teleport_player2": InputMap.get_action_list("teleport_player2")[0].scancode,
			"action_player2": InputMap.get_action_list("action_player2")[0].scancode,
				
			"game_restart": InputMap.get_action_list("game_restart")[0].scancode,
			"HUD_switch_state": InputMap.get_action_list("HUD_switch_state")[0].scancode,
			"display_console": InputMap.get_action_list("display_console")[0].scancode
		},
		"gameplay":{
			"level_id": -1,
			"checkpoint_reached": -1,
			"xion": 0,
			"gear": 0
		}
	}


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
	var _err = gameover_timer_node.connect("timeout",self, "on_gameover_timer_timeout")
	_err = transition_timer_node.connect("timeout",self, "on_transition_timer_timeout")
	_err = EVENTS.connect("level_ready", self, "on_level_ready")
	_err = EVENTS.connect("level_finished", self, "on_level_finished")
	_err = EVENTS.connect("seed_change_query", self, "on_seed_change_query")

	GameSaver.create_dirs(SAVEGAME_DIR, []) #Create saves directory at root
	GameSaver.settings_update_keys(_settings)

	# Generate the chapters
	ChapterGenerator.create_chapters(ChapterGenerator.chapter_dir_path, chapters_array)
	new_chapter() # Set the current chapter to be the first one


#### LOGIC ####

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
		level_to_load_path = find_level_path_in_chapter_array(last_level_name)
	
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
		LevelSaver.build_level_from_loaded_properties(SAVEDLEVEL_DIR, level)


# Change scene to the next level scene
# If the last level was not in the list, set the progression to -1
# Which means the last level will be launched again
func goto_next_level():
	var next_level : PackedScene = null
	var next_level_id : int = 0

	progression.set_checkpoint(-1)

	if last_level_name == "":
		next_level = current_chapter.load_level(0)
	else:
		next_level = current_chapter.load_next_level(last_level_name)
		next_level_id = current_chapter.find_level_id(last_level_name) + 1

	var next_level_name = current_chapter.get_level_name(next_level_id)
	LevelSaver.delete_level_temp_saves(SAVEDLEVEL_DIR, next_level_name)

	var _err = get_tree().change_scene_to(next_level)



func goto_level(level_index : int):
	var level : PackedScene = null

	progression.set_checkpoint(-1)

	level = current_chapter.load_level(level_index)
	var level_name = current_chapter.get_level_name(level_index)
	LevelSaver.delete_level_temp_saves(SAVEDLEVEL_DIR, level_name)

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


func find_level_path_in_chapter_array(level_name: String) -> String:
	for chapter in chapters_array:
		var level_path = chapter.find_level_path(level_name) 
		if level_path != "":
			return level_path
	return ""



# Triggers the timer before the gameover is triggered
# Called when a player die
func gameover():
	gameover_timer_node.start()

	var current_scene = get_tree().get_current_scene()
	if !current_scene is Level:
		return

	current_scene.set_process(false)


### TRY TO RELOCATE THIS FUNCTION IN GAME_SAVER ###

# Find the saved level with the corresponding name, and returns its path
# Returns "" if nothing was found
func find_saved_level_path(dir_path: String, level_name: String) -> String:
	var dir = Directory.new()
	if dir.open(dir_path) == OK:
		dir.list_dir_begin(true)
		var current_file_name : String = dir.get_next()

		while current_file_name != "":
			if dir.current_is_dir():
				continue
			else:
				if level_name.is_subsequence_of(current_file_name):
					return dir_path + current_file_name
				else:
					current_file_name = dir.get_next()
	return ""


func fade_in():
	$Tween.interpolate_property($CanvasLayer/ColorRect, "modulate",
		Color.black, Color.transparent, transition_time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func fade_out():
	$Tween.interpolate_property($CanvasLayer/ColorRect, "modulate",
		Color.transparent, Color.black, transition_time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

	MUSIC.fade_out()


func set_screen_fade_visible(value: bool):
	$CanvasLayer/ColorRect.set_visible(value)


# Check if the current level index is the right one when a new level is ready
# Usefull when testing a level standalone to keep track of the progression
func update_current_level_index(level : Level):
	var level_name = level.get_name()
	var level_index = current_chapter.find_level_id(level_name)
	GAME.progression.set_level(level_index)


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

#  Change scene to go to the gameover scene after the timer has finished
func on_gameover_timer_timeout():
	gameover_timer_node.stop()
	var _err = get_tree().change_scene_to(MENUS.game_over_scene)


# Called when a level is finished: wait for the transition to be finished
func on_level_finished(_level : Level):
	fade_out()
	transition_timer_node.start()


# When the transition is finished, go to the next level
func on_transition_timer_timeout():
	goto_next_level()


# Called when the level is ready, correct
func on_level_ready(level : Level):
	last_level_name = level.get_name()
	
	update_current_level_index(level)
	fade_in()


# When a player reach a checkpoint
func on_checkpoint_reached(level: Level, checkpoint_id: int):
	if checkpoint_id + 1 > GAME.progression.checkpoint:
		progression.checkpoint = checkpoint_id + 1
	
	LevelSaver.save_level_properties_as_json(SAVEDLEVEL_DIR, level)


func on_seed_change_query(new_seed: int):
	_set_current_seed(new_seed)
