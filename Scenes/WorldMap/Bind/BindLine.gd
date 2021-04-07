tool
extends Line2D
class_name BindLine

const bind_line_scene_path = "res://Scenes/WorldMap/Bind/BindLine.tscn"
onready var bind_variation_scene = preload("res://Scenes/WorldMap/Bind/BindVariation.tscn")

onready var start_cap = $StartCap
onready var end_cap = $EndCap
onready var bind_line_scene = load(bind_line_scene_path)

export var start_cap_visible : bool = false setget set_start_cap_visible
export var end_cap_visible : bool = true setget set_end_cap_visible

export var subline_offset : float = 8.0
export var sub_line_minimum_dist : float = 17.0

export var depth : int = 0 setget set_depth
export var max_depth : int = 2 setget set_max_depth

var corner_line : bool = false
var dead_end : bool = false

var is_ready : bool = false
var offset_sign : int = 0


#### ACCESSORS ####

func is_class(value: String): return value == "BindLine" or .is_class(value)
func get_class() -> String: return "BindLine"

func set_start_cap_visible(value: bool):
	start_cap_visible = value
	if !is_ready:
		yield(self, "ready")
	
	start_cap.set_visible(value)

func set_end_cap_visible(value: bool):
	end_cap_visible = value
	if !is_ready:
		yield(self, "ready")
	
	end_cap.set_visible(value)

func set_points(points_array: PoolVector2Array):
	if points_array.size() < 2: return
	
	for i in range(points_array.size()):
		var point = points_array[i]
		if i == 0:
			start_cap.set_position(point - points_array[0].direction_to(points_array[1]))
		elif i == points_array.size() - 1:
			end_cap.set_position(point - points_array[i].direction_to(points_array[i - 1]))
	
	points = points_array
	
	if dead_end == false && (depth < max_depth - 1 or corner_line):
		update_children_binds()

func set_depth(value: int): depth = value
func set_max_depth(value: int): max_depth = value

#### BUILT-IN ####

func _ready() -> void:
	is_ready = true
	
	if depth != 0:
		set_start_cap_visible(false)
	
	if corner_line:
		set_end_cap_visible(false)


#### VIRTUALS ####



#### LOGIC ####

func update_children_binds():
	clear_children_binds()
	
	# Generate the dead ends of the corner line
	if corner_line == true:
		generate_dead_end_lines()
	else:
		generate_node_sublines()

	# Generate the corner lines & variations
	if depth == 0 && corner_line == false:
		if points.size() > 2:
			generate_corner_lines()
		
		yield(get_tree(), "idle_frame")
		generate_variations()
	


func generate_node_sublines():
	# Loop through both start and end cap
	for i in range(2):
		
		# If we're not in the main line, we need to treat only the end cap
		if depth != 0 && i == 0:
			continue
		var level_node = null
		if depth == 0:
			level_node = owner.origin if i == 0 else owner.destination
		
		var rng = randi() % 3 if depth == 0 else 1
		if max_depth > 5 && depth == 0:
			 rng = 2
		
		var point = points[0] if i == 0 else points[-1]
		var dir = points[0].direction_to(points[1]) if i == 0 else points[-1].direction_to(points[-2])
		var dist = points[0].distance_to(points[1]) if i == 0 else points[-1].distance_to(points[-2])
		var last_sign = 0
		
		# Loop through each offset direction
		for _j in range(rng):
			var line = bind_line_scene.instance()
			var current_sign = 0
			
			# Compute the direction in which the end point will be generated
			
			# If we generate sublines of sublines: generate the line always the same side
			if depth > 0: 
				current_sign = offset_sign
			# If its the main line generating it sublines and we're generating the first one
			elif last_sign == 0:
				 current_sign = (randi() % 2) * 2 - 1
			# If its the main line generating it sublines and we're generating the second one
			else: 
				current_sign = -last_sign
			
			last_sign = current_sign
			
			var offset_dir = dir.rotated(deg2rad(90))
			
			if sub_line_minimum_dist > dist / 2:
				continue
			
			# Compute start & end points
			var start_point_dist = rand_range(sub_line_minimum_dist, dist / 2)
			var start_point = point + start_point_dist * dir
			var end_point = point + offset_dir * current_sign * subline_offset
			
			var line_points_array = [start_point]
			
			# Compute the intermediate point
			var point_dist = end_point - start_point
			var horizontal = dir.x != 0
			
			var ratio = 1 if start_point_dist < dist / 4 else 2  
			
			var inter_point = start_point + Vector2(0, point_dist.y) - dir * abs(point_dist.y) * ratio
			if !horizontal:
				 inter_point = start_point + Vector2(point_dist.x, 0) - dir * abs(point_dist.x) * ratio
			
			if start_point_dist != sub_line_minimum_dist:
				line_points_array.append(inter_point)
			
			line_points_array.append(end_point)
			
			# Add the line & give it its points
			line.offset_sign = current_sign
			line.set_depth(depth + 1)
			if level_node != null && level_node.name == "BossLevelNode" && depth == 0:
				line.set_max_depth(max_depth + 4)
			else:
				line.set_max_depth(max_depth)
			add_child(line)
			line.set_owner(self)
			line.call_deferred("set_points", PoolVector2Array(line_points_array))



