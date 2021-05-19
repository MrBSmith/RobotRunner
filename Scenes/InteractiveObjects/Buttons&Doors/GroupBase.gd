extends Node2D
class_name ButtonDoorGroup

var buttons_to_trigger : Array

var nb_buttons : int = 0
var nb_button_triggered : int = 0

func _ready():
	nb_buttons = 0
	for button in get_children():
		if button.is_class("DoorButton"):
			nb_buttons += 1
			var _err = button.connect("triggered", self, "_on_button_triggered")
			_err = button.connect("untriggered", self, "_on_button_untriggered")


func open_all_doors(open: bool = true) -> void:
	for child in get_children():
		if child.is_class("Door"):
			child.open(open)


#### SIGNAL RESPONSES ####

func _on_button_triggered() -> void:
	nb_button_triggered += 1
	if nb_button_triggered >= nb_buttons:
		open_all_doors()


func _on_button_untriggered() -> void:
	nb_button_triggered -= 1
	open_all_doors(false)
