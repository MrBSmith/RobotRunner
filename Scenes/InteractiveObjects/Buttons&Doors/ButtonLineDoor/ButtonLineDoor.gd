extends Line2D

onready var initial_color = get_default_color()

var active : bool = false setget set_active

signal active_changed(new_value)

#### ACCESSORS ####

func is_class(value: String): return value == "" or .is_class(value)
func get_class() -> String: return ""

func set_active(value: bool): 
	if active != value:
		active = value
		emit_signal("active_changed", active)

#### BUILT-IN ####

func _ready() -> void:
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
