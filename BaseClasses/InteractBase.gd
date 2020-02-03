extends Node2D

class_name InteractBase

export var group_name : String

onready var interact_nodes_array = get_tree().get_nodes_in_group(group_name)
onready var area2D_node = get_node("Area2D")

var players_nodes_array : Array

func _ready():
	var _err
	_err = area2D_node.connect("body_entered", self, "on_body_entered")
	_err = area2D_node.connect("body_exited", self, "on_body_exited")


func on_body_entered(body):
	if body in players_nodes_array and body.get_node("States/Action").interact_node != self:
		body.get_node("States/Action").interact_node = self

# Whenever a character exits the area of this interact object, set his interact reference to null
func on_body_exited(body):
	if body in players_nodes_array:
		var is_colliding = false
		
		# When the character get out of the area, check if it's because he left, or because he entered another one
		for interact_node in interact_nodes_array:
			if interact_node.overlaps_body(body) == true and interact_node != self:
				is_colliding = true
		
		# If he left, set his teleport_node value to null
		if is_colliding == false:
			body.get_node("States/Action").interact_node = null
