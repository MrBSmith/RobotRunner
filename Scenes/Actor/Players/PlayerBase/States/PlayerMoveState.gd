extends RobotMoveState
class_name PlayerMoveState

var SFX_node : Node


func _ready():
	yield(owner, "ready")
	SFX_node = owner.get_node("SFX")


func update_state( _delta):
	if !owner.is_on_floor() and !owner.ignore_gravity:
		return "Fall"
	elif owner.velocity.x == 0:
		return "Idle"


func enter_state():
	if !owner.is_on_floor() and !owner.ignore_gravity:
		owner.jump()
	
	owner.current_snap = owner.snap_vector
	animated_sprite.play(self.name)
	SFX_node.play_SFX("MoveDust", true)


func exit_state():
	SFX_node.play_SFX("MoveDust", false)


