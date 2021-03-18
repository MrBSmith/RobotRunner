tool
extends Path2D
class_name LevelNodeBind

onready var line : Line2D = $Line2D

export var origin_node_path : String = ""
export var destination_node_path : String = ""

var origin : Node2D setget set_origin, get_origin
var destination : Node2D setget set_destination, get_destination

var origin_pos := Vector2.INF setget set_origin_pos
var dest_pos := Vector2.INF setget set_dest_pos

var is_ready : bool = false

#### ACCESSORS ####

func is_class(value: String): return value == "LevelNodeBound" or .is_class(value)
func get_class() -> String: return "LevelNodeBound"

func set_origin(value: Node2D):
	if origin == value: 
		return
	origin = value
	if origin_node_path == "" && owner != null:
		origin_node_path = owner.get_path_to(origin)
	
	if origin == null:
		origin_pos == Vector2.INF

func get_origin() -> Node2D: return origin

func set_destination(value: Node2D): 
	if destination == value: 
		return
	destination = value
	if destination_node_path == "" && owner != null:
		destination_node_path = owner.get_path_to(destination)
	
	if destination == null:
		dest_pos == Vector2.INF

func get_destination() -> Node2D: return destination

func set_origin_pos(value: Vector2): 
	if value != origin_pos:
		origin_pos = value
		_update_line()

func set_dest_pos(value: Vector2): 
	if value != dest_pos:
		dest_pos = value
		_update_line()

#### BUILT-IN ####

func _ready() -> void:
	set_curve(Curve2D.new())
	
	if owner != null && origin_node_path != "" && destination_node_path != "":
		set_origin(owner.get_node(origin_node_path))
		set_destination(owner.get_node(destination_node_path))
	
	is_ready = true


func _process(delta: float) -> void:
	if Engine.editor_hint:
		if origin != null && destination != null:
			set_origin_pos(origin.get_global_position())
			set_dest_pos(destination.get_global_position())

#### VIRTUALS ####



#### LOGIC ####


func _update_line():
	if Vector2.INF in [origin_pos, dest_pos]:
		return
	
	curve.clear_points()
	
	curve.add_point(origin_pos)
	
	var x_dist = abs(origin_pos.x - dest_pos.x)
	var y_dist = abs(origin_pos.y - dest_pos.y)
	
	if x_dist != 0.0 && y_dist != 0.0:
		if x_dist > y_dist:
			curve.add_point(Vector2(origin_pos.x, dest_pos.y))
		else:
			curve.add_point(Vector2(dest_pos.x, origin_pos.y))
	
	curve.add_point(dest_pos)
	
	var points = curve.get_baked_points()
	line.set_points(points)


#### INPUTS ####



#### SIGNAL RESPONSES ####
