extends RobotActionState
class_name BabyBotActionState

var animated_sprite_node : AnimatedSprite

#### ACCESSORS ####

func is_class(value: String): return value == "BabyBotActionState" or .is_class(value)
func get_class() -> String: return "BabyBotActionState"


#### BUILT-IN ####

func enter_state():
	owner.set_direction(Vector2.ZERO)
	
	.enter_state()
	
	for body in action_hitbox_node.get_overlapping_bodies():
		if body.get_class() in owner.interactables:
			body.destroy()


func on_animation_finished():
	if states_machine.current_state == self:
		states_machine.set_state(states_machine.previous_state)
