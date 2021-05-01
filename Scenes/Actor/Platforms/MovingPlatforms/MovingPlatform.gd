extends NPCRobotBase
class_name MovingPlatform

func is_class(value: String): return value == "MovingPlatform" or .is_class(value)
func get_class() -> String: return "MovingPlatform"

#### ACCESSORS ####


#### BUILT-IN ####

#### VIRTUALS ####

#### LOGIC ####


#### INPUTS ####

#### SIGNAL RESPONSES ####

func _on_body_entered(body : Node):
	if body.is_class("Player"):
		body.ignore_gravity = true
