extends StaticBody2D
class_name Door

onready var animation_node = get_node_or_null("Animation")
onready var collision_node = get_node_or_null("CollisionShape2D")
onready var audio_node = get_node_or_null("AudioStreamPlayer")

export var open : bool = false setget set_open, is_open
export var need_delay : bool = false
export var open_delay : float = 0.0

var is_ready : bool = false

var timer_door

#### ACCESSORS ####

func is_class(value: String): return value == "Door" or .is_class(value)
func get_class() -> String: return "Door"

func set_open(value: bool):
	if !is_ready:
		yield(self, "ready")
	
	if collision_node != null && !collision_node.is_disabled() && value == true:
		open_door(true)
	else:
		open = value

func is_open() -> bool: return open


#### BUILT-IN ####

func _ready():
	is_ready = true

#### LOGIC ####

func open_door(instant : bool = false):
	#If the door has a delay before opening we will create the timer
	if need_delay:
		yield(get_tree().create_timer(open_delay), "timeout")
	
	if animation_node != null:
		if !instant:
			animation_node.play("Open")
		else:
			animation_node.set_frame(animation_node.get_sprite_frames().get_frame_count("Open") - 1)
	
	if collision_node != null:
		collision_node.set_disabled(true)
	
	if audio_node != null and !instant:
		audio_node.play()
	
	set_open(true)


func close_door(instant: bool = false) -> void:
	if animation_node != null:
		var sprite_frame = animation_node.get_sprite_frames()
		if !instant:
			if sprite_frame.has_animation("Close"):
				animation_node.play("Close")
			else:
				# If there is no Close animation, just play the Open animation backwards 
				animation_node.play("Open", true)
		else:
			if sprite_frame.has_animation("Close"):
				animation_node.set_frame(animation_node.get_sprite_frames().get_frame_count("Close") - 1)
			else:
				animation_node.set_frame(0)
	
	if collision_node != null:
		collision_node.set_disabled(false)
	
	if audio_node != null and !instant:
		audio_node.play()
	
	set_open(false)



#### SIGNAL RESPONSES ####
