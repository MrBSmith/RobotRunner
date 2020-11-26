extends Area2D
class_name Lava

#### LAVA MAIN NODE ####

## USE: CHANGE THE SIZE OF THE POOL BY CHANGING THE SCALE OF THIS NODE ##
## PLEASE DO NOT USE CHANGE CHILDREN TO CHANGE THE SIZE ##

#### ACCESSORS ####

func is_class(value: String):
	return value == "Lava" or .is_class(value)

func get_class() -> String:
	return "Lava"


#### BUILT-IN ####

func _ready():
	var _err = connect("body_entered", self, "on_body_entered")


#### SIGNAL RESPONSES ####

# Destroy the body entering the lava
func on_body_entered(body):
	if body.has_method("destroy"):
		body.destroy()
