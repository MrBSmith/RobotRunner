extends CameraState
class_name CameraFollowState

const ANTICIP_DIST : float = 200.0
const ANTICIP_TRIGGER_RATIO : float = 0.3
const BUFFER_DIST = 40.0

onready var border_anticip_label = $DebugLayer/Control/VBoxContainer/BordersAnticip

var borders_anticipated := Array() setget set_borders_anticipated, get_borders_anticipated


#### FOLLOW CAMERA STATE ####

#### ACCESSORS ####

func set_borders_anticipated(value: Array):
	if value != borders_anticipated:
		borders_anticipated = value
		
		var borders_string = ""
		for border in borders_anticipated:
			borders_string += String(border) + " "
		border_anticip_label.set_text("Border anticipated: " + borders_string)

func get_borders_anticipated() -> Array: return borders_anticipated



#### BUILT-IN ####


#### VIRTUAL ####


# This state is used to follow the players
# It computes the average position of all the players, and move the camera towards it
# Progressivly, so the camera feels smooth
func update_state(_delta):
	var players_array = camera.get_players_array()
	
	# Move the camera speed towards the average postion
	# With a horiziontal/vertical restriction
	if len(players_array) > 0:
		
		# Compute the dest of the camera
		var average_pos : Vector2 = camera.get_average_player_pos()
		var new_borders_approched = get_border_approched(average_pos)
		set_borders_anticipated(new_borders_approched)
		var offset = Vector2.ZERO
		
		if borders_anticipated.size() == 1:
			offset += borders_anticipated[0] * ANTICIP_DIST
		
		camera.start_moving_pivot(average_pos)
		camera.start_moving(average_pos + offset)
		
		# Zoom/Dezoom if necesary
		var max_dist = screen_size * 0.5
		var players_distance = compute_player_distance(players_array)
		var dest_zoom := Vector2.ONE
		
		if players_distance.length() > max_dist.length():
			var distance_ratio = players_distance.length() / max_dist.length()
			
			if borders_anticipated.size() > 1:
				distance_ratio += distance_ratio * 0.3
			
			distance_ratio = clamp(distance_ratio, 1.0, 2.0)
			dest_zoom = Vector2(distance_ratio, distance_ratio)
		
		if camera.zoom != dest_zoom:
			camera.start_zooming(dest_zoom)
		
		camera.update_camera_limits()


#### LOGIC ####

# Compute the distance between the players
func compute_player_distance(players_array: Array) -> Vector2:
	var distance := Vector2.ZERO
	var nb_players = players_array.size()
	
	if nb_players == 1:
		return Vector2.ZERO
	
	for i in range(nb_players):
		if i == 0:
			distance = players_array[0].get_global_position()
		else:
			distance -= players_array[i].get_global_position()
	return distance


# Returns an array of borders being approched
func get_border_approched(ply_average_pos: Vector2) -> Array:
	var border_array := Array()
	var players_array = owner.get_players_array()
	
	for player in players_array:
		var player_pos = player.get_global_position()
		
		var pivot_pos = camera.get_pivot_position()
		var anticip_dist = screen_size.x * ANTICIP_TRIGGER_RATIO
		
		# Buffer distance for anticipation (To fix border effect causing unwanted shaking)
		var left_buffer_dist = BUFFER_DIST * int(Vector2.LEFT in borders_anticipated)
		var right_buffer_dist = BUFFER_DIST * int(Vector2.RIGHT in borders_anticipated)
		
		### Check individual players position ###
		if player_pos.x > pivot_pos.x + (screen_size.x / 2) - anticip_dist - right_buffer_dist && \
							player.last_direction == Vector2.RIGHT:
			if !(Vector2.RIGHT in border_array):
				border_array.append(Vector2.RIGHT)
				continue
		
		elif player_pos.x < pivot_pos.x - (screen_size.x / 2) + anticip_dist + left_buffer_dist && \
							player.last_direction == Vector2.LEFT:
			if !(Vector2.LEFT in border_array):
				border_array.append(Vector2.LEFT)
				continue
		
		var cam_zoom = camera.get_zoom()
		var cam_size = screen_size * cam_zoom
		var cam_anticip_dist = cam_size.x * ANTICIP_TRIGGER_RATIO
		
		# Check average players position being in one of the border buffer
		if ply_average_pos.x > pivot_pos.x + (cam_size.x / 2) - cam_anticip_dist - right_buffer_dist:
			if !(Vector2.RIGHT in border_array) && player.last_direction == Vector2.RIGHT:
				border_array.append(Vector2.RIGHT)
				break
		
		if ply_average_pos.x < pivot_pos.x - (cam_size.x / 2) + cam_anticip_dist + left_buffer_dist:
			if !(Vector2.LEFT in border_array) && player.last_direction == Vector2.LEFT:
				border_array.append(Vector2.LEFT)
				break
	
	return border_array

# Convert a global position to a relative position to the camera origin (center)
func global_to_relative(global : Vector2) -> Vector2:
	return global - owner.get_global_position()
