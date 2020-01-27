extends Node2D

class_name LevelBase

var outside_screen_popup_scene = preload("res://Scenes/GUI/OutsideScreenPopup/OutsideScreenPopup.tscn")
var outside_screen_popup_node : Node


onready var camera_node = get_node("CameraSystem/Camera")
onready var GUI_node = get_node("CameraSystem/Camera/GUI")


func _ready():
	var _err = camera_node.connect("player_outside_screen", self, "on_player_outside_screen")


# Create the popup when a player exits the screen
func on_player_outside_screen(player : KinematicBody2D):
	outside_screen_popup_node = outside_screen_popup_scene.instance()
	GUI_node.call_deferred("add_child", outside_screen_popup_node)
	
	outside_screen_popup_node.player_node = player
	outside_screen_popup_node.camera_node = camera_node
	outside_screen_popup_node.rect_position.y = player.position.y