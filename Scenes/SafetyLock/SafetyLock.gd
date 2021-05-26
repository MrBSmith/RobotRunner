extends Node2D
class_name SafetyLock

onready var area_node = $Area2D
onready var exit_area = $ExitArea
onready var in_door = $InDoor
onready var out_door = $OutDoor
onready var screen_sprite = $Screen
onready var animation_player = $AnimationPlayer
onready var screen_timer = $ScreenTimer

export var wanted_class : String = "ActorBase"
export var one_way : bool = false

var has_been_triggered = false

#### ACCESSORS ####

func is_class(value: String): return value == "SafetyLock" or .is_class(value)
func get_class() -> String: return "SafetyLock"


#### BUILT-IN ####

func _ready() -> void:
	var __ = area_node.connect("body_entered", self, "_on_body_entered")
	__ = area_node.connect("body_exited", self, "_on_body_exited")
	__ = screen_timer.connect("timeout", self, "_on_screen_timer_timeout")
	__ = animation_player.connect("animation_finished", self, "_on_animation_player_animation_finished")
	
	play_default_screen_animation()
	
	if !one_way:
		exit_area.queue_free()
	else:
		exit_area.waited_class = wanted_class
		exit_area.connect("area_triggered", self, "_on_exit_area_triggered")
		var out_door_pos = out_door.get_position()
		
		exit_area.position.x *= sign(out_door_pos.x)


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


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_body_entered(_body: Node2D) -> void:
	if !animation_player.is_playing():
		animation_player.play("LaserMovement")


func _on_animation_player_animation_finished(_anim_name: String) -> void:
	var bodies = area_node.get_overlapping_bodies()
	var nb_robots = count_robots(bodies)
	
	if nb_robots > 1 or !is_wanted_robot(bodies):
		screen_sprite.play("Invalid")
	else:
		screen_sprite.play("Valid")
		in_door.open(!in_door.is_opened())
		out_door.open(!out_door.is_opened())
		has_been_triggered = true
	
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


func _on_exit_area_triggered(_body: Node2D):
	if has_been_triggered:
		in_door.open(false)
		out_door.open(false)
	else:
		exit_area.set_triggered(false)
