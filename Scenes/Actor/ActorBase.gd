extends KinematicBody2D
class_name ActorBase

func is_class(value: String): return value == "ActorBase" or .is_class(value)
func get_class() -> String: return "ActorBase"

var is_ready : bool = false

var current_speed : float = 0.0
export var max_speed : float = 400.0
export var acceleration : float = 15.0

onready var animated_sprite_node = $AnimatedSprite
onready var path_node = get_node_or_null("Path")
onready var action_hitbox_node = get_node_or_null("ActionHitBox")

export var default_state : String = ""
export var interactables := PoolStringArray(["InteractiveObject"])

export var jump_force : int = -500 
export (int, 0, 1000) var push = 2

const GRAVITY : int = 30
export var ignore_gravity : bool = false

var snap_vector = Vector2(0, 10)
var current_snap = snap_vector

var last_direction := Vector2.ZERO
var direction := Vector2.ZERO setget set_direction, get_direction
var velocity := Vector2.ZERO setget set_velocity, get_velocity

var impulse := Vector2.ZERO setget set_impulse, get_impulse
var forces : PoolVector2Array = [] #first value must be IMPULSE

var is_waiting : bool = false

signal velocity_changed
signal impulse_changed

#### ACCESSORS ####

func set_direction(value : Vector2):
	value = value.normalized()
	if value.x != 0 and value != direction:
		flip(int(sign(value.x)))
		last_direction = value
	direction = value

func get_direction() -> Vector2: return direction

func set_max_speed(value : float): max_speed = value
func get_max_speed() -> float: return max_speed

func set_velocity(value: Vector2):
	if value != velocity:
		emit_signal("velocity_changed", value)
	velocity = value

func get_velocity() -> Vector2:
	return velocity
	
func set_impulse(new_impulse_vector : Vector2):
	impulse = new_impulse_vector
	emit_signal("impulse_changed", new_impulse_vector)

func get_impulse() -> Vector2:
	return impulse

func set_state(value): $StatesMachine.set_state(value)
func get_state() -> String: return $StatesMachine.get_state_name()

func get_extents() -> Vector2: return $CollisionShape2D.get_shape().get_extents()

# Returns the direction of the robot
func get_face_direction() -> int:
	if animated_sprite_node.is_flipped_h():
		return -1
	else:
		return 1

#### BUILT-IN ####

func _ready():
	is_ready = true
	var _err = connect("impulse_changed", self, "on_impulse_changed")
	
#### PHYSIC BEHAVIOUR ####

func _physics_process(delta):
	actor_speed_handler()
	compute_velocity()
	correct_jump_corner(delta)
	apply_movement(delta)
	apply_force_to_colliding_bodies()
	reduce_impulse_force_by_friction(acceleration * 3.3)

#### LOGIC ####	

func get_reel_input(action_name : String) -> String:
	var input_event_array = InputMap.get_action_list(action_name)
	
	if input_event_array == []:
		return ""
	else:
		return input_event_array[0].as_text()


func appear():
	$StatesMachine.set_state("Rise")

func overheat():
	$AnimationPlayer.play("Overheat", -1, 2.5)


func destroy():
	EVENTS.emit_signal("play_SFX", "small_explosion", global_position)
	queue_free()

func actor_speed_handler():
	var dir = get_direction()
	
	# Handle actor's acceleration/decceleration
	var base_speed = max_speed / 2
	
	if dir != Vector2.ZERO:
		if current_speed < base_speed:
			current_speed = base_speed
		else:
			current_speed += acceleration
	else:
		current_speed -= (acceleration * 3.3)
	
	current_speed = clamp(current_speed, 0.0, max_speed)

func compute_velocity():
	# Compute velocity
	velocity.x = last_direction.x * current_speed
	if forces.size() > 0 and impulse != Vector2.ZERO:
		velocity.x += forces[0].x #index of impulse
		velocity.y = forces[0].y #index of impulse
	if !ignore_gravity:
		velocity.y += GRAVITY

func reduce_impulse_force_by_friction(friction_value : float):
	if forces.size() > 0:
		if forces[0].x > 0:
			forces[0].x -= friction_value
		if forces[0].y < 0:
			forces[0].y += friction_value
		else:
			forces.remove(0)
			impulse = Vector2.ZERO
	else:
		return

func apply_movement(_delta):
	# Apply movement
	velocity = move_and_slide_with_snap(velocity, current_snap, Vector2.UP, true, 4, deg2rad(46), false)

func correct_jump_corner(delta):
	var state = get_state()
	
	# Jump corner correction
	if state == "Jump":
		# Make a movement test to check collisions preemptively
		var corner_col = move_and_collide(velocity * delta, true, true, true)
		if corner_col != null:
			var col_normal = corner_col.get_normal()
			if col_normal.x < 0.2 && col_normal.x > -0.2:
				var __ = corner_correct(20, delta, corner_col)
				
	# Check for little horizontal gap (few pxls)
	elif velocity.x != 0 && (state == "Idle" or state == "Move"):
		if ground_frontal_collision(delta):
			return

func apply_force_to_colliding_bodies():
	# Apply force to bodies it hit
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("MovableBodies"):
			collision.collider.apply_central_impulse(-collision.normal * push)

func jump(dir := Vector2.ZERO):
	set_direction(dir)
	if is_on_floor():
		set_state("Jump")


# Flip the actor accordingly to the direction it is facing
func flip(dir: int):
	var is_looking_left : bool = (dir == -1)
	
	# Flip the sprite
	animated_sprite_node.set_flip_h(is_looking_left)
	
	# Flip the offset
	if is_looking_left:
		animated_sprite_node.offset.x = -abs(animated_sprite_node.offset.x)
	else:
		animated_sprite_node.offset.x = abs(animated_sprite_node.offset.x)
	
	# Flip the hitbox
	if action_hitbox_node != null:
		var hit_box_shape_x_pos = action_hitbox_node.get_child(0).position.x
		action_hitbox_node.get_child(0).position.x = abs(hit_box_shape_x_pos) * dir


# Try to correct the players position, if its supposed to collide with a corner
# Do it verticaly by default (to correct ceiling corners), but can be done horizontaly
# by setting vertical to false
func corner_correct(amount : int, delta: float, collision2D : KinematicCollision2D = null, 
					vertical: bool = true) -> bool:
	
	var level = get_tree().get_current_scene()
	
	if !collision2D:
		return false
	
	for i in range(1, amount + 1):
		for j in [1, -1]:
			if !vertical && j == 1: continue
			
			var movement = Vector2(i * j, velocity.y * delta) if vertical\
								   else Vector2(velocity.x * delta, i * j)
			
			var collision = CollisionChecker.test_collision(self, movement, 
													collision2D, vertical)
			
			if !collision:
				if vertical && CollisionChecker.test_wall_collision(self, level, movement):
					return false
				else:
					global_position += movement
					return true
	return false


func ground_frontal_collision(delta : float) -> bool:
	var collision2D = move_and_collide(velocity * delta, true, true, true)
	if collision2D:
		var normal = collision2D.get_normal()
		if normal == Vector2.LEFT or normal == Vector2.RIGHT:
			return corner_correct(16, delta, collision2D, false)
	return false


##### SIGNALS #####
func on_impulse_changed(value : Vector2):
	if forces.size() == 0:
		forces.append(impulse)
	else:
		forces.set(0, impulse)
