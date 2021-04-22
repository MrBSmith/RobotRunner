extends StaticBody2D
class_name Door

onready var animation_node = get_node_or_null("Animation")
onready var collision_node = get_node_or_null("CollisionShape2D")
onready var audio_node = get_node_or_null("AudioStreamPlayer")

export var open : bool = false setget set_open, is_open
export var need_delay : bool = false
export var open_delay : float = 0.0

var timer_door

#### ACCESSORS ####

func is_class(value: String): return value == "Door" or .is_class(value)
func get_class() -> String: return "Door"

func set_open(value: bool):
	if collision_node != null && !collision_node.is_disabled():
		open_door(true)
	else:
		open = value

func is_open() -> bool: return open


#### BUILT-IN ####

func _ready():
	if !is_open():
		if need_delay:  		#If the door has a delay before opening we will create the timer
								#to open it after an amount of time
			timer_door = Timer.new()
			add_child(timer_door)
			timer_door.connect("timeout", self, "_on_doortimer_timeout")
			timer_door.set_wait_time(open_delay)
			timer_door.set_one_shot(true)


#### LOGIC ####

func open_door(instant : bool = false):
	if animation_node != null:
		if !instant:
			animation_node.play("default")
		else:
			animation_node.set_frame(animation_node.get_sprite_frames().get_frame_count("default")-1)
	
	if collision_node != null:
		collision_node.set_disabled(true)
	
	if audio_node != null and !instant:
		audio_node.play()
	
	set_open(true)

#### SIGNAL RESPONSES ####

func _on_doortimer_timeout():
	open_door()
