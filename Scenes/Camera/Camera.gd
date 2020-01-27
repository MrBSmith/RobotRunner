extends Camera2D

export var speed : float = 10
export var acceleration : float = 5
var current_acceleration : float = 1

onready var players_nodes_array = get_tree().get_nodes_in_group("Players")
onready var checkpoints_nodes_array = get_tree().get_nodes_in_group("CameraCheckpoint")
onready var start_area_node = get_node("StartMovingArea")
onready var play_zone_node = get_node("PlayZone")
onready var fast_forward_zone_node = get_node("FastForwardArea")
onready var safe_area_node = get_node("SafeArea")

onready var original_forward_shape_ext = fast_forward_zone_node.get_node("CollisionShape2D").get_shape().get_extents()
onready var original_safe_area_shape_ext = Vector2((screen_width / 2), (screen_height / 3))
#var player_forwarding : bool = false

signal player_outside_screen
signal player_inside_screen

export var cam_direction := Vector2(1, 0)

var screen_width : float = ProjectSettings.get("display/window/size/width")
var screen_height : float = ProjectSettings.get("display/window/size/height")
var screen_size := Vector2(screen_width, screen_height)

func _ready():
	# Set the camera play_area (the playable area, where the players need to stay in) to the size of the game window 
	play_zone_node.get_node("CollisionShape2D").get_shape().set_extents(screen_size / 2)
	
	set_physics_process(false)
	
	# Connect signals
	var _err
	_err = start_area_node.connect("body_entered", self, "on_start_area_body_entered")
	_err = play_zone_node.connect("body_exited", self, "on_play_area_zone_exited")
	_err = play_zone_node.connect("body_entered", self, "on_play_area_zone_entered")
	for checkpoint in checkpoints_nodes_array:
		_err = checkpoint.connect("camera_reached_checkpoint", self, "_on_checkpoint_reached")


# Move the camera given by the last checkpoint
func _physics_process(_delta):
	if is_forwarding():
		current_acceleration = acceleration
	else:
		current_acceleration = 1
	position += (speed / 100) * cam_direction * current_acceleration


# Start to move the camera if a player enter the start area
func on_start_area_body_entered(body):
	if body in players_nodes_array:
		set_physics_process(true)


# When a player exits the camera zone
func on_play_area_zone_exited(body):
	if body in players_nodes_array:
		emit_signal("player_outside_screen", body)


# When a player enter back the camera zone
func on_play_area_zone_entered(body):
	if body in players_nodes_array:
		emit_signal("player_inside_screen", body)



# Get the camera direction from the current check point, and adapt area in response
func _on_checkpoint_reached(cp_dir):
	cam_direction = cp_dir
	adapt_area(fast_forward_zone_node, original_forward_shape_ext)
	adapt_area(safe_area_node, original_safe_area_shape_ext)


# Check if the players are inside/outise an area, depending on the value of the argument ouside (set to false by default)
# Return true is they are inside/ouside, false if not
# If the argument all is true, they all have to be inside/ouside for the method to return true
# If the argument all is false, check if a least one player is inside/outside
func players_in_area(area : Area2D, all : bool):
	var bodies_in_area = area.get_overlapping_bodies()
	
	for player in players_nodes_array:
		if(player in bodies_in_area) == (!all):
			return !all
	
	return all


# Check if one player or more is in the forward zone while all players are in the safe zone, return true if it is, false if not
func is_forwarding() -> bool:
	# Check if one of the players is inside the fast forward area
	if players_in_area(fast_forward_zone_node, false):
		# Check if all the players are in the safe area
		if players_in_area(safe_area_node, true):
			return true
	return false


# Compute the size and the direction of safe/forward area based on the direction of the camera
func adapt_area(area : Area2D, original_ext : Vector2):
	var collision_shape = area.get_node("CollisionShape2D")
	var shape = collision_shape.get_shape()
	
	### TO SET AS DYNAMIC LATER ###
	# Compute the size of the given shape
	if cam_direction.x != 0:
		shape.extents = original_ext
	if cam_direction.y != 0:
		if area == fast_forward_zone_node:
			shape.extents.x = (screen_width / 2)
			shape.extents.y = original_ext.x
		else:
			shape.extents.x = original_ext.x
			shape.extents.y = original_ext.y
	
	var shape_extents = shape.get_extents()
	
	# Compute the position of the given area
	collision_shape.position.x = ((screen_width / 2) - shape_extents.x) * sign(cam_direction.x)
	collision_shape.position.y = ((screen_height / 2) - shape_extents.y) * sign(cam_direction.y)
