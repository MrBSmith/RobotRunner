extends Camera2D

export var speed : float = 10
export var acceleration : float = 5
var current_acceleration : float = 1

onready var players_nodes_array = get_tree().get_nodes_in_group("Players")
onready var checkpoints_nodes_array = get_tree().get_nodes_in_group("CameraCheckpoint")
onready var start_area_node = get_node("StartMovingArea")
onready var play_zone_node = get_node("PlayZone")
onready var fast_forward_zone_node = get_node("FastForwardArea")

#var player_forwarding : bool = false

signal player_outside_screen
signal player_inside_screen

var cam_direction := Vector2(1, 0)

var screen_width : int = ProjectSettings.get("display/window/size/width")
var screen_height : int = ProjectSettings.get("display/window/size/height")
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
	_err = fast_forward_zone_node.connect("body_entered", self, "on_fast_forward_body_entered")
	_err = fast_forward_zone_node.connect("body_exited", self, "on_fast_forward_body_exited")
	for checkpoint in checkpoints_nodes_array:
		_err = checkpoint.connect("camera_reached_checkpoint", self, "_on_checkpoint_reached")


# Move the camera given by the last checkpoint
func _process(_delta):
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


# Toggle the acceleration of the camera if one of the players is in the fast forward zone
func on_fast_forward_body_entered(body):
	if body in players_nodes_array:
		#player_forwarding = true
		current_acceleration = acceleration


# When a body exits the fast forward zone, check if they are all outside it
func on_fast_forward_body_exited(body):
	if body in players_nodes_array:
		if all_players_in_area(fast_forward_zone_node, true):
			#player_forwarding = false
			current_acceleration = 1


# Check if all the players are inside/outise an area, depending on the value of the argument ouside (set to false by default)
# Return true is they are all inside/ouside, flase if not
func all_players_in_area(area : Area2D, outside : bool = false):
	var bodies_in_area = area.get_overlapping_bodies()
	var verif := true
	
	for player in players_nodes_array:
		if (player in bodies_in_area) == outside:
			verif = false
		else:
			verif = true
	
	return verif

# Get the camera direction from the current check point
func _on_checkpoint_reached(cp_dir):
	cam_direction = cp_dir
