tool
extends WorldMapMovingElement
class_name WorldMapCursor

# warnings-disable

onready var sprite_container = $SpriteContainer

signal idle_animation_finished
signal rotation_animation_finished


#### ACCESSORS ####

func is_class(value: String): return value == "WorldMapCursor" or .is_class(value)
func get_class() -> String: return "WorldMapCursor"


#### BUILT-IN ####

func _ready() -> void:
	var __ = connect("path_finished", self, "_on_path_finished")

#### VIRTUALS ####



#### LOGIC ####

func move_to_level(level_node: LevelNode, interpol: bool = true):
	var current_state_name = $StatesMachine.get_state_name()
	
	if current_state_name == "Move":
		return
	
	$StatesMachine.set_state("Move")
	match(current_state_name):
		"Idle": yield(self, "idle_animation_finished")
		"Rotate": yield(self, "rotation_animation_finished")
	
	.move_to_level(level_node, true)


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_path_finished():
	$StatesMachine.set_state("Idle")
