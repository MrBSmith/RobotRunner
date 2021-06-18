extends NPCRobotBase
class_name RobotPlatformBase

#### ACCESSORS ####

func is_class(value: String): return value == "RobotPlatformBase" or .is_class(value)
func get_class() -> String: return "RobotPlatformBase"

#### BUILT-IN ####


#### VIRTUALS ####


#### LOGIC ####


#### INPUTS ####


#### SIGNAL RESPONSES ####

func _on_body_entered(body : Node):
	if body.is_class("Player"):
		body.set_ignore_gravity(true)


func _on_body_exited(body : Node):
	if body.is_class("Player"):
		if "ignore_gravity" in body:
			if body.ignore_gravity:
				body.set_ignore_gravity(false)
		if body.get_state_name() == "Jump":
			body.add_force("PlatformInertia",velocity)
