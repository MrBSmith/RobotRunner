extends Node2D
class_name ButtonDoorGroup


#### BUILT-IN ####

func _ready():
	for button in get_children():
		if button.is_class("DoorButton"):
			var _err = button.connect("triggered", self, "_on_button_triggered")
			_err = button.connect("untriggered", self, "_on_button_untriggered")


#### LOGIC ####


func open_all_doors(open: bool = true) -> void:
	for child in get_children():
		if child.is_class("Door"):
			child.open(open)


func are_all_button_triggered() -> bool:
	for child in get_children():
		if child.is_class("DoorButton"):
			if !child.is_push():
				return false
	return true


#### SIGNAL RESPONSES ####

func _on_button_triggered() -> void:
	if are_all_button_triggered():
		open_all_doors()


func _on_button_untriggered() -> void:
	open_all_doors(false)
