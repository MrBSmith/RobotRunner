extends CameraState
class_name CameraStopState

#### STOP STATE CAMERA ####

# This state is called when we need the camera not to move,
# Or to wait a certain amount of time, not moving

onready var timer_node = $Timer

var wait_time : float = INF

func _ready():
	var _err = timer_node.connect("timeout", self, "on_timer_timeout")


func enter_state():
	if wait_time != INF:
		timer_node.set_wait_time(wait_time)
		timer_node.start()


func exit_state():
	wait_time = INF
	timer_node.stop()


func on_timer_timeout():
	if len(owner.instruction_stack) != 0:
		owner.execute_next_instruction()
	else:
		states_machine.set_state(states_machine.default_state)
