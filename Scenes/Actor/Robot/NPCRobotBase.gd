extends ActorBase
class_name NPCRobotBase

enum MOVEMENT_TYPE{ONESHOT = 0, PINGPONG, LOOP}

export(MOVEMENT_TYPE) var movement_type
export var path_disabled : bool = false
var path = []
var next_point_index : int = 0
var path_finished : bool = false
var travel_forward : bool = true

onready var original_pos = get_global_position()

#### ACCESSORS ####

func is_class(value: String):
	return value == "NPCRobotBase" or .is_class(value)

func get_class() -> String:
	return "NPCRobotBase"

#### BUILT-IN ####

func _ready():
	if path_node != null and !path_disabled:
		path = path_node.get_children()

#### LOGIC ####

func is_path_empty() -> bool:
	return path.empty()

# Check if the actor is arrived at the given position
func is_arrived(destination: Vector2) -> bool:
	var realvel = velocity * get_process_delta_time()
	return global_position.distance_to(destination) < realvel.length()

func is_path_finished(destination: PathPoint) -> bool:
	if travel_forward:
		return destination == path[-1]
	else:
		return destination == path[0]

func wait_for_delay(value : float):
	is_waiting = true
	var t = Timer.new()
	t.set_wait_time(value)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	set_state("Idle")
	yield(t, "timeout")
	t.queue_free()
	is_waiting = false
	set_state($StatesMachine.previous_state)
	

# Returns the world position of the given point
func get_point_world_position(point: Position2D) -> Vector2:
	return original_pos + point.get_global_position()

#### VIRTUALS ####


#### INPUTS ####



#### SIGNAL RESPONSES ####
