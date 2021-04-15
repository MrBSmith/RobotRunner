extends NPCRobotBase
class_name RobotPlatformBase

#### ACCESSORS ####

func is_class(value: String): return value == "RobotPlatformBase" or .is_class(value)
func get_class() -> String: return "RobotPlatformBase"


#### BUILT-IN ####



#### VIRTUALS ####

func compute_velocity():
	# Compute velocity
	velocity = last_direction * current_speed
	if !ignore_gravity:
		velocity.y += GRAVITY

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
#		move_and_slide(velocity, Vector2.UP)
		set_global_position(get_global_position() + velocity * _delta)

#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
