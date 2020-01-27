extends Node2D

onready var children_array : Array = get_children()

func _ready():
	for children in children_array:
		if children.get_index() != 0:
			children_array[0].door_node_array.append(children)
	children_array[0].setup()