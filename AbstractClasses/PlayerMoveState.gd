extends ActorStateBase
class_name PlayerMoveState

var SFX_node : Node
var inputs_node : Node

func _ready():
	yield(owner, "ready")
	SFX_node = owner.get_node("SFX")
	inputs_node = owner.get_node("Inputs")


func update( _delta):
	if !owner.is_on_floor():
		return "Fall"
	elif owner.velocity.x == 0:
		return "Idle"


func enter_state():
	if !owner.is_on_floor():
		states_machine.set_state("Jump")
	
	owner.current_snap = owner.snap_vector
	animated_sprite.play(self.name)
	SFX_node.play_SFX("MoveDust", true)


func exit_state():
	SFX_node.play_SFX("MoveDust", false)


# Define the actions the player can do in this state
func _input(event):
	if !owner.active:
		return
	
	if states_machine.get_state() == self:
		if event.is_action_pressed(inputs_node.get_input("Jump")):
			states_machine.set_state("Jump")
		
		elif event.is_action_pressed(inputs_node.get_input("Teleport")):
			owner.emit_signal("layer_change")
		
		elif event.is_action_pressed(inputs_node.get_input("Action")):
			states_machine.set_state("Action")

