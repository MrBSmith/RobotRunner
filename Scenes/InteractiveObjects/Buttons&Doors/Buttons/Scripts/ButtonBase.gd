tool
extends StaticBody2D
class_name DoorButton

signal triggered
signal untriggered

onready var animation_node = get_node("Animation")
onready var area2D_node = get_node("Area2D")
onready var collision_shape_node = get_node("CollisionShape2D")
onready var button_line_door = get_node_or_null("ButtonLineDoor")

var collision_shape_initial_pos : Vector2
var is_ready : bool = false

export var push_delay : float = 0.0
export var pushed : bool = false setget set_pushed, is_pushed

#### ACCESSORS ####

func is_class(value: String): return value == "DoorButton" or .is_class(value)
func get_class() -> String: return "DoorButton"

func set_pushed(value: bool):
	if !is_ready:
		yield(self, "ready")
		if collision_shape_node != null && !collision_shape_node.is_disabled() && value:
			trigger(true, true)
	
	pushed = value

func is_pushed() -> bool: return pushed

#### BUILT-IN ####


func _ready():
	var _err = area2D_node.connect("body_entered", self, "_on_body_entered")
	_err = animation_node.connect("frame_changed", self, "_on_frame_changed")
	_err = animation_node.connect("animation_finished", self, "_on_animation_finished")
	_err = connect("triggered", self, "_on_button_triggered")
	_err = connect("untriggered", self, "_on_button_untriggered")
	
	collision_shape_initial_pos = collision_shape_node.position
	is_ready = true


#### LOGIC ####



func trigger(trigger: bool = true, instant: bool = false):
	if !instant:
		if push_delay != 0.0:
			yield(get_tree().create_timer(push_delay), "timeout")
		animation_node.play("Trigger", !trigger)
	else:
		if trigger:
			animation_node.set_frame(animation_node.get_sprite_frames().get_frame_count("Trigger") - 1)
		else:
			animation_node.set_frame(0)



#### SIGNAL RESPONSES ####


# Play the animation when a player touch the button
func _on_body_entered(body):
	if body.is_class("ActorBase"):
		trigger()


# When the animation is finished, emit the signal, and disable the collision shape
func _on_animation_finished():
	var current_frame = animation_node.get_frame()
	var triggered = current_frame != 0
	set_pushed(triggered)
	
	if triggered:
		emit_signal("triggered")
	else:
		emit_signal("untriggered")
	
	collision_shape_node.set_disabled(triggered)


# Move the shape at the same time as the sprite
func _on_frame_changed():
	var current_frame = animation_node.get_frame()
	if current_frame == 0:
		animation_node.emit_signal("animation_finished")
		animation_node.stop()
	
	var new_pos = collision_shape_initial_pos
	new_pos.y += (animation_node.get_frame() * 2) + 1
	collision_shape_node.set_position(new_pos)


func _on_button_triggered():
	if is_instance_valid(button_line_door):
		button_line_door.set_active(true)

func _on_button_untriggered():
	if is_instance_valid(button_line_door):
		button_line_door.set_active(false)
