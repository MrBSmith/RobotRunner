extends RT_ActorJumpState
class_name RobotJumpState

### JUMP STATE ###


func update(_delta):
	if owner.is_on_floor():
		return "Idle"
	elif owner.velocity.y > 0:
		return "Fall"


func enter_state():
	.enter_state()
	
	if owner.get("current_snap") != null:
		owner.current_snap = Vector2.ZERO
	
	# Apply the jump force
	owner.velocity.y = owner.jump_force



func _on_animation_finished():
	if states_machine.get_state() == self:
		if animated_sprite.get_animation() == "Jump":
			if "MidAir" in animated_sprite.get_sprite_frames().get_animation_names():
				animated_sprite.play("MidAir")

