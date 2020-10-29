extends StaticBody2D
class_name Door

onready var animation_node = get_node_or_null("Animation")
onready var collision_node = get_node_or_null("CollisionShape2D")
onready var audio_node = get_node_or_null("AudioStreamPlayer")

export var is_open : bool = false
export var need_delay : bool = false
export var open_delay : float = 0.0

var timer_door

#### ACCESSORS ####

func is_class(value: String):
	return value == "Door" or .is_class(value)

func get_class() -> String:
	return "Door"


#### BUILT-IN ####

func _ready():
	if need_delay:  		#If the door has a delay before opening we will create the timer
							#to open it after an amount of time
		timer_door = Timer.new()
		add_child(timer_door)
		timer_door.connect("timeout", self, "_on_doortimer_timeout")
		timer_door.set_wait_time(open_delay)


#### LOGIC ####

func open_door():
	if animation_node != null:
		animation_node.play("default")
	
	if collision_node != null:
		collision_node.set_disabled(true)
	
	if audio_node != null:
		audio_node.play()
	
	is_open = true

	is_open = true

#### SIGNAL RESPONSES ####

func _on_doortimer_timeout():
	open_door()
