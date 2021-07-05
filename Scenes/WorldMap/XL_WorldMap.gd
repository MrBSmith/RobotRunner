tool
extends WorldMap
class_name XL_WorldMap

const signal_light_scene = preload("res://Scenes/WorldMap/SignalLight.tscn")
const pulsing_light_scene = preload("res://BabaGodotLib/Feedback/PulsingLight.tscn")

onready var moving_light_container = $MovingLightContainer
onready var fade_transition_node = $Transition

var pulsing_light = null

#### ACCESSORS ####

func is_class(value: String): return value == "XL_WorldMap" or .is_class(value)
func get_class() -> String: return "XL_WorldMap"


#### BUILT-IN ####

func _ready() -> void:
	var __ = get_tree().connect("node_removed", self, "_on_scene_tree_node_removed")
	
	if !Engine.editor_hint:
		var visited_levels = GAME.progression.visited_levels
		var last_level_id = GAME.progression.get_last_level_id()
		var last_level_path = GAME.current_chapter.get_level_path(last_level_id)
		
		apply_current_progression(visited_levels, last_level_path)
		fade_transition_node.fade(1.0, FadeTransition.FADE_MODE.FADE_IN)
	
	var current_level = cursor.get_current_level()
	generate_pulsing_light(current_level)


#### VIRTUALS ####



#### LOGIC ####


func apply_current_progression(visited_levels: Array, last_level_path: String) -> void:
	var levels_array = get_level_nodes()
	var last_level : LevelNode = null
	for level in levels_array:
		var level_scene_path = level.get_level_scene_path()
		if level_scene_path in visited_levels:
			level.set_visited(true)
		
		if level_scene_path == last_level_path:
			last_level = level
	
	init_cursor_position(last_level)


func enter_current_level():
	# Assure there is no moving light currently moving in the world map
	if moving_light_container.get_child_count() > 0:
		return
	
	if pulsing_light != null:
		pulsing_light.call_deferred("queue_free")
	
	var cursor_level_node = cursor.get_current_level()
	var character_current_level = characters_container.get_current_level()
	
	if cursor_level_node != character_current_level:
		light_moving_through(characters_container.current_level, cursor_level_node)
		yield(self, "character_moving_feedback_finished")
	
	characters_container.move_to_level(cursor_level_node)
	yield(characters_container, "enter_level_animation_finished")
	
	.enter_current_level()


func generate_pulsing_light(current_level: LevelNode):
	pulsing_light = pulsing_light_scene.instance()
	pulsing_light.set_global_position(current_level.get_global_position())
	pulsing_light.set_light_color(Color.yellow)
	pulsing_light.set_scale(Vector2(0.3, 0.3))
	pulsing_light.set_pulsing(true)
	
	add_child(pulsing_light)


func light_moving_through(start: LevelNode, dest: LevelNode):
	var bind = get_bind(start, dest)
	if bind == null:
		print_debug("The given start and/or dest LevelNode are neither the origin nor the destination")
		return
	
	var line_array := Array()
	var output_branch_array := Array()
	
	bind.get_every_branching_line(start, line_array)
	bind.get_every_branching_line(dest, output_branch_array)
	
	output_branch_array.erase(line_array[0])
	
	for i in range(max(line_array.size(), output_branch_array.size())):
		var line = line_array[i] if i < line_array.size() else line_array[0]
		var output_line = output_branch_array[i] if i < output_branch_array.size() else null
		var line_points = line.get_points()
		var output_line_points = output_line.get_points() if output_line != null else []
		
		if line.depth != 0 or start != line.get_start_cap_node():
			line_points.invert()
		
			if line.depth != 0:
				var main_line_points = line_array[0].get_points()
				if start != line_array[0].get_start_cap_node():
					main_line_points.invert()
				main_line_points.remove(0)
				line_points += main_line_points
		
		var signal_light = signal_light_scene.instance()
		var light_pos = line_points[0]
		moving_light_container.add_child(signal_light)
		
		var last_point = line_points[-1]
		line_points.resize(line_points.size() - 1)
		line_points.append_array(output_line_points)
		line_points.append(last_point)
		
		signal_light.set_global_position(light_pos)
		signal_light.move_along_path(line_points, false)


func is_animation_running() -> bool:
	return characters_container.is_moving() or moving_light_container.get_child_count() != 0


#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_scene_tree_node_removed(node: Node):
	if node.is_class("WorldMapSignalLight"):
		yield(get_tree(), "idle_frame")
		if moving_light_container.get_child_count() == 0:
			emit_signal("character_moving_feedback_finished")
