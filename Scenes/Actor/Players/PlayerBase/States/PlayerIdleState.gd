extends ActorStateBase
class_name PlayerIdleState

### IDLE STATE ###

var SFX_node : Node

# Setup method
func _ready():
	yield(owner, "ready")
	SFX_node = owner.get_node("SFX")
	
	var _err = animated_sprite.connect("animation_finished", self, "on_animation_finished")


# Check if the character is falling, before it triggers fall state
func update_state(_delta):
	if !owner.is_on_floor() and !owner.ignore_gravity:
		return "Fall"

	# Chage state to move if the player is moving horizontaly
	var horiz_movement = owner.get_velocity().x
	if abs(horiz_movement) > 0.0 :
		states_machine.set_state("Move")


# Triggers the Idle aniamtion when entering the state,
# If the character was falling before, triggers the landing animation before
func enter_state():
	if !owner.is_on_floor() and !owner.ignore_gravity:
		states_machine.set_state("Fall")
	
	var animations_array = animated_sprite.get_sprite_frames().get_animation_names()
	owner.current_snap = owner.snap_vector
	
	if states_machine.previous_state != null && states_machine.previous_state.name == "Fall"\
	 	&& "StartFalling" in animations_array:
		animated_sprite.play("Land")
	else:
		animated_sprite.play(self.name)


# Triggers the idle animation when the slanding is over
func on_animation_finished():
	if is_current_state():
		if animated_sprite.get_animation() == "Land":
			animated_sprite.play(self.name)
