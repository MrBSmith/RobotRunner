extends Node2D
class_name LevelChunck

var interactive_object_dict : Dictionary = {
	"RedTeleporter": preload("res://Scenes/InteractiveObjects/Teleports/Types/RedTeleporter.tscn"),
	"BlueTeleporter": preload("res://Scenes/InteractiveObjects/Teleports/Types/BlueTeleporter.tscn"),
	"GreenTeleporter": preload("res://Scenes/InteractiveObjects/Teleports/Types/GreenTeleporter.tscn"),
	"IceBlock": preload("res://Scenes/InteractiveObjects/BreakableObjects/Blocks/IceBlock/M/MIceBlock.tscn"),
	"EarthBlock": preload("res://Scenes/InteractiveObjects/BreakableObjects/Blocks/EarthBlock/S/EarthBlockBase.tscn")
}

var room_type_dict : Dictionary = {
	"Small": SmallChunckRoom,
	"Big": BigChunckRoom
}

const max_nb_room : int = 3

onready var walls_tilemap = $Walls
onready var new_chunck_area = $NewChunckGenArea
onready var debug_cursor = $Walls/TilemapDebugCursor

export var debug : bool = true setget set_debug, is_debug

var chunck_bin : ChunckBin = null setget set_chunck_bin, get_chunck_bin

var unplaced_rooms : Array = []

var first_chunck : bool = false
var is_ready : bool = false
var starting_points : Array = []
var next_start_pos_array := PoolVector2Array()

var nb_automata : int = 2
var object_to_add : Array = []

var invert_player_placement : bool = false

var players_disposition : Dictionary = {
	"top": null,
	"bottom": null
}

signal chunck_gen_finished
signal new_chunck_reached(invert_player_pos)
signal every_automata_finished
signal walls_updated

#### ACCESSORS ####

func is_class(value: String): return value == "LevelChunck" or .is_class(value)
func get_class() -> String: return "LevelChunck"

func set_debug(value : bool):
	debug = value
	if debug_cursor!= null:
		debug_cursor.set_active(value)

func is_debug() -> bool : return debug

func set_chunck_bin(value: ChunckBin):
	if value != null:
		chunck_bin = value

func get_chunck_bin() -> ChunckBin: return chunck_bin

func get_rooms() -> Array : return $Rooms.get_children()

#### BUILT-IN ####

func _ready():
	var _err = new_chunck_area.connect("body_entered", self, "on_body_entered")
	is_ready = true
	
	if debug:
		debug_cursor.set_active(true)
	
	initialize_chunck()


#### LOGIC ####

func initialize_chunck():
	var last_room = generate_rooms()
	
	if last_room != null:
		yield(last_room, "ready")
	
	set_chunck_bin(ChunckBin.new(self))
	update_wall_tiles()
	
	initialize_player_placement()
	create_automatas()


func generate_self():
	update_wall_tiles()
	SlopePlacer.place_slopes(walls_tilemap)
	fetch_rooms_objects()
	generate_objects()
	
	if debug:
		room_debug_visualizer()
	
	emit_signal("chunck_gen_finished")


func update_wall_tiles(pos := Vector2.INF):
	place_wall_tiles(pos)
	if pos == Vector2.INF:
		walls_tilemap.update_bitmask_region(Vector2.ZERO, ChunckBin.chunck_tile_size)
	else:
		walls_tilemap.update_bitmask_region(pos - Vector2.ONE, pos + Vector2(2, 2))
	
	walls_tilemap.update_dirty_quadrants()
	emit_signal("walls_updated")


func create_automatas() -> void:
	for point in starting_points:
		var automata = ChunckAutomata.new(chunck_bin, point)
		automata.name = "automata"
		automata.chunck = self
		call_deferred("add_child", automata)


# Generate the rooms that will be added to the chunck. 
# By default generate only small rooms. 
# Overide it to generate different kind of rooms
func generate_rooms() -> Node:
	var room : Node = null
	var nb_room = randi() % max_nb_room
	for i in range(nb_room):
		var room_type_id = randi() % room_type_dict.size() if !first_chunck else 0
		var room_type = room_type_dict.values()[room_type_id]
		var next_room_half = ChunckRoom.ROOM_HALF.TOP_HALF
		
		if i != 0:
			var last_room_half = room.get_room_half()
			if last_room_half == next_room_half:
				next_room_half = ChunckRoom.ROOM_HALF.BOTTOM_HALF
		
		room = room_type.new(next_room_half)
		room.chunck = self
		$Rooms.call_deferred("add_child", room)
		unplaced_rooms.append(room)
	return room


