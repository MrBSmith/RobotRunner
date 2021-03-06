extends Node
class_name ChunckAutomata

const SIZE := Vector2(2, 2)

export var debug : bool = false 

var chunck_bin : ChunckBin = null 
var chunck = null
var bin_map_pos := Vector2.INF setget set_bin_map_pos, get_bin_map_pos

var last_moves := PoolVector2Array()
var stoped : bool = false setget set_stoped, is_stoped

var forced_moves = []
var thread : Thread

onready var move_timer = Timer.new()

signal moved(automata, to)
signal stopped(pos)
signal finished(final_pos)
signal finished_crossing_room(automata, room)
signal forced_move_finished(automata, pos)
signal block_placable(cell)

#### ACCESSORS ####

func is_class(value: String): return value == "ChunckAutomata" or .is_class(value)
func get_class() -> String: return "ChunckAutomata"

func set_bin_map_pos(value: Vector2):
	if value != Vector2.INF && value != bin_map_pos:
		bin_map_pos = value
		emit_signal("moved", self, bin_map_pos)

func get_bin_map_pos() -> Vector2: return bin_map_pos

func set_stoped(value: bool): 
	stoped = value
	if stoped == false:
		start_carving()
	else:
		emit_signal("stopped", bin_map_pos)

func is_stoped() -> bool: return stoped


#### BUILT-IN ####

func _init(chunck_binary: ChunckBin, pos: Vector2):
	chunck_bin = chunck_binary
	set_bin_map_pos(pos)


func _ready():
	var _err = connect("finished", chunck, "_on_automata_finished")
	_err = connect("finished", self, "_on_carving_finished")
	_err = connect("moved", chunck, "_on_automata_moved")
	_err = connect("forced_move_finished", chunck, "_on_automata_forced_move_finished")
	_err = connect("block_placable", chunck, "_on_automata_block_placable")
	_err = connect("finished_crossing_room", chunck, "_on_automata_finished_crossing_room")
	
	emit_signal("moved", self, bin_map_pos)
	
	if debug:
		add_child(move_timer)
		move_timer.set_wait_time(0.1)
		_err = move_timer.connect("timeout", self, "on_move_timer_timeout")
	else:
		start_carving()


#### LOGIC ####


func start_carving() -> void:
	carving_movement_loop(null)
#	if debug:
#		carving_movement_loop(null)
#	else:
#		thread = Thread.new()
#		var __ = thread.start(self, "carving_movement_loop")


# Carve into the chunck until something tells it to stop or its arrived at the end of the chunck
func carving_movement_loop(_thread_user_data):
	var movement_finished : bool = false
	
	while(!stoped):
		movement_finished = move()
		if movement_finished:
			set_stoped(true)
		
		# Emit the signal block placable each time the conditions are met
		if compare_last_moves(Vector2.RIGHT, 3):
			emit_signal("block_placable", get_bin_map_pos())
	
	if movement_finished:
		return


# Choose a movement, the movement can either be expressed if relative value (chosen_move)
# or in absolute value (realtive to the whole chunck instead of relative to the automata pos)
# if the final_pos is not set (is equal to Vector2.INF), the relative value will be used
# if the final_pos have a value, the chosen_move should have the value of Vector2.INF
# that way, we know this move was a teleportation
func move() -> bool:
	var room : ChunckRoom = chunck.find_room_from_cell(bin_map_pos)
	
	if room != null && !is_inside_room(room):
		room = null
	
	var chosen_move = Vector2.INF
	var final_pos := Vector2.INF
	var room_rect := Rect2()
	
	# If the current position is in a room, teleport to the other size of the room
	# If it's a big room, stay on the same y axis, if it's a small one
	# set the y position to the bottom of the room so it is accesible from a jump
	if room != null:
		room_rect = room.get_room_rect()
		var entry_point = Vector2(0, bin_map_pos.y)
		var rel_entry = theorical_to_rel_access(bin_map_pos, room)
		var room_floor_y = room_rect.position.y + room_rect.size.y
		
		rel_entry = Vector2(rel_entry.x, clamp(rel_entry.y, entry_point.y, room_floor_y - SIZE.y))
		
		# Get the player in the same half of the chunck as the automata
		var player_key = "bottom" if is_in_bottom_half() else "top"
		var player = chunck.players_disposition[player_key].get_ref()
		
		# Compute the y pos of the exit based on whether there is a pool or not
		var dist_to_floor = room_floor_y - rel_entry.y - SIZE.y
		var is_pool_possible = dist_to_floor > 2 && player.name == "MrCold"
		var min_exit_height = 3 if is_pool_possible else 0
		var max_exit_height = 5 - min_exit_height if is_pool_possible else 3
		
		# Get a random offset value between min_exit_height & max_exit_height
		var random_offset = (randi() % int(max_exit_height) + min_exit_height) * Vector2.UP
		final_pos = room_rect.position + room_rect.size + random_offset + Vector2(0, -2)
		
		if is_pool_possible:
			pass
		
		EVENTS.emit_signal("automata_room_crossed", self, room, rel_entry, final_pos)
		emit_signal("finished_crossing_room", self, room)
		
		forced_moves.append(Vector2.RIGHT) 
	else:
		chosen_move = choose_move()
	
	# Update last moves
	last_moves.append(chosen_move)
	if last_moves.size() > 5:
		last_moves.remove(0)
	
	# Move the automata and check if the automata has finished moving (is outside the chunck)
	var projected_pos = bin_map_pos + chosen_move if room == null else final_pos
	if is_pos_inside_chunck(projected_pos):
		set_bin_map_pos(projected_pos)
		return false
	else: 
		if !is_queued_for_deletion():
			emit_signal("finished", bin_map_pos)
		return true


