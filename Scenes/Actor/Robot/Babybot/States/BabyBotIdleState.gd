extends RobotIdleState
class_name BabyBotIdleState

#### ACCESSORS ####

func is_class(value: String): return value == "BabyBotIdleState" or .is_class(value)
func get_class() -> String: return "BabyBotIdleState"


#### BUILT-IN ####

func enter_state():
	if owner.is_path_empty():
		.enter_state()
		owner.set_direction(Vector2.ZERO)
	else:
		owner.set_state("Move")

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
