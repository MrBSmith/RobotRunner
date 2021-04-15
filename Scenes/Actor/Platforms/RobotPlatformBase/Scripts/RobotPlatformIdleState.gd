extends ActorStateBase
class_name RobotPlatformMovingIdleState

#### ACCESSORS ####

func is_class(value: String): return value == "RobotPlatformMovingIdleState" or .is_class(value)
func get_class() -> String: return "RobotPlatformMovingIdleState"


#### BUILT-IN ####

func enter_state():
	if !owner.is_ready:
		yield(owner, "ready")
	if owner.is_path_empty() or owner.path_finished or owner.is_waiting:
		.enter_state()
		owner.set_direction(Vector2.ZERO)
	else:
		owner.set_state("Move")

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
