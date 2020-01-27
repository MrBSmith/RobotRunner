extends Node2D

const level1 = preload("res://Scenes/Levels/Level1.tscn")
#const debug_level = preload("res://Scenes/Levels/LevelDebug.tscn")

var level1_node
#var debug_level_node

func _ready():
	level1_node = level1.instance()
	add_child(level1_node)
#	debug_level_node = debug_level.instance() 
#	add_child(debug_level_node)