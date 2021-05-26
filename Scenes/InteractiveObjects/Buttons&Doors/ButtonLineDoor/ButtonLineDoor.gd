tool
extends Line2D
class_name ButtonLineDoor

onready var initial_color = get_default_color()

var active : bool = false setget set_active
export var door_node_path : String = "" setget set_door_node_path, get_door_node_path

signal active_changed(new_value)

#### ACCESSORS ####

func is_class(value: String): return value == "ButtonLineDoor" or .is_class(value)
func get_class() -> String: return "ButtonLineDoor"

func set_active(value: bool): 
	if active != value:
		active = value
		emit_signal("active_changed", active)

func set_door_node_path(value : String): door_node_path = value
func get_door_node_path() -> String: return door_node_path

#### BUILT-IN ####

func _ready() -> void:
	if !Engine.editor_hint:
		var _err = connect("active_changed", self, "_on_active_changed")
		_on_active_changed(active)

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_active_changed(new_value: bool) -> void:
	if new_value == false:
		set_default_color(initial_color.blend(Color.gray))
	else:
		set_default_color(initial_color)
