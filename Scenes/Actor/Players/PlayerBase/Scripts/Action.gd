extends PlayerStateBase

class_name ActionBase

### ACTION STATE  ###

var interact_able_array : Array
var inputs_node : Node

export var breakable_type_array : PoolStringArray
export var interactables : PoolStringArray

var action_hitbox_node : Area2D
var hit_box_shape : Node

var has_touch : bool = false

onready var audio_node = get_node("AudioStreamPlayer")

# Setup, called by the parent when it is ready
func _ready():
	yield(owner, "ready")
	action_hitbox_node = owner.get_node("ActionHitBox")
	inputs_node = owner.get_node("Inputs")
	var _err = animation_node.connect("animation_finished", self, "on_animation_finished")
	hit_box_shape = action_hitbox_node.get_node("CollisionShape2D")


func update(_host, _delta):
	if !has_touch:
		damage()


# When the actor enters action state: set active the hit box, and play the right animation
func enter_state(_host):
	# Play the animation
	animation_node.play(self.name)
	
	# Play the audio
	audio_node.play()
	
	# Set the hitbox active
	hit_box_shape.set_disabled(false)


# When the actor exits action state: set unactive the hit box and triggers the interaction if necesary
func exit_state(_host):
	interact()
	
	# Reset the was broke bool, for the next use of the action state
	has_touch = false
	
	# Set the hitbox inactive
	hit_box_shape.set_disabled(true)


# Damage a block if it is in the hitbox area, and if his type correspond to the current robot breakable type
func damage():
	var bodies_in_hitbox = action_hitbox_node.get_overlapping_bodies()
	for body in bodies_in_hitbox:
		if body.get_class() in owner.breakable_type_array:
			var average_pos = (body.global_position + action_hitbox_node.global_position) / 2
			damage_body(body, average_pos)


func interact():
	# Get every area in the hitbox area
	var interact_areas = action_hitbox_node.get_overlapping_areas()
	
	# Check if one on the areas in the hitbox area is an interative one, and interact with it if it is
	# Also verify if no block were broke in this use of the action state
	for area in interact_areas:
		if area.get_class() in interactables && has_touch == false:
			area.interact(hit_box_shape.global_position)



# If the raycast found no obstacle in its way, damage the targeted body
func damage_body(body : PhysicsBody2D, impact_pos: Vector2):
	body.damage(owner)
	SFX.play_SFX(SFX.great_hit, impact_pos)
	has_touch = true


# When the animation is off, set the actor's state to Idle
func on_animation_finished():
	if state_node.current_state == self:
		if owner.is_on_floor():
			state_node.set_state("Idle")
		else:
			state_node.set_state("Fall")


# Define the actions the player can do in this state
func _input(event):
	if event is InputEventKey:
		if state_node.get_current_state() == self:
			
			if event.is_action_pressed(inputs_node.input_map["MoveLeft"]) or event.is_action_pressed(inputs_node.input_map["MoveRight"]):
				if owner.is_on_floor():
					state_node.set_state("Move")
			
			elif event.is_action_pressed(inputs_node.input_map["Jump"]):
				if owner.is_on_floor():
					state_node.set_state("Jump")
