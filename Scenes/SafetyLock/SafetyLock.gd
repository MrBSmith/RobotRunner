extends Node2D
class_name SafetyLock


onready var wrong_sound = $WrongSound
onready var valid_sound = $ValidSound
onready var area_node = $Area2D
onready var exit_area_trigger = $ExitAreaTrigger
onready var in_door = $InDoor
onready var out_door = $OutDoor
onready var screen_sprite = $Screen
onready var animation_player = $AnimationPlayer
onready var screen_timer = $ScreenTimer
onready var entrance = in_door

export var wanted_class : String = "ActorBase"
export var one_way : bool = false

var has_been_triggered = false

#warning-ignore:unused_signal
signal laser_animation_finished

#### ACCESSORS ####

func is_class(value: String): return value == "SafetyLock" or .is_class(value)
func get_class() -> String: return "SafetyLock"


#### BUILT-IN ####

func _ready() -> void:
	var __ = area_node.connect("body_entered", self, "_on_body_entered")
	__ = area_node.connect("body_exited", self, "_on_body_exited")
	__ = screen_timer.connect("timeout", self, "_on_screen_timer_timeout")
	__ = connect("laser_animation_finished", self, "_on_laser_animation_finished")
	
	play_default_screen_animation()
	
	if !one_way:
		exit_area_trigger.queue_free()
	else:
		exit_area_trigger.wanted_class = wanted_class
		exit_area_trigger.connect("triggered", self, "_on_exit_area_triggered")
		var out_door_pos = out_door.get_position()
		
		exit_area_trigger.position.x *= sign(out_door_pos.x)


#### VIRTUALS ####



#### LOGIC ####


func play_default_screen_animation() -> void:
	var screen_sprite_frame = screen_sprite.get_sprite_frames()
	
	if screen_sprite_frame!= null && screen_sprite_frame.has_animation(wanted_class):
		screen_sprite.play(wanted_class)


func count_robots(bodies_array: Array) -> int:
	var count = 0
	for body in bodies_array:
		if body.is_class("Player"):
			count += 1
	return count


func is_wanted_robot(bodies_array: Array) -> bool:
	for body in bodies_array:
		if body.is_class(wanted_class):
			return true
	return false


func valid() -> void:
	screen_sprite.play("Valid")
	valid_sound.play()
	var door_to_open = in_door if entrance == out_door else out_door
	door_to_open.open(true)
	has_been_triggered = true


func invalid() -> void:
	screen_sprite.play("Invalid")
	entrance.open(true)
	wrong_sound.play()



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_body_entered(_body: Node2D) -> void:
	var door_to_close = in_door if in_door.is_opened() else out_door
	if !animation_player.is_playing() && door_to_close.is_opened():
		entrance = door_to_close
		door_to_close.open(false)
		yield(door_to_close, "animation_finished")
		
		animation_player.play("LaserMovement")


func _on_laser_animation_finished() -> void:
	var bodies = area_node.get_overlapping_bodies()
	var nb_robots = count_robots(bodies)
	
	if nb_robots > 1 or !is_wanted_robot(bodies):
		invalid()
	else:
		valid()
	
	if nb_robots == 0:
		screen_timer.start()


func _on_body_exited(body: Node2D) -> void:
	var bodies = area_node.get_overlapping_bodies()
	
	for overlapping_body in bodies:
		if overlapping_body == body:
			continue
		if overlapping_body.is_class("Player"):
			return
	
	screen_timer.start()


func _on_screen_timer_timeout():
	play_default_screen_animation()


func _on_exit_area_triggered():
	if has_been_triggered:
		in_door.open(false)
		out_door.open(false)
		exit_area_trigger.set_enabled(false)
