extends BreakableObjectBase

class_name XionCrate

const xion_collectable = preload("res://Scenes/InteractiveObjects/Collactables/XionCollactable/XionCollectable.tscn")

onready var sprites_group_node = $Sprites
onready var animation_player_node = $AnimationPlayer
onready var timer_node = $Timer
onready var base_anim_node = $Sprites/Base
onready var flash_node = $Flash
onready var area_node = $Area2D
onready var raycast_node = $RayCast2D

var animated_sprite_node_array : Array

var actor_destroying : Node
var tracked_player : Player = null

export var hitpoint : int = 3


#### ACCESSORS ####

func is_class(value: String):
	return value == "XionCrate" or .is_class(value)

func get_class() -> String:
	return "XionCrate"


#### BUILT-IN ####

func _ready():
	var _err = timer_node.connect("timeout", self, "on_timer_timeout")
	_err = base_anim_node.connect("animation_finished", self, "on_sprite_animation_finished")
	_err = area_node.connect("body_entered", self, "on_area_body_entered")
	_err = area_node.connect("body_exited", self, "on_area_body_exited")
	_err = raycast_node.connect("target_found", self, "on_raycast_target_found")
	
	for child in sprites_group_node.get_children():
		if child.is_class("AnimatedSprite"):
			animated_sprite_node_array.append(child)


func _physics_process(_delta):
	if tracked_player != null:
		raycast_node.search_for_target(tracked_player)


#### LOGIC ####


# Called by a character when its hitbox touches it
# Count the number of time the crate has been damaged
# If the hitpoints reaches 0 call the destroy method
func damage(actor_damaging: Node = null):
	hitpoint -= 1
	
	flash_node.play("Flash")
	
	if hitpoint == 0:
		destroy(actor_damaging)



# Called when the destruction happens, hide every non-destruction related sprite
func hide_crate():
	for sprite in animated_sprite_node_array:
		sprite.set_visible(false)


# Triggers every animation_sprite's animation
func start_sprite_anim():
	for anim in animated_sprite_node_array:
		anim.play()


# Triggers the vibration animation
func start_vibrate_anim():
	animation_player_node.play("Vibrate", -1, rand_range(0.8, 1.2))

# Genereate xion collactables
func generate_xion_collectable():
	if actor_destroying != null:
		for _i in range(5):
			var xion_collactable_node = xion_collectable.instance()
			xion_collactable_node.position = global_position
			owner.add_child(xion_collactable_node)
			xion_collactable_node.follow(actor_destroying)



#### SIGNAL RESPONSES ####

# Called when the sprite animation is over
# Reset every animated_sprite to its first frame 
func on_sprite_animation_finished():
	for anim in animated_sprite_node_array:
		anim.stop()
		anim.set_frame(0)


func on_area_body_entered(body : Node):
	if body is Player:
		tracked_player = body


func on_area_body_exited(body : Node):
	if body is Player:
		raycast_node.set_activate(false)
		tracked_player = null


func on_raycast_target_found(target: Node):
	if target is Player:
		EVENTS.emit_signal("approch_collactable", self)


# Called when the object has finished its breaking animation
func on_fadeout_finished():
	generate_xion_collectable()
	queue_free()


# Tiggers one of the two animations randomly and reset the timer to a random time
func on_timer_timeout():
	if randi() % 2 == 0:
		start_sprite_anim()
	else:
		start_vibrate_anim()
	
	timer_node.set_wait_time(rand_range(1.5, 3.0))


# Function called to destroy an object
func on_destruction(actor: Node = null):
	timer_node.stop()
	
	# Hide every non-destruction related sprite
	hide_crate()
	
	# Play the Xion explosion animation
	EVENTS.emit_signal("play_SFX", "xion_explosion", global_position)
	
	# Play the crate explosion and triggers the fade out
	base_anim_node.disconnect("animation_finished", self, "on_sprite_animation_finished")
	animation_player_node.play("FadeOut")
	
	actor_destroying = actor