# Choose a movement
func choose_move() -> Vector2:
	var near_celling : bool = is_near_ceiling()
	var near_floor : bool = is_near_floor()
	
	if !forced_moves.empty():
		var move = forced_moves.pop_front()
		if forced_moves.empty():
			emit_signal("forced_move_finished", self, get_bin_map_pos() + move)
		return move
	
	var possible_moves = [Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	
	if near_celling or compare_last_moves(Vector2.UP, 2) or is_last_move(Vector2.DOWN):
		possible_moves.erase(Vector2.UP)
	
	if near_floor or is_last_move(Vector2.UP):
		possible_moves.erase(Vector2.DOWN)
	
	if near_chunck_end() or bin_map_pos.x == 0:
		possible_moves = [Vector2.RIGHT]
	
	var random_id = randi() % possible_moves.size()
	return possible_moves[random_id]


# Convert the theorical entry point in the concrete one
# ie the lowest point from where the player pass
func theorical_to_rel_access(access: Vector2, room: ChunckRoom, entry := true) -> Vector2:
	var room_rect = room.get_room_rect()
	
	var offset = Vector2.LEFT if entry else Vector2.ZERO
	var clamped_access = Vector2(room_rect.position.x, access.y) if entry else access
	
	var point = clamped_access + offset
	var chunck_size = ChunckBin.chunck_tile_size
	var rel_access = Vector2.ZERO
	
	for i in range(chunck_size.y):
		if point.y + i > chunck_size.y: 
			break
		if is_automata_pos_in_wall(point + Vector2(0, i), room):
			if i == 0: 
				break
			rel_access = clamped_access + Vector2(0, i - 1)
			return rel_access
	return clamped_access


# Compare the given move with the last move the automata has done.
# Returns true if it is the same
func is_last_move(move: Vector2) -> bool:
	if last_moves.empty(): return false
	return move == last_moves[last_moves.size() - 1]
	

# Takes an array of moves an compare it with the last moves
func a_compare_last_moves(comp_moves: Array) -> bool:
	if last_moves.size() < comp_moves.size(): return false
	for i in range(comp_moves.size()):
		if last_moves[-i - 1] != comp_moves[-i - 1]:
			return false
	return true


# Returns true if the last n moves are the given move
func compare_last_moves(move: Vector2, n: int) -> bool:
	if last_moves.size() < n: return false
	for i in range(n):
		if last_moves[-i -1] != move:
			return false
	return true


# Returns true if the automata is close from the ceiling of its half
func is_near_ceiling() -> bool:
	if !is_in_bottom_half():
		return bin_map_pos.y <= 2
	else:
		return bin_map_pos.y <= chunck_bin.chunck_tile_size.y / 2 + 3


# Returns true if the automata is close from the floor of its half
func is_near_floor() -> bool:
	if !is_in_bottom_half():
		return bin_map_pos.y >= chunck_bin.chunck_tile_size.y / 2 - 3
	else:
		return bin_map_pos.y >= chunck_bin.chunck_tile_size.y - 3


# Returns true if the automata is close from the end of the floor
func near_chunck_end() -> bool:
	return bin_map_pos.x >= chunck_bin.chunck_tile_size.x - 3

# Returns true if the automata is in the bottom half
func is_in_bottom_half() -> bool:
	return bin_map_pos.y > chunck_bin.chunck_tile_size.y / 2


# Verify if the given position is inside the chunck
func is_pos_inside_chunck(pos: Vector2):
	return pos.x >= 0 && pos.y >= 0 \
	&& pos.x < chunck_bin.chunck_tile_size.x && pos.y < chunck_bin.chunck_tile_size.y


# Check if the entire automata is inside the given room 
func is_inside_room(room : ChunckRoom) -> bool:
	var room_rect = room.get_room_rect()
	for i in range(SIZE.y):
		for j in range(SIZE.x):
			if !room_rect.has_point(bin_map_pos + Vector2(j, i)):
				return false
	return true


func is_automata_pos_in_wall(pos: Vector2, room : ChunckRoom = null) -> bool:
	var bin_map = chunck_bin.get_bin_map()
	for i in range(SIZE.y):
		for j in range(SIZE.x):
			var cell = Vector2(pos.x + j , pos.y + i)
			if bin_map[cell.y][cell.x] == 1 && !room.is_cell_inside_room(cell):
				return true
	return false



#### VIRTUALS ####



#### INPUTS ####

func _input(_event):
	if Input.is_action_just_pressed("ui_accept"):
		move_timer.start()


#### SIGNAL RESPONSES ####

func on_move_timer_timeout():
	var __ = move()


func _on_carving_finished(_pos: Vector2):
	queue_free()
