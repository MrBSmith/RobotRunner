extends ActorFallState
class_name PlayerFallState

onready var tolerance_timer_node = $ToleranceTimer
onready var jump_buffer_timer_node = $JumpBufferTimer


#### BUILT-IN ####

func _ready() -> void:
	var _err = tolerance_timer_node.connect("timeout", owner, "on_tolerence_timeout")
	_err = jump_buffer_timer_node.connect("timeout", owner, "on_jump_buffer_timeout")


#### VIRTUALS ####

# Start the cool down at the entry of the state
func enter_state():
	owner.current_snap = Vector2.ZERO
	var previous_state_name : String = states_machine.previous_state.name
	
	# Start the time during which the jump is tolerated
	if previous_state_name in ["Move", "Idle"]:
		tolerance_timer_node.start()
		owner.jump_tolerance = true
	
	# Triggers the StartFalling animation if it exists
	if "StartFalling" in animated_sprite.get_sprite_frames().get_animation_names():
		animated_sprite.play("StartFalling")
	else:
		animated_sprite.play(self.name)


# Reset the jump tolerance and jump buffered bools to ensure no unwanted behaviours
func exit_state():
	owner.jump_tolerance = false
	owner.jump_buffered = false
	owner.remove_impulse("bounce")
	owner.remove_force("PlatformInertia")


func update_state(_delta):
	if owner.is_on_floor():
		if owner.jump_buffered:
			owner.jump()
		else:
			return "Idle"
	elif owner.ignore_gravity:
		return "Idle"
	else:
		return


#### INPUTS ####




#### SIGNAL RESPONSES ####



