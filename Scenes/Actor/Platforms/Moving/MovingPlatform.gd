extends PlatformBase
class_name MovingPlatform
#### ACCESSORS ####

func is_class(value: String): return value == "MovingPlatform" or .is_class(value)
func get_class() -> String: return "MovingPlatform"

onready var platform_start_waypoint_node = $PathWaypoints/StartWaypoint
onready var platform_end_waypoint_node = $PathWaypoints/EndWaypoint

export var accel : float = 0.0
export var deccel : float = 0.0
export var speed : float = 0.0

var start_waypoint_coordinates : Vector2
var end_waypoint_coordinates : Vector2

#### BUILT-IN ####

func _ready():
	start_waypoint_coordinates = platform_start_waypoint_node.transform
	end_waypoint_coordinates = platform_end_waypoint_node.transform

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
