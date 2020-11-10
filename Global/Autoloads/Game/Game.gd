extends Node2D

onready var gameover_timer_node = $GameoverTimer
onready var transition_timer_node = $TransitionTimer

export var debug : bool = false
export var progression : Resource

export var transition_time : float = 1.0

var chapters_array = []
var current_chapter : Resource = null

var player1 = preload("res://Scenes/Actor/Players/RobotIce/RobotIce.tscn")
var player2 = preload("res://Scenes/Actor/Players/RobotHammer/RobotHammer.tscn")

var level_array : Array
var last_level_path : String

#### BUILT-IN ####

func _ready():
	var _err = gameover_timer_node.connect("timeout",self, "on_gameover_timer_timeout")
	_err = transition_timer_node.connect("timeout",self, "on_transition_timer_timeout")


#### LOGIC ####

func new_chapter():
	progression.add_to_chapter(1)
	current_chapter = chapters_array[progression.get_chapter()]


func goto_last_level(previous_level: Level, from_start: bool = false):
	var level_to_load_path : String = ""
	var level_scene : PackedScene
	
	if previous_level == null:
		print("GAME.goto_last_level needs a previous_level. previous level is currently null")
		return
	
	var previous_level_name : String = previous_level.get_name()
	
	level_to_load_path = find_saved_level_path("res://Scenes/Levels/SavedLevel/", previous_level_name)
	
	if level_to_load_path != "" or from_start:
		level_scene = load(level_to_load_path)
	else:
		level_scene = current_chapter.load_level(0)
	
	update_collectable_progression()
	
	var _err = get_tree().change_scene_to(level_scene)


# Change scene to the next level scene
# If the last level was not in the list, set the progression to -1
# Which means the last level will be launched again
func goto_next_level(last_level : Level = null):
	var level_scene : PackedScene = null
	
	#### THE CASE WHERE THE LEVEL IS THE LAST OF THE CHAPTER ISN'T TAKEN CARE OF #### 
	progression.add_to_level(1)
	progression.set_checkpoint(0)
	update_collectable_progression()
	
	if debug:
		print("progression.level: " + String(progression.get_level()))
	
	if last_level == null:
		level_scene = current_chapter.load_level(0)
	else:
		level_scene = current_chapter.load_level(progression.get_level())
	
	var _err = get_tree().change_scene_to(level_scene)



# Triggers the timer before the gameover is triggered
# Called when a player die
func gameover():
	gameover_timer_node.start()
	get_tree().get_current_scene().set_process(false)


# Move the camera to the given position
func move_camera_to(dest: Vector2, average_w_players: bool = false, speed : float = -1.0, duration : float = 0.0):
	var camera_node = get_tree().get_current_scene().find_node("Camera")
	if camera_node != null:
		var func_call_array : Array = ["move_to", dest, average_w_players, speed, duration]
		camera_node.stack_instruction(func_call_array)


# Give zoom the camera to the destination wanted zoom
func zoom_camera_to(dest_zoom: Vector2, zoom_speed : float = 1.0):
	var camera_node = get_tree().get_current_scene().find_node("Camera")
	if camera_node != null:
		camera_node.start_zooming(dest_zoom, zoom_speed)


# Set the camera in the follow state
func set_camera_on_follow():
	var camera_node = get_tree().get_current_scene().find_node("Camera")
	camera_node.set_state("Follow")


# Return the index of a given string in a given array
# Return -1 if the string wasn't found
func find_string(string_array: PoolStringArray, target_string : String):
	var index = 0
	for string in string_array:
		if target_string.is_subsequence_of(string) or target_string == string:
			return index
		else:
			index += 1
	return -1


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
					print(current_file_name)
					return current_file_name
	return ""


# Save the players' level progression into the main game progression
func update_collectable_progression():
	progression.set_main_xion(SCORE.get_xion())
	progression.set_main_materials(SCORE.get_materials())


# Update the HUD when a player retry or go to the next level
func update_hud_collectable_progression():
	SCORE.set_xion(progression.get_main_xion())
	SCORE.set_materials(progression.get_main_materials())


# Discard progression and get the lastest data
func discard_collectable_progression():
	pass


# Check if the current level index is the right one when a new level is ready
# Usefull when testing a level standalone to keep track of the pro
func update_current_level_index(level):
	var level_filename = level.filename
	var level_index = find_string(current_chapter.levels_scenes_array, level_filename)
	GAME.progression.set_level(level_index)


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


#### SIGNAL RESPONSES ####

#  Change scene to go to the gameover scene after the timer has finished
func on_gameover_timer_timeout():
	gameover_timer_node.stop()
	var _err = get_tree().change_scene_to(MENUS.game_over_scene)


# Called when a level is finished: wait for the transition to be finished
func on_level_finished():
	fade_out()
	transition_timer_node.start()


# When the transition is finished, go to the next level
func on_transition_timer_timeout():
	goto_next_level()


# Called when the level is ready, correct
func on_level_ready(level):
	last_level_path = level.filename
	if progression.level == 0:
		update_current_level_index(level)

	$LevelSaver.save_level(level, progression.main_stored_objects)
	fade_in()


# When a player reach a checkpoint
func on_checkpoint_reached(level):
	GAME.progression.checkpoint += 1
	GAME.progression.set_main_xion(SCORE.xion)
	GAME.progression.set_main_materials(SCORE.materials)
	$LevelSaver.save_level(level, progression.main_stored_objects)
