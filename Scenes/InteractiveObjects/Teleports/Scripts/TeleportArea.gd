extends Area2D

onready var layer_up_teleport_node: Node
onready var layer_down_teleport_node: Node
onready var teleport_master_node = get_parent()

var teleporters_array : Array
var players_node_array : Array

func _ready():
	add_to_group("InteractivesObjects")
	var _err
	_err = connect("body_entered", self, "on_body_entered")
	_err = connect("body_exited", self, "on_body_exited")
	teleporters_array = teleport_master_node.get_children()
	var i = get_index()
	
	var prec = i - 1
	if prec < 0:
		prec = len(teleporters_array) - 1
	var suiv = i + 1
	if suiv > len(teleporters_array) - 1:
		suiv = 0
	
	layer_up_teleport_node = teleporters_array[prec]
	layer_down_teleport_node = teleporters_array[suiv]


func set_players_array():
	players_node_array = get_tree().get_nodes_in_group("Players")


# Whenever a character enters the area of this teleport, this method gives him the referecence to this node
func on_body_entered(body):
	if body in players_node_array and body.get_node("LayerChange").teleport_node != self:
		body.get_node("LayerChange").teleport_node = self


# Whenever a character exits the area of this teleport, set his teleport_node reference to null
func on_body_exited(body):
	if body in players_node_array:
		var is_colliding = false
		
		# When the character get out of the area, check if it's because he left, or because he did teleport
		for teleporter in teleporters_array:
			if teleporter.overlaps_body(body) == true and teleporter != self:
				is_colliding = true
		
		# If he left, set his teleport_node value to null
		if is_colliding == false:
			body.get_node("LayerChange").teleport_node = null


# Teleport the player the the right destination teleporter
func teleport_layer(character : Node):
	
	# Get the size of the character's collision shape
	var y_offset = character.find_node("CollisionShape2D").get_shape().get_extents().y
	var teleport_pos : Vector2 = character.global_position
	
	# Check if one player is already on the teleport or not
	if len(layer_up_teleport_node.get_overlapping_bodies()) <= 0 :
		teleport_pos = layer_up_teleport_node.global_position
	elif len(layer_down_teleport_node.get_overlapping_bodies()) <= 0:
		teleport_pos = layer_down_teleport_node.global_position
	
	teleport_pos.y -= y_offset
	character.set_position(teleport_pos)
