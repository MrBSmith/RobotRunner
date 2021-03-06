extends StaticBody2D
class_name Door

onready var animation_node = get_node_or_null("Animation")
onready var collision_node = get_node_or_null("CollisionShape2D")
onready var audio_node = get_node_or_null("AudioStreamPlayer")

export var opened : bool = false setget set_opened, is_opened
export var need_delay : bool = false
export var open_delay : float = 0.0

var is_ready : bool = false

var timer_door

signal opened_changed(open)

#### ACCESSORS ####

func is_class(value: String): return value == "Door" or .is_class(value)
func get_class() -> String: return "Door"

func set_opened(value: bool):
	if !is_ready:
		yield(self, "ready")
		if value == true:
			open(true, true)
	
	var value_changed : bool = value != opened
	opened = value
	if value_changed:
		emit_signal("opened_changed", opened)

func is_opened() -> bool: return opened


#### BUILT-IN ####

func _ready():
	is_ready = true


#### LOGIC ####

func open(open: bool = true, instant : bool = false):
	if open == opened:
		return

	if need_delay:
		yield(get_tree().create_timer(open_delay), "timeout")

	if animation_node != null:
		var sprite_frame = animation_node.get_sprite_frames()
		var has_close_anim = sprite_frame.has_animation("Close")
		var anim_to_play = "Open" if open or !has_close_anim else "Close"
		var play_backwards : bool = !has_close_anim && !open

		if !instant:
			animation_node.play(anim_to_play, play_backwards)
			if play_backwards:
				var _err = animation_node.connect("frame_changed", self, "_on_animation_frame_changed")
		else:
			if play_backwards:
				animation_node.set_frame(0)
			else:
				var last_frame = sprite_frame.get_frame_count(anim_to_play) - 1
				animation_node.set_frame(last_frame)

	if collision_node != null:
		collision_node.call_deferred("set_disabled", open)

	if audio_node != null and !instant:
		audio_node.play()

	if !instant:
		set_opened(open)


#### SIGNAL RESPONSES ####

func _on_animation_frame_changed():
	if animation_node.get_frame() == 0:
		animation_node.disconnect("frame_changed", self, "_on_animation_frame_changed")
		animation_node.emit_signal("animation_finished")
