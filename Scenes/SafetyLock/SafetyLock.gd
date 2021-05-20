extends Node2D
class_name SafetyLock

onready var area_node = $Area2D
onready var in_door = $InDoor
onready var out_door = $OutDoor

export var wanted_class : String = "ActorBase"

#### ACCESSORS ####

func is_class(value: String): return value == "SafetyLock" or .is_class(value)
func get_class() -> String: return "SafetyLock"


#### BUILT-IN ####

func _ready() -> void:
	var __ = area_node.connect("body_entered", self, "_on_body_entered")

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_body_entered(body: Node2D) -> void:
	if body.is_class(wanted_class):
		in_door.open(!in_door.is_openned())
		out_door.open(!out_door.is_openned())
