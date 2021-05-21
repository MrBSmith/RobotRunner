tool
extends Door
class_name SafetyLockDoor

export var flip_h : bool = false setget set_flip_h


#### ACCESSORS ####

func is_class(value: String): return value == "SafetyLockDoor" or .is_class(value)
func get_class() -> String: return "SafetyLockDoor"

func set_flip_h(value: bool):
	if !is_ready:
		yield(self, "ready")
	
	if value != flip_h:
		flip_h = value
		animation_node.set_flip_h(flip_h)
	
	var invert = int(!flip_h) * 2 - 1
	$CollisionShape2D.position.x = abs($CollisionShape2D.position.x) * invert


#### BUILT-IN ####


#### VIRTUALS ####



#### LOGIC ####

func open(open: bool = true, instant : bool = false) -> void:
	set_visible(true)
	.open(open, instant)
	
	if open && instant:
		set_visible(false)
	
	if !instant:
		yield(animation_node, "animation_finished")
		set_visible(!open)


#### INPUTS ####



#### SIGNAL RESPONSES ####
