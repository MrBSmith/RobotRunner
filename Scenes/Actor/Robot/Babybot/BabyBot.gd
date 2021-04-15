extends NPCRobotBase
class_name BabyBot

onready var bubble_scene = preload("res://Scenes/GUI/Bubble/Bubble.tscn")

export var action_name_bubble : String = ""
export var player_id : int = 0 setget set_player_id, get_player_id

onready var animation_player_node = $AnimationPlayer


#### ACCESSORS ####

func set_player_id(value : int):
	player_id = value

func get_player_id() -> int:
	return player_id


#### BUILT-IN ####

func _ready():
	var _err = animation_player_node.connect("animation_finished", self, "on_animation_finished")

#### LOGIC ####

func tuto_bubble(action: String = ""):
	var action_name = $Input.get_input(action)
	var key_array = InputMap.get_action_list(action_name)
	
	var bubble_node = bubble_scene.instance()
	bubble_node.button_name = key_array[0].as_text()
	bubble_node.set_position(Vector2(6, -28))
	call_deferred("add_child", bubble_node)

#### VIRTUALS ####


#### INPUTS ####


#### SIGNAL RESPONSES ####

func on_animation_finished(anim_name: String):
	if anim_name == "Overheat":
		destroy()
