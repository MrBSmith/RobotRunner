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

onready var trigger_area_node = get_node_or_null("TriggerArea")
onready var area_node : Area2D = get_node_or_null("Area2D")
var body_triggering_area : PhysicsBody2D = null
#export var triggering_bodies : PoolStringArray = ["Player"]

#### ACCESSORS ####

func is_class(value: String):
	return value == "NPCRobotBase" or .is_class(value)

func get_class() -> String:
	return "NPCRobotBase"

#### BUILT-IN ####

func _ready():
	if path_node != null and !path_disabled:
		path = path_node.get_children()
	if trigger_area_node != null:
		var _err = trigger_area_node.connect("area_triggered",self,"_on_area_triggered")
	if area_node != null:
		var _err = area_node.connect("body_entered",self,"_on_body_entered")
		_err = area_node.connect("body_exited",self,"_on_body_exited")

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

func compute_velocity():
	# Compute velocity
	velocity = last_direction * current_speed
	if !ignore_gravity:
		velocity += GRAVITY
	
	emit_signal("velocity_changed", velocity)

func apply_movement(_delta):
	var next_point_position
	var next_point_distance

	if path.size() == 0:
		next_point_distance = max_speed
	else:
		next_point_position = get_point_world_position(path[next_point_index])
		next_point_distance = get_global_position().distance_to(next_point_position)

	if (velocity.length() * _delta) > next_point_distance:
		set_global_position(next_point_position)
	else:
		velocity = move_and_slide_with_snap(velocity, current_snap, Vector2.UP, true, 4, deg2rad(46), false)

#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_body_entered(body : Node):
	
	yield(get_tree(),"idle_frame")
	if body.is_class("Player"):
		body.set_velocity(Vector2.ZERO)	
		body_triggering_area = body
		body.current_platform = weakref(self)

func _on_body_exited(body : Node):
	yield(get_tree(),"idle_frame")
	var overlapping_bodies = $Area2D.get_overlapping_bodies()
	if body == null or body_triggering_area in overlapping_bodies or body != body_triggering_area:
		return
	else:
		if body_triggering_area.has_method("remove_force"):
			body_triggering_area.remove_force("MovingInertia")
		if "ignore_gravity" in body_triggering_area:
			if body_triggering_area.ignore_gravity:
				body_triggering_area.ignore_gravity = false
		body_triggering_area = null
		body.current_platform = null
