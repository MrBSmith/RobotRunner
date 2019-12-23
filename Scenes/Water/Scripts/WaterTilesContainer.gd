extends Node2D

var S_IceBlocks_node : Node2D
var M_IceBlocks_node : Node2D

onready var water_tiles_array = get_children()

func setup():
	for water_tile in water_tiles_array:
		water_tile.S_IceBlocks_node = S_IceBlocks_node
		water_tile.M_IceBlocks_node = M_IceBlocks_node