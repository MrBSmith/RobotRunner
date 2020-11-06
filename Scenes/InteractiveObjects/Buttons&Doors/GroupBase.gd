extends Node2D
class_name BtnDoorsGroup

onready var children_array : Array = get_children()
var buttons_to_trigger : Array

var nb_buttons : int = 0
var nb_button_triggered : int = 0

func _ready():
	nb_buttons = 0
	for buttons in children_array:
		if buttons.is_class("DoorButton"):
			buttons.setup()
			nb_buttons += 1


func button_triggered():
	nb_button_triggered += 1
	if nb_button_triggered >= nb_buttons:
		for doors in children_array:
			if doors.is_class("Door"):
				if doors.need_delay:
					doors.timer_door.start()
				else:
					doors.open_door()
