extends Door
class_name GreatDoor

#### GREAT DOOR CLASS ####

onready var area_node = $Area2D

# When set to true (default), the camera will move until it reach the position of the door
# When set to false, the camera will make an average between the average players position
# And the door position, and move to it
export var focus_on_door : bool = true

signal player_exit_level

#### ACCESSORS ####

func is_class(value: String):
	return value == "GreatDoor" or .is_class(value)

func get_class() -> String:
	return "GreatDoor"


#### BUILT-IN ####

func _ready():
	var _err = area_node.connect("body_entered", self, "on_area_body_entered")
	_err = connect("player_exit_level", owner, "on_player_exited")

#### LOGIC ####

# Triggers the opening of the door
func open(open: bool = true, _instant : bool = false):
	if open == opened or open == false:
		return
	
	# Triggers the camera movement
	EVENTS.emit_signal("move_camera_to_query", position, !focus_on_door, -1.0, 0.0)
	
	for child in self.get_children():
		if child is AnimationPlayer:
			animation_node.play("Open")
	
	collision_node.set_disabled(open)
	set_opened(open)

#### SIGNAL RESPONSES ####

# Notify the game autoload that a player exited the level 
func on_area_body_entered(body : PhysicsBody2D):
	if body != null && body.is_class("Player"):
		emit_signal("player_exit_level", body)
		body.fade_out()
