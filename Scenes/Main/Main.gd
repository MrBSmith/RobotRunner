extends Node2D

onready var game_playing_node = get_node("GamePlaying")

var game_over_scene = preload("res://Scenes/GUI/GameOverScene/GameOver.tscn")
var game_over_node : Node


# Triggers the game over 
func on_gameover():
	game_playing_node.queue_free()
	game_over_node = game_over_scene.instance()
	add_child(game_over_node)