func fetch_rooms_objects():
	for room in $Rooms.get_children():
		var room_rect = room.get_room_rect()
		for obj in room.interactive_objects:
			obj.set_position(obj.get_position() + room_rect.position * GAME.TILE_SIZE)
			object_to_add.append(obj) 


# Place the rooms in the chunck by modifing the chunck bin accordingly to the room bin
func place_room(room : ChunckRoom):
	var room_rect : Rect2 = room.get_room_rect()
	for i in range(room_rect.size.y):
		for j in range(room_rect.size.x):
			var pos = Vector2(j, i) + room_rect.position
			if room.bin_map.empty():
				break
			else:
				var room_cell = room.bin_map[i][j]
				chunck_bin.bin_map[pos.y][pos.x] = room_cell


# Place the tiles in the tilemap according the the bin_map value
func place_wall_tiles(pos := Vector2.INF):
	var wall_tile_id = walls_tilemap.get_tileset().find_tile_by_name("AutotileWall")
	var chunck_tile_size = ChunckBin.chunck_tile_size
	var bin_noise_map = chunck_bin.get_bin_map()
	
	# Update a single given automata position (2*2 tiles)
	if pos != Vector2.INF:
		for i in range(2):
			for j in range(2):
				var current_pos = pos + Vector2(j, i)
				if chunck_bin.is_cell_outside_chunck(current_pos):
					continue
				if bin_noise_map[current_pos.y][current_pos.x] == 1:
					walls_tilemap.set_cellv(current_pos, wall_tile_id)
				else:
					walls_tilemap.set_cellv(current_pos, -1)
		return
	
	# Update the whole tilemap
	walls_tilemap.clear()
	
	for i in range(chunck_tile_size.y):
		for j in range(chunck_tile_size.x):
			var current_pos = Vector2(j, i)
			if bin_noise_map[i][j] == 1:
				walls_tilemap.set_cellv(current_pos, wall_tile_id)
			else:
				walls_tilemap.set_cellv(current_pos, -1)


# Initialize the player disposition dictionary
func initialize_player_placement():
	var players_array = get_tree().get_nodes_in_group("Players")
	
	for player in players_array:
		var player_pos = player.get_global_position()
		var bottom = is_pos_in_bottom_half(player_pos)
		
		var key = "bottom"
		if (!bottom && !invert_player_placement) or (bottom && invert_player_placement):
			key = "top"

		players_disposition[key] = weakref(player)


# Returns true if the given position is in the bottom half of the chunck
# False if the pos is in the top half
func is_pos_in_bottom_half(pos: Vector2) -> bool:
	return pos.y > (ChunckBin.chunck_tile_size.y * GAME.TILE_SIZE.y) / 2


# Returns the rect of the room the given is in
# Returns an empty Rect2 if the given pos isn't in a room
func find_room_from_cell(cell: Vector2) -> ChunckRoom:
	for room in $Rooms.get_children():
		var room_rect = room.get_room_rect()
		if room_rect.has_point(cell): 
			return room
	return null


# Genrerate the interactive objects in the chunck 
func generate_objects():
	for element in object_to_add:
		if element is Node2D:
			if element is BlockBase && !is_block_placable(element):
				element.queue_free()
				continue
			call_deferred("add_child", element)
		elif element is Array:
			call_deferred("add_child", element[0])
			yield(element[0], "tree_entered")
			
			for i in range(element.size()):
				if i == 0: continue
				element[0].call_deferred("add_child", element[i])


# Add an object to the object_to_add array postioned at the given cell
func stack_object_at_cell(obj_key: String, cell: Vector2):
	if !obj_key in interactive_object_dict.keys():
		print("The request object: " + obj_key + " is not in the interactive_objects_dict")
		return
	
	var obj = interactive_object_dict[obj_key].instance()
	obj.set_position(cell * GAME.TILE_SIZE)
	
	if obj.has_method("awake"):
		obj.awake()
	
	object_to_add.append(obj)


# Place a block at the given cell, and adapt the block type to the expected player 
func place_block(cell: Vector2):
	var cell_pos = cell * GAME.TILE_SIZE
	var pos_in_bottom_half = is_pos_in_bottom_half(cell_pos)
	var key = "bottom" if pos_in_bottom_half else "top"
	var player_weakref = players_disposition[key]
	
	if player_weakref == null:
		return
	
	var player = player_weakref.get_ref()
	
	var breakable_objs = player.interactables
	var block_type = "IceBlock" if "IceBlock" in breakable_objs else "EarthBlock"
	
	stack_object_at_cell(block_type, cell)


