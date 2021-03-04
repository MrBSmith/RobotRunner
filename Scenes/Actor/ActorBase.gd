extends KinematicBody2D
class_name ActorBase

var current_speed : float = 0.0
export var max_speed : float = 400.0
export var acceleration : float = 15.0

onready var animated_sprite_node = $AnimatedSprite
onready var path_node = get_node_or_null("Path")
onready var action_hitbox_node = get_node_or_null("ActionHitBox")

export var default_state : String = ""

export var jump_force : int = -500 
export (int, 0, 1000) var push = 2

const GRAVITY : int = 30

var snap_vector = Vector2(0, 10)
var current_snap = snap_vector

var last_direction : int = 0
var direction : int = 0 setget set_direction, get_direction
var velocity := Vector2.ZERO setget set_velocity, get_velocity

signal velocity_changed

#### ACCESSORS ####

func set_direction(value : int):
	value = int(sign(value))
	if value != 0 and value != direction:
		flip(value)
		last_direction = value
	direction = value

func get_direction() -> int: return direction

func set_max_speed(value : float): max_speed = value
func get_max_speed() -> float: return max_speed

func set_velocity(value: Vector2):
	if value != velocity:
		emit_signal("velocity_changed", value)
	velocity = value

func get_velocity() -> Vector2:
	return velocity

func set_state(value : String): $StatesMachine.set_state(value)
func get_state() -> String: return $StatesMachine.get_state_name()

func get_extents() -> Vector2: return $CollisionShape2D.get_shape().get_extents()

# Returns the direction of the robot
func get_face_direction() -> int:
	if animated_sprite_node.is_flipped_h():
		return -1
	else:
		return 1


#### BUILT-IN ####


#### PHYSIC BEHAVIOUR ####

func _physics_process(delta):
	var dir = get_direction()
	
	
	# Handle actor's acceleration/decceleration
	var base_speed = max_speed / 2
	
	if dir != 0:
		if current_speed < base_speed:
			current_speed = base_speed
		else:
			current_speed += acceleration
	else:
		current_speed -= acceleration * 3.3
	
	current_speed = clamp(current_speed, 0.0, max_speed)
	
	# Compute velocity
	velocity.x = last_direction * current_speed
	velocity.y += GRAVITY
	
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
	
	# Apply movement
	velocity = move_and_slide_with_snap(velocity, current_snap, Vector2.UP, true, 4, deg2rad(46), false)
	
	# Apply force to bodies it hit
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("MovableBodies"):
			collision.collider.apply_central_impulse(-collision.normal * push)


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


func jump(dir := Vector2.ZERO):
	set_direction(int(dir.x))
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
	if !collision2D:
		return false
	
	for i in range(1, amount + 1):
		for j in [1, -1]:
			if !vertical && j == 1: continue
			
			var movement = Vector2(i * j, velocity.y * delta) if vertical\
								   else Vector2(velocity.x * delta, i * j)
			
			var collision = COLLISION_CHECKER.test_collision(self, movement, 
													collision2D, vertical)
			
			if !collision:
				if vertical && COLLISION_CHECKER.test_wall_collision(self, movement):
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
