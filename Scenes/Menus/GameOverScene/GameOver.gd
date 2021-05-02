extends Control

onready var title_screen = "res://Scenes/Menus/ScreenTitle/ScreenTitle.tscn"
onready var children_array = get_children()
onready var timer_node = get_node("Timer")
onready var quit_text_node = get_node("RTL_Quit")
onready var restart_text_node = get_node("RTL_Retry")

const CANCEL_KEY = "ui_cancel"
const RESTART_KEY = "game_restart"

var game_node : Node

var QUIT_TEXT : String = "[center][wave amp=50 freq=7]PRESS " + InputMap.get_action_list("ui_cancel")[0].as_text() + " TO RETURN TO MENU[/wave][/center]"
var RESTART_TEXT : String = "[center][wave amp=85 freq=3]PRESS " + InputMap.get_action_list("game_restart")[0].as_text() + " TO RETRY [/wave][/center]"
var player_action_on_gameover : String


func _ready():
	var _err = timer_node.connect("timeout", self, "on_timer_timeout")
	quit_text_node.bbcode_text = QUIT_TEXT
	restart_text_node.bbcode_text = RESTART_TEXT


func _input(_event):
	if(Input.is_action_just_pressed(CANCEL_KEY)):
		player_action_on_gameover = "MENU"
		timer_node.start()
	if(Input.is_action_just_pressed(RESTART_KEY)):
		player_action_on_gameover = "RESTART"
		timer_node.start()


# Action to do when the timer is over
func on_timer_timeout():
	match(player_action_on_gameover):
		"MENU":
			var _err = get_tree().change_scene(title_screen)
		"RESTART":
			GAME.goto_last_level()
	
	queue_free()
