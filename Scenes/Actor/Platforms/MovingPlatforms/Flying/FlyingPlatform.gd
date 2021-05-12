extends RobotPlatformBase
class_name FlyingPlatform

func is_class(value: String): return value == "FlyingPlatform" or .is_class(value)
func get_class() -> String: return "FlyingPlatform"

#### ACCESSORS ####


#### BUILT-IN ####


#### VIRTUALS ####


#### LOGIC ####

# function override
func compute_velocity():
	velocity = last_direction * current_speed
	if !ignore_gravity:
		velocity += GRAVITY

	emit_signal("velocity_changed", velocity)


#### INPUTS ####



#### SIGNAL RESPONSES ####