# Check if the block is on a correct possition to be placed
func is_block_placable(block: BlockBase) -> bool:
	if block == null : 
		return false
	var block_global_pos = block.get_position() + walls_tilemap.get_position()
	var block_cell = walls_tilemap.world_to_map(block_global_pos) + Vector2.ONE
	var used_cells = walls_tilemap.get_used_cells()
	
	# for the block to be placable the two cells on its left must be empty cells,
	# and it shall have a floor underneath
	if !are_cells_empty(block_cell, 2, Vector2.LEFT) or \
	 !(block_cell + Vector2.DOWN in used_cells && block_cell + Vector2(-1, 1) in used_cells):
		return false
	
	var block_pos = block.get_position()
	var block_size = block.block_size
	
	# Check if a block has already a block on its left or right
	# (to avoid adjacent blocks)
	for obj in object_to_add:
		if obj == block or !(obj is BlockBase): 
			continue
		var obj_pos = obj.get_position()
		
		if obj_pos.y != block_pos.y: continue
		
		if (obj_pos.x >= block_pos.x - block_size.x - 1 \
		&& obj_pos.x < block_pos.x) or \
		(obj_pos.x <= block_pos.x + block_size.x + 1 \
		&& obj_pos.x > block_pos.x):
			return false
	
	return true

# Check from an origin cell, by going nb_cells in the given dir
# if each cells are empty
func are_cells_empty(o_cell: Vector2, nb_cells: int, dir: Vector2) -> bool:
	var used_cells = walls_tilemap.get_used_cells()
	
	for i in range(nb_cells):
		var cell_to_check = o_cell + (dir * (i + 1))
		if cell_to_check in used_cells:
			return false
	return true


func is_pos_inside_chunck(pos: Vector2) -> bool:
	var chunck_pos = get_global_position()
	var chunck_bottom_right = chunck_pos + ChunckBin.chunck_tile_size * GAME.TILE_SIZE
	
	return pos.x > chunck_pos.x && pos.y > chunck_pos.y && \
	pos.x < chunck_bottom_right.x && pos.y < chunck_bottom_right.y


#### VIRTUALS ####


#### INPUTS ####


#### DEBUG ####

# Display the room as a red semi transparant rectangle
func room_debug_visualizer():
	var tile_size = GAME.TILE_SIZE
	
	for room in $Rooms.get_children():
		var room_color_rect = ColorRect.new()
		var room_rect = room.get_room_rect()
		room_color_rect.name = "RoomColorRect"
		room_color_rect.set_frame_color(Color.red)
		room_color_rect.set_position(room_rect.position * tile_size)
		room_color_rect.set_size(room_rect.size * tile_size)
		room_color_rect.color.a = 0.5
		
		call_deferred("add_child", room_color_rect)
		
		# Display entries and exits
		for couple in room.entry_exit_couple_array:
			var entry_cell = couple[0]
			var exit_cell = couple[1]
			
			var entry_room_color_rect = ColorRect.new()
			entry_room_color_rect.name = "EntryColorRect"
			entry_room_color_rect.set_position(room_color_rect.get_position() + (entry_cell * tile_size))
			entry_room_color_rect.set_size(tile_size)
			entry_room_color_rect.set_frame_color(Color.azure)
			entry_room_color_rect.color.a = 0.5
			
			var exit_room_color_rect = ColorRect.new()
			exit_room_color_rect.name = "ExitColorRect"
			exit_room_color_rect.set_position(room_color_rect.get_position() + (exit_cell * tile_size))
			exit_room_color_rect.set_size(tile_size)
			entry_room_color_rect.set_frame_color(Color.violet)
			entry_room_color_rect.color.a = 0.5
			 
			call_deferred("add_child", entry_room_color_rect)
			call_deferred("add_child", exit_room_color_rect)



#### SIGNAL RESPONSES ####


func on_body_entered(body: PhysicsBody2D):
	if body is Player:
		emit_signal("new_chunck_reached", false)
		new_chunck_area.queue_free()


func on_bin_map_changed():
	pass


func _on_automata_moved(_automata: ChunckAutomata, to: Vector2):
	chunck_bin.erase_automata_pos(to)
	if debug:
		update_wall_tiles(to)


func _on_automata_forced_move_finished(_automata: ChunckAutomata, _pos: Vector2):
	pass


func _on_automata_finished(final_pos: Vector2):
	next_start_pos_array.append(Vector2(0, final_pos.y))
	nb_automata -= 1
	
	if nb_automata == 0:
		chunck_bin.refine_chunck()
		emit_signal("every_automata_finished")
		generate_self()


func _on_automata_block_placable(cell: Vector2):
	if !first_chunck:
		var rng = randi() % 3
		if rng == 0:
			place_block(cell)


func _on_automata_finished_crossing_room(_automata: ChunckAutomata, room: ChunckRoom):
	if room in unplaced_rooms:
		place_room(room)
