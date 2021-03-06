extends KinematicBody2D
class_name ActorBase

func is_class(value: String): return value == "ActorBase" or .is_class(value)
func get_class() -> String: return "ActorBase"

var is_ready : bool = false

var current_speed : float = 0.0
export var max_speed : float = 400.0
export var acceleration : float = 30
export var friction : float = 30

onready var animated_sprite_node = $AnimatedSprite
onready var path_node = get_node_or_null("ActorPath")
onready var action_hitbox_node = get_node_or_null("ActionHitBox")

export var default_state : String = ""
export var interactables := PoolStringArray(["InteractiveObject"])

export var jump_force : int = -490
export (int, 0, 1000) var push = 2

const GRAVITY : Vector2 = Vector2(0, 30)
export var ignore_gravity : bool = false setget set_ignore_gravity, get_ignore_gravity

var snap_vector = Vector2(0, 10)
var current_snap = snap_vector

var last_direction := Vector2.ZERO
var direction := Vector2.ZERO setget set_direction, get_direction
var velocity := Vector2.ZERO setget set_velocity, get_velocity
var applied_force := Vector2.ZERO

var impulse : Dictionary = {} 
var forces : Dictionary = {}

var collision_type

var is_waiting : bool = false

signal velocity_changed(vel)
signal direction_changed(dir)

#### ACCESSORS ####

func set_direction(value : Vector2):
	value = value.normalized()
	if value.x != 0 and value != direction:
		flip(int(sign(value.x)))
		last_direction = value
	if !direction.is_equal_approx(value):
		emit_signal("direction_changed",value)
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

func set_state(value): $StatesMachine.set_state(value)
func get_state() -> Object: return $StatesMachine.get_state()
func get_state_name() -> String: return $StatesMachine.get_state_name()

func get_extents() -> Vector2: return $CollisionShape2D.get_shape().get_extents()

func set_ignore_gravity(value: bool): ignore_gravity = value
func get_ignore_gravity() -> bool: return ignore_gravity

# Returns the direction of the robot
func get_face_direction() -> int:
	if animated_sprite_node.is_flipped_h():
		return -1
	else:
		return 1

#### BUILT-IN ####

func _ready():
	is_ready = true
	
#### PHYSIC BEHAVIOUR ####

func _physics_process(delta):
	actor_speed_handler()
	compute_velocity()
	correct_jump_corner(delta)
	step_correct(delta)
	apply_movement(delta)
	apply_force_to_colliding_bodies()
	remove_useless_impulse()


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
		current_speed -= acceleration * 3.3
	
	current_speed = clamp(current_speed, 0.0, max_speed)


func compute_velocity():
	# Compute velocity
	
	applied_force = Vector2.ZERO
	
	for key in forces.keys():
		applied_force += forces[key]
	for key in impulse.keys():
		applied_force += impulse[key]
		reduce_impulse_force_by_friction(key)
		
	velocity.x = last_direction.x * current_speed
	
	if !ignore_gravity:
		velocity += GRAVITY
	
	emit_signal("velocity_changed", velocity)


func reduce_impulse_force_by_friction(impulse_key : String):
	if impulse.size() > 0:
		var impulse_length = impulse[impulse_key].length()
		var impulse_newlength = clamp(impulse_length-friction, 0, impulse_length)
		impulse[impulse_key] = impulse[impulse_key].clamped(impulse_newlength)


func add_impulse(key: String, impulse_value : Vector2):
	impulse[key] = impulse_value


func remove_impulse(key : String):
	if impulse.has(key):
		var _i = impulse.erase(key)


func remove_useless_impulse():
	for key in impulse.keys():
		if impulse[key] == Vector2.ZERO:
			var _i = impulse.erase(key)


func add_force(key: String, value : Vector2):
	if !has_force(key):
		forces[key] = value


func remove_force(key: String):
	if has_force(key):
		var _f = forces.erase(key)


func set_force(key: String, value : Vector2):
	if has_force(key):
		forces[key] = value


func has_force(key: String) -> bool:
	return forces.has(key)


func apply_movement(delta):
	# Apply movement
	
	#Have to check collisions, otherwise the actor will be able to go through solids
	#Do not use 2 move_and_slide at the same time
	position += applied_force * delta
	velocity = move_and_slide_with_snap(velocity, current_snap, Vector2.UP, true, 4, deg2rad(46), false)


func correct_jump_corner(delta):
	var state_name = get_state_name()
	
	# Jump corner correction
	if state_name == "Jump":
		# Make a movement test to check collisions preemptively
		var corner_col = move_and_collide(velocity * delta, true, true, true)
		if corner_col != null:
			var col_normal = corner_col.get_normal()
			if col_normal.x < 0.2 && col_normal.x > -0.2:
				var __ = corner_correct(20, delta, corner_col)


func step_correct(delta):
	# Check for little horizontal gap (few pxls)
	var state_name = get_state_name()
	if velocity.x != 0 && (state_name in ["Idle", "Move"]):
		if ground_frontal_collision(delta):
			return


func apply_force_to_colliding_bodies():
	# Apply force to bodies it hit
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("MovableBodies"):
			collision.collider.apply_central_impulse(-collision.normal * push)


func jump(dir := get_direction()):
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
