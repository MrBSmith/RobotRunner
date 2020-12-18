extends Camera2D
class_name GameCamera

const DEFAULT_INTERPOL_DUR : float = 1.3

onready var state_machine_node = $StateMachine
onready var stop_state_node = $StateMachine/Stop
onready var follow_state_node = $StateMachine/Follow
onready var moveto_state_node = $StateMachine/MoveTo
onready var shake_state_node = $StateMachine/Shake
onready var tween_node = $Tween
onready var avg_pos_visualizer = $AveragePos
onready var pivot = $Pivot

export var camera_speed : float = 3.0

export var debug : bool = false setget set_debug, is_debug

var players_weakref_array : Array = [] setget set_players_weakref_array
var instruction_stack : Array = []

var average_player_pos := Vector2.INF setget set_average_player_pos, get_average_player_pos

var is_ready : bool = false

#### ACCESSORS ####

func set_state(state_name: String): state_machine_node.set_state(state_name)
func get_state() -> StateBase: return state_machine_node.get_current_state()
func get_state_name() -> String: return get_state().get_name()

func set_debug(value: bool):
	if value != debug:
		debug = value
		
		if !is_ready:
			yield(self, "ready")
		
		avg_pos_visualizer.set_visible(debug)
		pivot.set_visible(debug)
		
		var state = get_state()
		if state != null:
		 state.set_debug_panel_visible(debug)

func is_debug() -> bool: return debug

func set_to_previous_state():
	state_machine_node.set_to_previous_state()

func set_average_player_pos(value: Vector2):
	average_player_pos = value
	avg_pos_visualizer.set_global_position(average_player_pos)

func get_average_player_pos() -> Vector2: return average_player_pos

func set_pivot_position(value: Vector2): pivot.set_global_position(value)
func get_pivot_position() -> Vector2: return pivot.get_global_position()

# Feed the array of players with weakrefs
func set_players_weakref_array(weakref_array: Array):
	for element in weakref_array:
		if not element is WeakRef:
			if debug:
				print("One of the elements of the array passed to set_players_weakref_array is not a WeakRef")
			return
	players_weakref_array = weakref_array

# Return the player true ref
func get_players_array() -> Array:
	var players_array : Array = []
	for player_weakref in players_weakref_array:
		var player = player_weakref.get_ref()
		if player != null:
			players_array.append(player)
	return players_array


#### BUILT-IN ####

func _enter_tree() -> void:
	set_zoom(Vector2.ONE)


func _ready() -> void:
	pivot.set_as_toplevel(true)
	avg_pos_visualizer.set_as_toplevel(true)
	is_ready = true


func _physics_process(_delta: float) -> void:
	set_average_player_pos(compute_average_pos())


#### LOGIC ####

# Add an instruction in the stack
func stack_instruction(instruction: Array):
	instruction_stack.append(instruction)
	
	var current_state = state_machine_node.get_state_name()
	if current_state == "Follow" or current_state == "Stop":
		execute_next_instruction()


# Unstack the next instruction and execute it
func execute_next_instruction():
	if len(instruction_stack) == 0:
		return
	
	var instruction = instruction_stack.pop_front()
	var intruction_funcref := funcref(self, instruction.pop_front())
	intruction_funcref.call_funcv(instruction)


# Give the camera the order to move at the given position, and set it's state to move_to
func move_to(dest: Vector2, average_w_players : bool = false, move_speed : float = -1.0, duration : float = 0.0):
	moveto_state_node.destination = dest
	moveto_state_node.average_w_players = average_w_players
		
	if move_speed != -1.0:
		moveto_state_node.current_speed = move_speed

	moveto_state_node.wait_time = duration
	state_machine_node.set_state("MoveTo")


# Move according to the given velocity
func move_vel(delta: float, velocity: Vector2):
	position += velocity * delta


# Progressively move the pivot to the given position
func start_moving_pivot(dest_pos: Vector2, duration: float = DEFAULT_INTERPOL_DUR):
	tween_node.remove(pivot, "global_position")
	tween_node.interpolate_property(pivot, "global_position",
		global_position, dest_pos, duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_node.start()


# Progressively move to the given destination
func start_moving(dest_pos: Vector2, duration: float = DEFAULT_INTERPOL_DUR):
	tween_node.remove(self, "global_position")
	tween_node.interpolate_property(self, "global_position",
		global_position, dest_pos, duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_node.start()


# Progressively zoom/dezoom
func start_zooming(dest_zoom: Vector2, duration: float = DEFAULT_INTERPOL_DUR):
	tween_node.remove(self, "zoom")
	tween_node.interpolate_property(self, "zoom",
		get_zoom(), dest_zoom, duration,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_node.start()


# Set the average_pos variable to be at the average of every players position
func compute_average_pos() -> Vector2:
	var players_array = get_tree().get_nodes_in_group("Players")
	var average_pos = Vector2.ZERO
	for player in players_array:
		average_pos += player.global_position
	
	average_pos /= len(players_array)
	
	return average_pos


func shake(magnitude: float, duration: float):
	shake_state_node.magnitude = magnitude
	shake_state_node.duration = duration
	set_state("Shake")
