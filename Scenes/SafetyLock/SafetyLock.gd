extends Node2D
class_name SafetyLock

onready var area_node = $Area2D
onready var in_door = $InDoor
onready var out_door = $OutDoor
onready var screen_sprite = $Screen
onready var animation_player = $AnimationPlayer
onready var screen_timer = $ScreenTimer

export var wanted_class : String = "ActorBase"

#### ACCESSORS ####

func is_class(value: String): return value == "SafetyLock" or .is_class(value)
func get_class() -> String: return "SafetyLock"


#### BUILT-IN ####

func _ready() -> void:
	var __ = area_node.connect("body_entered", self, "_on_body_entered")
	__ = area_node.connect("body_exited", self, "_on_body_exited")
	__ = screen_timer.connect("timeout", self, "_on_screen_timer_timeout")
	
	play_default_screen_animation()


#### VIRTUALS ####



#### LOGIC ####


func play_default_screen_animation() -> void:
	var screen_sprite_frame = screen_sprite.get_sprite_frames()
	
	if screen_sprite_frame!= null && screen_sprite_frame.has_animation(wanted_class):
		screen_sprite.play(wanted_class)


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_body_entered(body: Node2D) -> void:
	animation_player.play("LaserMovement")
	yield(animation_player, "animation_finished")
	
	if body.is_class(wanted_class):
		screen_sprite.play("Valid")
		in_door.open(!in_door.is_openned())
		out_door.open(!out_door.is_openned())
	else:
		screen_sprite.play("Invalid")


func _on_body_exited(_body: Node2D) -> void:
	screen_timer.start()


func _on_screen_timer_timeout():
	play_default_screen_animation()