func generate_corner_lines():
	if randi() % 3 == 0: return
	
	var rdm_sign = (randi() % 2) * 2 - 1
	var dir = points[1].direction_to(points[1 + rdm_sign])
	var segment_total_dist = points[1].distance_to(points[1 + rdm_sign])
	var offset_dir = points[1 - rdm_sign].direction_to(points[1]) 
	
	if segment_total_dist / 2 < sub_line_minimum_dist:
		return
	
	var final_point_dist = rand_range(sub_line_minimum_dist, segment_total_dist / 2)
	
	var start_point = points[1]
	var intermediate_point = points[1] + offset_dir * subline_offset
	var end_point = intermediate_point + final_point_dist * dir
	
	var line_points_array = [start_point, intermediate_point, end_point]
	
	var line = bind_line_scene.instance()
	line.corner_line = true
	line.set_depth(depth + 1)
	line.set_max_depth(0)
	
	add_child(line)
	line.call_deferred("set_points", PoolVector2Array(line_points_array))



func generate_dead_end_lines():
	if corner_line == true:
		var dir = points[-1].direction_to(points[-2])
		var offset_dir = points[0].direction_to(points[1])
		
		var nb_dead_end = randi() % 3 + 1
		
		for i in range(nb_dead_end):
			var start_point = points[-1] + dir * subline_offset * i
			var end_point = start_point + offset_dir * subline_offset
			
			var line = bind_line_scene.instance()
			line.set_depth(depth + 1)
			line.set_max_depth(0)
			line.dead_end = true
			
			add_child(line)
			line.call_deferred("set_points", PoolVector2Array([start_point, end_point]))


func generate_variations():
	for i in range(points.size() - 1):
		if randi() % 3 != 0: continue
		var dir = points[i].direction_to(points[i + 1])
		var dist = points[i].distance_to(points[i + 1])
		var point = points[i] + dist / rand_range(1.3, 3.0) * dir
		
		if !is_point_available(point):
			continue
		
		for j in range(randi() % 2 + 3):
			var dir_sign = (j % 2) * 2 - 1 if j != 0 else 0
			
			var nb_offset = int(float(j + 1) / 2)
			
			var variation = bind_variation_scene.instance()
			variation.set_position(point + (dir_sign * dir * 3 * nb_offset))
			variation.set_rotation(dir.angle())
			add_child(variation)


func clear_children_binds():
	for child in get_children():
		if not child in [start_cap, end_cap]:
			child.queue_free()


func get_points_recursive(array_to_fill: Array):
	for point in points:
		array_to_fill.append(point)
	
	for child in get_children():
		if child.is_class("BindLine"):
			child.get_points_recursive(array_to_fill)


func is_point_available(point_to_test: Vector2) -> bool:
	var points_array : Array = []
	
	get_points_recursive(points_array)
	
	for point in points_array:
		if point.distance_to(point_to_test) < sub_line_minimum_dist:
			return false
	
	return true


#### INPUTS ####



#### SIGNAL RESPONSES ####
