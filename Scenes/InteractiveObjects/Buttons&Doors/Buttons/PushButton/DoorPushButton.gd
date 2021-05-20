extends DoorButton
class_name DoorPushButton

#### ACCESSORS ####

func is_class(value: String): return value == "DoorPushButton" or .is_class(value)
func get_class() -> String: return "DoorPushButton"


#### BUILT-IN ####

func _ready() -> void:
	var _err = area2D_node.connect("body_exited", self, "_on_body_exited")
	

#### VIRTUALS ####



#### LOGIC ####

func is_button_being_pressed(exception_body: Node2D) -> bool:
	for body in area2D_node.get_overlapping_bodies():
		if body == exception_body:
			continue
		
		if body.is_class("ActorBase"):
			return true
	return false

#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_body_exited(body: Node2D):
	if body.is_class("ActorBase"):
		if !is_button_being_pressed(body):
			trigger(false)
