extends RobotPlatformMovingIdleState
class_name RobotPlatformFlyingIdleState

func is_class(value: String):
	return value == "" or .is_class(value)

func get_class() -> String:
	return ""
	
#### ACCESSORS ####



#### BUILT-IN ####



#### LOGIC ####

func enter_state():
	if !owner.is_ready:
		yield(owner, "ready")
	if owner.is_path_empty() or owner.path_finished or owner.is_waiting:
		.enter_state()
		owner.set_direction(Vector2.ZERO)
	else:
		owner.set_state("Move")

#### VIRTUALS ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
