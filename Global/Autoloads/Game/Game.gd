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

var stored_objects_array : Array

var objects_datatype_storage = {
	'BreakableObjectBase': [],
	'Checkpoint': ['active'],
	'Event': [],
	'DoorButton':['is_push'],
	'Door':['is_open']
}

#### BUILT-IN ####

func _ready():
	var _err = gameover_timer_node.connect("timeout",self, "on_gameover_timer_timeout")
	_err = transition_timer_node.connect("timeout",self, "on_transition_timer_timeout")


#### LOGIC ####

func new_chapter():
	progression.add_to_chapter(1)
	current_chapter = chapters_array[progression.get_chapter()]


func goto_level(index : int = 0):

	### IMPORTANT : TO BE MODIFIED AND CLEANED

	#Handling players' progression => Xion ; Materials
	update_collectable_progression()

	if index == -1:
		goto_last_level()
	else:
		var level = current_chapter.load_level(index)
		var _err = get_tree().change_scene_to(level)


func goto_last_level():
	### IMPORTANT : TO BE MODIFIED AND CLEANED

	var level_to_load = load_level('res://Scenes/Levels/SavedLevel/saved_level.tscn')

	#Handling players' progression => Xion ; Materials
	update_collectable_progression()
	get_tree().current_scene.queue_free()

	if(level_to_load == null):
		var last_level = load(last_level_path)
		var _err = get_tree().change_scene_to(last_level)
	else:
		var _err = get_tree().change_scene_to(level_to_load)


# Change scene to the next level scene
# If the last level was not in the list, set the progression to -1
# Which means the last level will be launched again
func goto_next_level():
	var last_level_index = find_string(current_chapter.levels_scenes_array, last_level_path)
	#Handling players' progression => Levels
	progression.add_to_level(1)

	if debug:
		print("progression.level: " + String(progression.get_level()))
	progression.set_checkpoint(0)

	if last_level_index == -1:
		goto_last_level()
	else:
		goto_level(progression.get_level())

func save_level(level : Node2D):
	var saved_level = PackedScene.new()
	saved_level.pack(get_tree().get_current_scene())
	ResourceSaver.save("res://Scenes/Levels/SavedLevel/saved_level.tscn", saved_level)
	progression.saved_level = saved_level

func load_level(level_path : String) -> PackedScene:
	var level_to_load = load(level_path)
	return level_to_load

# Triggers the timer before the gameover is triggered
# Called when a player die
func gameover():
	gameover_timer_node.start()
	get_tree().get_current_scene().set_process(false)


#  Change scene to go to the gameover scene after the timer has finished
func on_gameover_timer_timeout():
	gameover_timer_node.stop()
	var _err = get_tree().change_scene_to(MENUS.game_over_scene)


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

	# XION AND MATERIALS METODS HANDLERS
# Save the players' <level>progression into the main game progression
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

#Load the current level state
func load_current_level_state(level, array : Array):
	array.clear()
	get_children_of_node([level.get_node('InteractivesObjects'), level.get_node('Events')], array)
#	if(debug):
#		print_weakref(array)

# Get every children of a node
func get_children_of_node(nodes_to_scan_array : Array, array_to_fill : Array):
	var classes_to_scan_array = objects_datatype_storage.keys()
	for node in nodes_to_scan_array:
		for child in node.get_children():
			#print(child.name)
			for node_class in classes_to_scan_array:
				if child.is_class(node_class):
#					if(debug):
#						print("- "+child.get_name()) # DEBUG PURPOSE
					var object_properties = get_object_properties(child, node_class)
					var properties_per_object = {child.name: object_properties}
					array_to_fill.append(properties_per_object)
					continue
			if child.get_child_count() != 0:
#				if(debug):
#					print("["+child.get_name()+"]") # DEBUG PURPOSE
				get_children_of_node([child], array_to_fill)

func get_object_properties(object : Object, classname : String) -> Dictionary:
	var property_list : Array = objects_datatype_storage[classname]
	var property_data_dict : Dictionary = {}
	for property in property_list:
		if(property in object):
			property_data_dict[property] = object.get(property)
		else:
			print("Property : " + property + " could not be found in " + object.name)

	return property_data_dict

#func print_weakref(array : Array):
#	for weakref_ref in array:
#		if(weakref_ref.get_ref() != null):
#			print('Weakref object : ', weakref_ref.get_ref().name)

#get_property_list() const
func print_properties(objs : Array, prop : String):
	for obj in objs:
		var tmpObj = obj.get_ref()
		if(tmpObj != null):
			if(prop in tmpObj):
				print(tmpObj.get(prop))

#### SIGNAL RESPONSES ####

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

	load_current_level_state(level, stored_objects_array)
	fade_in()

# When a player reach a checkpoint
func on_checkpoint_reached():
	GAME.progression.checkpoint += 1
	GAME.progression.set_main_xion(SCORE.xion)
	GAME.progression.set_main_materials(SCORE.materials)
	save_level(get_tree().get_current_scene())
	load_current_level_state(level, progression.main_storedObjects)
#	print_properties(progression.main_storedObjects, 'is_push')
