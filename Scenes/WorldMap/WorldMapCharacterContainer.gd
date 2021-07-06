tool
extends WorldMapMovingElement
class_name WorldMapCharacterContainer

signal enter_level_animation_finished

#### ACCESSORS ####

func is_class(value: String): return value == "WorldMapCharacterContainer" or .is_class(value)
func get_class() -> String: return "WorldMapCharacterContainer"


#### BUILT-IN ####




#### VIRTUALS ####



#### LOGIC ####


func move_to_level(level_node: LevelNode, _interpol: bool= true):
	moving = true
	set_global_position(level_node.get_global_position())
	
	for child in get_children():
		if child is WorldMapCharacter:
			tween_node.interpolate_property(child, "position",
				child.get_position(), Vector2.ZERO,
				1.0, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	
	tween_node.start()
	
	yield(tween_node, "tween_all_completed")
	moving = false
	emit_signal("enter_level_animation_finished")


#### INPUTS ####



#### SIGNAL RESPONSES ####

