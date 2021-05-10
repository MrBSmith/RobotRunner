extends ActorStateBase
class_name RobotPlatformBouncingIdleState

func is_class(value: String):
	return value == "RobotPlatformBouncingIdleState" or .is_class(value)
func get_class() -> String:
	return "RobotPlatformBouncingIdleState"

#### ACCESSORS ####

#### BUILT-IN ####

func enter_state():
	.enter_state()
	owner.platform_collisionshape_node.call_deferred("set_disabled", false)

#### LOGIC ####

#### VIRTUALS ####

#### INPUTS ####

#### SIGNAL RESPONSES ####
