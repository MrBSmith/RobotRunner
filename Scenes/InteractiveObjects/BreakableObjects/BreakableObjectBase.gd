extends RigidBody2D

class_name BreakableObjectBase

onready var sprite_node = get_node_or_null("Sprite")
onready var collision_shape_node = get_node_or_null("CollisionShape2D")
onready var awake_area_node = get_node_or_null("AwakeArea")
onready var audio_node = get_node_or_null("AudioStreamPlayer")
onready var particule_node = get_node_or_null("Particles2D")

export (int, 5, 40) var nb_debris = 10
export (float, 10.0, 500.0) var explosion_impulse = 80.0
export (float, 0.0, 1.0) var explosion_impulse_modifier = 0.7

export var floor_obj : bool = true

signal destroyed

#### ACCESSORS ####

func is_class(value: String):
	return value == "BreakableObjectBase" or .is_class(value)

func get_class() -> String:
	return "BreakableObjectBase"


#### BUILT-IN ####


func _ready():
	var _err = connect("sleeping_state_changed", self, "on_sleeping_state_changed")


#### LOGIC ####


# Called by a character when its hitbox touches it
# By default: call the destroy method
func damage(actor_damaging : Node = null):
	destroy(actor_damaging)


# Function called to destroy an object
# Triggers every commun stuff happening at the destruction of an object,
# If you want to add more stuff happining overwrite the on_destruction method 
# Also warn every body in the area that this one was destroyed, and then queue free
func destroy(actor_destroying : Node = null):
	if audio_node:
		audio_node.play()
		
	if sprite_node:
		sprite_node.call_deferred("set_visible", false)
	
	if collision_shape_node:
		collision_shape_node.call_deferred("set_disabled", true)
	
	if particule_node:
		particule_node.set_emitting(true)
	
	call_deferred("set_mode", RigidBody2D.MODE_STATIC)
	EVENTS.emit_signal("scatter_object", self, nb_debris, explosion_impulse)
	EVENTS.emit_signal("scatter_object", self, int(nb_debris / 6), explosion_impulse * explosion_impulse_modifier)
	
	awake_nearby_bodies()
	
	emit_signal("destroyed")
	on_destruction(actor_destroying)


# Awake bodies in the area, so they can fall, if needed
func awake_nearby_bodies():
	if awake_area_node == null : return
	
	var bodies_nearby = awake_area_node.get_overlapping_bodies()
	for body in bodies_nearby:
		if body is PhysicsBody2D && body != self:
			if body.has_method("awake"):
				body.call_deferred("awake")


# Awake this instance, generaly called by a sourrounding body been destoyed
func awake():
	if get_mode() != RigidBody2D.MODE_STATIC:
		return
	
	awake_nearby_bodies()
	set_mode(RigidBody2D.MODE_RIGID)
	set_sleeping(false)
	set_physics_process(true)


#### SIGNAL RESPONSES ####

# Set the mode back to static mode when the body is sleeping
func on_sleeping_state_changed():
	if get_mode() == RigidBody2D.MODE_RIGID && is_sleeping():
		call_deferred("set_mode", RigidBody2D.MODE_STATIC)


# Virtual method: called by destroy
# you can overwrite it to add stuff happening on the destruction of the object
# or if you need to redertemine where the queue_free happens
func on_destruction(_actor_destroying: Node = null):
	queue_free()
