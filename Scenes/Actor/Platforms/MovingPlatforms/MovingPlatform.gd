extends NPCRobotBase
class_name MovingPlatform

func is_class(value: String): return value == "MovingPlatform" or .is_class(value)
func get_class() -> String: return "MovingPlatform"

#### ACCESSORS ####


#### BUILT-IN ####

func _ready():
	var _err = connect("velocity_changed",self,"_on_velocity_changed")

#### VIRTUALS ####

#### LOGIC ####

func apply_moving_velocity(vel : Vector2):
#	if body_triggering_area != null:
#		if body_triggering_area.force_exist("MovingInertia"):
#			body_triggering_area.set_force("MovingInertia", vel)
#		else:
#			body_triggering_area.add_force("MovingInertia", vel)
	pass

#### INPUTS ####

#### SIGNAL RESPONSES ####

func _on_body_entered(body : Node):
	._on_body_entered(body)
	
	yield(get_tree(),"idle_frame")
	if body.is_class("Player"):
		body.set_velocity(Vector2.ZERO)
		body_triggering_area.ignore_gravity = true
		apply_moving_velocity(velocity)

func _on_velocity_changed(vel : Vector2):
	apply_moving_velocity(vel)
