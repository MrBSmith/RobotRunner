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
var last_level_name : String

#### BUILT-IN ####

func _ready():
	var _err = gameover_timer_node.connect("timeout",self, "on_gameover_timer_timeout")
	_err = transition_timer_node.connect("timeout",self, "on_transition_timer_timeout")


#### LOGIC ####

func new_chapter():
	progression.add_to_chapter(1)
	current_chapter = chapters_array[progression.get_chapter()]


# Reload the last level played
# If from_start is true, reload the native level scene, else load the saved level scene
func goto_last_level(from_start: bool = false):
	var level_to_load_path : String = ""
	var level_scene : PackedScene
	var level_node
	
	if last_level_name == "":
		print("GAME.goto_last_level needs a previous_level. previous level is currently null")
		return
	
	level_to_load_path = find_saved_level_path("res://Scenes/Levels/SavedLevel/tscn/", last_level_name)
	
	if level_to_load_path != "" or from_start:
		level_scene = load(level_to_load_path)
		level_node = level_scene.instance()
		level_node.is_loaded_from_save = true
	else:
		level_scene = current_chapter.load_level(0)
		level_node = level_scene.instance()
	
	update_collectable_progression()
	
	var _err = get_tree().get_current_scene().queue_free()
	_err = get_tree().get_root().add_child(level_node)
	get_tree().set_current_scene(level_node)


# Change scene to the next level scene
# If the last level was not in the list, set the progression to -1
# Which means the last level will be launched again
func goto_next_level():
	var next_level : PackedScene = null
	
	progression.set_checkpoint(-1)
	update_collectable_progression()
	
	if last_level_name == "":
		next_level = current_chapter.load_level(0)
	else:
		next_level = current_chapter.load_next_level(last_level_name)
	
	var _err = get_tree().change_scene_to(next_level)


# Triggers the timer before the gameover is triggered
# Called when a player die
func gameover():
	gameover_timer_node.start()
	
	var current_scene = get_tree().get_current_scene()
	if !current_scene is Level:
		return
	
	current_scene.set_process(false)


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
# Usefull when testing a level standalone to keep track of the progression
func update_current_level_index(level : Level):
	var level_name = level.get_name()
	var level_index = current_chapter.find_level_id(level_name)
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

func deserialize_level_properties(file_path : String):
	var level_properties  : String = ""
	var parsed_data : Dictionary = {}
	var load_file = File.new()
	
	if !load_file.file_exists(file_path):
		return
	
	load_file.open(file_path, load_file.READ)
	level_properties = load_file.get_as_text()
	parsed_data = parse_json(level_properties)
	load_file.close()

	return parsed_data

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
func on_level_ready(level : Level):
	last_level_name = level.get_name()
	if progression.level == 0:
		update_current_level_index(level)
	
	if(level.is_loaded_from_save == false):
		$LevelSaver.save_level_properties_as_json(level.get_name(), level)
	else:
		GAME.get_node("LevelSaver").load_level_properties_from_json(level.is_loaded_from_save, level.get_name())
		
	fade_in()


# When a player reach a checkpoint
func on_checkpoint_reached(level: Level, checkpoint_id: int):
	if checkpoint_id + 1 > GAME.progression.checkpoint:
		GAME.progression.checkpoint = checkpoint_id + 1
	
	GAME.progression.set_main_xion(SCORE.xion)
	GAME.progression.set_main_materials(SCORE.materials)
	$LevelSaver.save_level(level, progression.main_stored_objects)
