tool
extends Door
class_name SafetyLockDoor

export var flip_h : bool = false setget set_flip_h

signal animation_finished()

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

func _ready() -> void:
	var __ = animation_node.connect("animation_finished", self, "_on_animation_finished")



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

func _on_animation_finished() -> void:
	emit_signal("animation_finished")



