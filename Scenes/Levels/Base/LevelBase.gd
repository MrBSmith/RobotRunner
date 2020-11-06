extends Node2D

class_name Level

const CLASS : String = "Level"

onready var xion_cloud_node = get_node_or_null("XionCloud")
onready var hud_node = "GUI/HUD"
onready var interactive_object_node = get_node("InteractivesObjects")
var interactive_objects_dict : Dictionary

onready var music_bus_id = AudioServer.get_bus_index("Music")
onready var master_bus_id = AudioServer.get_bus_index("Master")

var players_array : Array
var player_in_danger : bool = false
var players_exited : int = 0

signal level_finished
signal level_ready

func is_class(value: String) -> bool:
	return value == CLASS

func get_class() -> String:
	return CLASS


func _ready():
	var _err = connect("level_finished", GAME, "on_level_finished")
	_err = connect("level_ready", GAME, "on_level_ready")

	GAME.last_level_path = filename
#	update_current_level_index()

	if(!GAME.progression.main_stored_objects.empty()):
		print(GAME.progression.main_stored_objects)

	set_starting_points()
	instanciate_players()
	set_camera_position_on_start()
	propagate_weakref_players_array()
	
	GAME.update_hud_collectable_progression()
	MUSIC.play()

	GAME.get_children_of_node([interactive_object_node], interactive_objects_dict)

	emit_signal("level_ready", self)


func _physics_process(_delta):
	if !AudioServer.is_bus_mute(music_bus_id) && !AudioServer.is_bus_mute(master_bus_id):
		MUSIC.adapt_music(xion_cloud_node, players_array, player_in_danger)

# Called by GAME when a player exited the level
# Update the players array, and the player_exited counter
func on_player_exited(player : PhysicsBody2D):
	players_exited += 1

	var player_index = players_array.find(player)
	if player_index != -1:
		players_array.remove(player_index)

	if players_exited == 2:
		emit_signal("level_finished")


func on_player_in_danger():
	player_in_danger = true


func on_player_out_of_danger():
	player_in_danger = false


# Load the last checkpoint visited and set the position accordingly,
# Also disable every uneeded checkpoint
func set_starting_points():
	var current_checkpoint = GAME.progression.checkpoint

	if current_checkpoint <= 0:
		return

	var checkpoint_array = get_node("Events/Checkpoints").get_children()
	var starting_point_array = get_tree().get_nodes_in_group("StartingPoint")

	# Place the starting position based on the last checkpoint visited
	var new_starting_point1 = checkpoint_array[current_checkpoint - 1].get_node("NewStartingPoint1")
	var new_starting_point2 = checkpoint_array[current_checkpoint - 1].get_node("NewStartingPoint2")

	starting_point_array[0].set_global_position(new_starting_point1.global_position)
	starting_point_array[1].set_global_position(new_starting_point2.global_position)

	# Set active every checkpoint before the current one (And also the current one)
	for i in range(current_checkpoint):
		checkpoint_array[i].set_active(true)


# Intanciate the players inside the level
func instanciate_players():
	# Get the players starting positions
	var player_start_array = [get_node_or_null("StartingPointP1"), get_node_or_null("StartingPointP2")]
	players_array += [GAME.player1.instance(), GAME.player2.instance()]

	# Add the players scene to the level scene a the position of the start position
	for i in range(player_start_array.size()):
		if player_start_array[i] != null:
			var player_start_pos = player_start_array[i].get_global_position()
			var player_node = players_array[i]
			player_node.global_position = player_start_pos
			player_node.level_node = self
			add_child(player_node)


func set_camera_position_on_start():
	if(GAME.progression.checkpoint > 0):
		var camera_node : Node = find_node("Camera")
		var camera_position_on_start = camera_node.compute_average_pos(players_array)
		camera_node.set_global_position(camera_position_on_start)


# Feed every needing node with weak references of the players so it can follow them
func propagate_weakref_players_array():
	var players_weakref_array = []
	for player in players_array:
		players_weakref_array.append(weakref(player))

	propagate_call("set_players_weakref_array", [players_weakref_array])
	MUSIC.set_players_weakref_array(players_weakref_array)
