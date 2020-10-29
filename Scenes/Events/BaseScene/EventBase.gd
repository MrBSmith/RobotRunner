extends Node2D

class_name Event

export var triggers_on_level_start : bool = false
export var event_disabled : bool = false

var triggers_area_array : Array = []

func is_class(value: String):
	return value == "Event" or .is_class(value)

func get_class() -> String:
	return "Event"

# Get every TriggerArea child of this node and store them in the triggers_area_array
# Also connect every child's area_triggered signal
func _ready():
	if triggers_on_level_start:
		event()
		for child in get_children():
			if child.is_class("TriggerArea"):
				child.queue_free()
	else:
		for child in get_children():
			if child.is_class("TriggerArea"):
				triggers_area_array.append(child)
				var _err = child.connect("area_triggered", self, "on_area_triggered")


# Each time an area is triggered, check if every area is triggered
# If it is the case, call the event
func on_area_triggered():
	if are_every_area_triggered():
		event()


# Check if every area have been triggered, return true if yes, false if not
func are_every_area_triggered() -> bool:
	var value = true
	for area in triggers_area_array:
		if !area.is_triggered():
			value = false
	
	return value


# Here is what happens when every area has been triggered
func event():
	queue_free()
