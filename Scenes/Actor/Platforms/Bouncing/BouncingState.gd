extends ActorStateBase
class_name BouncingState
#### ACCESSORS ####

func is_class(value: String): return value == "BouncingState" or .is_class(value)
func get_class() -> String: return "BouncingState"

#### BUILT-IN ####

#### LOGIC ###
	
#### VIRTUALS ####

func enter_state():
	.enter_state()
	
	owner.platform_collisionshape_node.call_deferred("set_disabled", true)
	
	var state_timer = Timer.new()
	state_timer.set_one_shot(true)
	add_child(state_timer)
	state_timer.start(owner.bouncing_duration)
	yield(state_timer, "timeout")
	state_timer.queue_free()
	states_machine.set_state("Idle")

#### INPUTS ####

#### SIGNAL RESPONSES ####
