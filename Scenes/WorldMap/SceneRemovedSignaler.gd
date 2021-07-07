tool
extends Node
class_name SceneDestroyedAlerter

signal scene_destroyed_alert

#### ACCESSORS ####

func is_class(value: String): return value == "SceneRemovedSignaler" or .is_class(value)
func get_class() -> String: return "SceneRemovedSignaler"


#### BUILT-IN ####

func _exit_tree() -> void:
	emit_signal("scene_destroyed_alert")


#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
