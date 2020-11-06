extends StaticBody2D
class_name DoorButton

signal button_trigger

onready var animation_node = get_node("Animation")
onready var area2D_node = get_node("Area2D")
onready var collision_shape_node = get_node("CollisionShape2D")

var collision_shape_initial_pos : Vector2

export var is_push : bool = false

#### ACCESSORS ####

func is_class(value: String):
	return value == "DoorButton" or .is_class(value)

func get_class() -> String:
	return "DoorButton"


#### BUILT-IN ####


func _ready():
	collision_shape_initial_pos = collision_shape_node.position
	if is_push:
		animation_node.set_frame(animation_node.get_sprite_frames().get_frame_count("default")-1)
		collision_shape_node.set_disabled(true)
		
#### LOGIC ####


func setup():
	# Connect signals
	var _err = connect("button_trigger", get_parent(), "button_triggered")
	_err = area2D_node.connect("body_entered", self, "on_body_entered")
	_err = animation_node.connect("frame_changed", self, "on_frame_change")
	_err = animation_node.connect("animation_finished", self, "on_animation_finished")

#### SIGNAL RESPONSES ####


# Play the animation when a player touch the button
func on_body_entered(body):
	if body.is_class("Player"):
		animation_node.play()


# When the animation is finished, emit the signal, and disable the collision shape
func on_animation_finished():
	emit_signal("button_trigger")
	collision_shape_node.set_disabled(true)
	is_push = true


# Move the shape at the same time as the sprite
func on_frame_change():
	var new_pos = collision_shape_initial_pos
	new_pos.y += (animation_node.get_frame() * 2) + 2
	collision_shape_node.set_position(new_pos)
