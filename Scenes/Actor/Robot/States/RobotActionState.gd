extends RT_ActorActionState
class_name RobotActionState

var has_damaged : bool = false


#### ACCESSORS ####


func is_class(value: String): return value == "RobotActionState" or .is_class(value)
func get_class() -> String: return "RobotActionState"


#### BUILT-IN ####


# Setup, called by the parent when it is ready
func _ready():
	yield(owner, "ready")
	
	var _err = animated_sprite.connect("animation_finished", self, "on_animation_finished")


#### VIRTUALS ####

func update_state(_delta):
	if !has_damaged:
		damage()


# When the actor enters action state: set active the hit box, and play the right animation
func enter_state():
	if not owner is Player:
		owner.set_direction(Vector2.ZERO)
	
	.enter_state()
	
	# Set the hitbox active
	hit_box_shape.set_disabled(false)


# When the actor exits action state: set unactive the hit box and triggers the interaction if necesary
func exit_state():
	interact()
	
	# Reset the was broke bool, for the next use of the action state
	has_damaged = false
	
	# Set the hitbox inactive
	hit_box_shape.set_disabled(true)


func interact():
	# Check if the actor has already has damaged something 
	# (meaning it can't interact this time)
	if has_damaged: return
	
	.interact()


#### LOGIC ####



# Damage a block if it is in the hitbox area, and if his type correspond to the current robot breakable type
func damage():
	var bodies_in_hitbox = action_hitbox_node.get_overlapping_bodies()
	for body in bodies_in_hitbox:
		if is_obj_interactable(body):
			var average_pos = (body.global_position + action_hitbox_node.global_position) / 2
			damage_body(body, average_pos)
			has_damaged = true


# If the raycast found no obstacle in its way, damage the targeted body
func damage_body(body : PhysicsBody2D, impact_pos: Vector2):
	body.damage(owner)
	EVENTS.emit_signal("play_SFX", "great_hit", impact_pos)
	has_damaged = true


#### SIGNAL RESPONSES ####

# When the animation is off, set the actor's state to Idle
func on_animation_finished():
	if states_machine.current_state == self:
		if owner.is_on_floor():
			states_machine.set_state("Idle")
		else:
			states_machine.set_state("Fall")
