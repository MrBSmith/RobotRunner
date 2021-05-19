extends StaticBody2D
class_name DoorButton

signal triggered
signal untriggered

onready var animation_node = get_node("Animation")
onready var area2D_node = get_node("Area2D")
onready var collision_shape_node = get_node("CollisionShape2D")

var collision_shape_initial_pos : Vector2
var is_ready : bool = false

export var push : bool = false setget set_push, is_push

#### ACCESSORS ####

func is_class(value: String): return value == "DoorButton" or .is_class(value)
func get_class() -> String: return "DoorButton"

func set_push(value: bool):
	if !is_ready:
		yield(self, "ready")
		if collision_shape_node != null && !collision_shape_node.is_disabled() && value:
			trigger(true, true)
	
	push = value

func is_push() -> bool: return push

#### BUILT-IN ####


func _ready():
	var _err = area2D_node.connect("body_entered", self, "_on_body_entered")
	_err = animation_node.connect("frame_changed", self, "_on_frame_changed")
	_err = animation_node.connect("animation_finished", self, "_on_animation_finished")
	
	collision_shape_initial_pos = collision_shape_node.position
	is_ready = true


#### LOGIC ####



func trigger(trigger: bool = true, instant: bool = false):
	if !instant:
		animation_node.play("Trigger", !trigger)
	else:
		if trigger:
			animation_node.set_frame(animation_node.get_sprite_frames().get_frame_count("Trigger") - 1)
		else:
			animation_node.set_frame(0)
	
	collision_shape_node.call_deferred("set_disabled", trigger)



#### SIGNAL RESPONSES ####


# Play the animation when a player touch the button
func _on_body_entered(body):
	if body.is_class("ActorBase"):
		trigger()


# When the animation is finished, emit the signal, and disable the collision shape
func _on_animation_finished():
	var current_frame = animation_node.get_frame()
	var triggered = current_frame != 0
	
	if triggered:
		emit_signal("triggered")
	else:
		emit_signal("untriggered")
	
	collision_shape_node.set_disabled(triggered)
	set_push(triggered)


# Move the shape at the same time as the sprite
func _on_frame_changed():
	var current_frame = animation_node.get_frame()
	if current_frame == 0:
		animation_node.emit_signal("animation_finished")
		animation_node.stop()
	
	var new_pos = collision_shape_initial_pos
	new_pos.y += (animation_node.get_frame() * 2) + 2
	collision_shape_node.set_position(new_pos)
