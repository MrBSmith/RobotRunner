extends DoorButton
class_name DoorPushButton

var stay_triggered : bool = false setget set_stay_triggered

#### ACCESSORS ####

func is_class(value: String): return value == "DoorPushButton" or .is_class(value)
func get_class() -> String: return "DoorPushButton"

func set_stay_triggered(value: bool) -> void: stay_triggered = value

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
		if !is_button_being_pressed(body) && !stay_triggered:
			trigger(false)

# When the animation is finished, emit the signal, and disable the collision shape
func _on_animation_finished():
	var current_frame = animation_node.get_frame()
	var triggered = current_frame != 0
	set_pushed(triggered)
	
	if triggered:
		emit_signal("triggered")
	else:
		emit_signal("untriggered")
