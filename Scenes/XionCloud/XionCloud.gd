extends Area2D
class_name XionCloud

onready var timer_node = $Timer
onready var path_node = get_node_or_null("CloudPath")
onready var collision_shape_node = $CollisionShape2D

export var speed : float = 40.0 

var path : PoolVector2Array = []

export var cloud_active : bool = true
export var time_before_moving : float = 0.0

signal player_in_danger
signal player_out_of_danger


#### ACCESSORS ####

func is_class(value: String):
	return value == "XionCloud" or .is_class(value)

func get_class() -> String:
	return "XionCloud"

func get_direction() -> Vector2:
	if path.empty(): return Vector2.ZERO
	else:
		var dir = global_position.direction_to(path[0])
		return Vector2(round(dir.x), round(dir.y))

#### BUILT-IN ####

func _ready():
	var _err = connect("body_entered", self, "on_body_entered")
	_err = connect("body_exited", self, "on_body_exited")
	_err = timer_node.connect("timeout", self, "on_timer_timeout")
	
	add_to_group("XionCloud")
	
	# Connect the signals only if the scene is not playing alone
	if owner != null:
		_err = connect("player_in_danger", owner, "on_player_in_danger")
		_err = connect("player_out_of_danger", owner, "on_player_out_of_danger")
	
	set_physics_process(false)
	
	if path_node != null:
		var path_len = path_node.get_curve().get_point_count()
		for i in range(path_len):
			path.append(path_node.get_curve().get_point_position(i))
		
		# Set the timer time, or triggers the cloud if the time is lesser or equal to 0
		if time_before_moving <= 0.0:
			set_physics_process(cloud_active)
		else:
			timer_node.set_wait_time(time_before_moving)
			timer_node.start()
	
	set_active(cloud_active)


# Move the cloud, until it's arrived to the next point
func _physics_process(delta):
	if len(path) > 0:
		var target_point_world = path[0]
		var arrived_to_next_point = move_to(target_point_world, scale, delta)
		
		# If the cloud is arrived to the next point, remove this point from the path and take the next for destination
		if arrived_to_next_point == true:
			path.remove(0)
	else:
		set_physics_process(false)


#### LOGIC ####

# Set the could active or not, 
# if the cloud_active is false, set the cloud to invisible and make it stop
func set_active(value : bool):
	cloud_active = value
	collision_shape_node.call_deferred("set_disabled", !value)
	set_visible(value)
	set_physics_process(value)


func stop():
	set_physics_process(false)


# Return the number of elements in the array of the given class
func count_class_in_array(array: Array, cls_name: String) -> int:
	var nb_element : int = 0
	
	for element in array:
		if element.is_class(cls_name):
			nb_element += 1
	
	return nb_element


# Return true if a element in the given array is of class player, flase if not
func is_class_in_array(array: Array, cls_name: String) -> bool:
	for element in array:
		if element.is_class(cls_name):
			return true
	return false


# Handle the movement to the next point on the path, return true if the node is arrived
func move_to(destination : Vector2, path_scale: Vector2, delta: float):
	var velocity = (destination - position).normalized() * speed * delta
	var avrg_scale = (path_scale.x + path_scale.y) / 2
	
	if position.distance_to(destination) <= speed * delta / avrg_scale:
		position = destination
	else:
		position += velocity / path_scale

	return destination == position


#### SIGNAL RESPONSES ####

# When the timer is over, triggers the cloud mouvement
func on_timer_timeout():
	set_physics_process(cloud_active)


# Triggers the overheat if a player enters the cloud
func on_body_entered(body: Node):
	if body.is_class("Player"):
		body.overheat()
		
		# Emit the signal only if the scene is not playing alone
		if owner != null:
			emit_signal("player_in_danger")


# Stop the overheat animation when a player exits the cloud
func on_body_exited(body: Node):
	if body.is_class("Player"):
		body.stop_overheat()
		
		# Emit the signal only if the scene is not playing alone
		if owner != null:
			var bodies_in_cloud = get_overlapping_bodies()
			if count_class_in_array(bodies_in_cloud, "Player") <= 1:
				emit_signal("player_out_of_danger")

