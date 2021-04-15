extends RT_ActorMoveState
class_name RobotMoveState

#### MOVE STATE ####

func update_state(_delta : float):
	if owner.is_path_empty():
		return "Idle"
	
	var last_point : PathPoint = owner.path[owner.next_point_index]
	if owner.is_arrived(owner.get_point_world_position(last_point)):

		# Trigger the event of the last point the free it
		var event_array = last_point.get_event()
		if event_array != [] && len(event_array) != 0:
			var method = event_array.pop_front()
			if owner.has_method(method):
				owner.callv(method, event_array)
			else:
				if method != "":
					print("method named " + method + " can't be found in class " + owner.name)
		
		if owner.is_path_finished(last_point):
			match(owner.movement_type):
				owner.MOVEMENT_TYPE.ONESHOT:
					owner.path_finished = true
					return "Idle"
				owner.MOVEMENT_TYPE.LOOP:
					owner.set_global_position(owner.original_pos)
					owner.next_point_index = 0
				owner.MOVEMENT_TYPE.PINGPONG:
					owner.travel_forward = !owner.travel_forward
					increment_point_index()
		else:
			increment_point_index()
		
	if is_current_state():
		move_to_next_point()


# Move to the next point in the path
func move_to_next_point():
	if owner.is_path_empty():
		return
	var dest = owner.get_point_world_position(owner.path[owner.next_point_index])
	move_to(dest)


# Handle the movement to the next point on the path, return true if the node is arrived
func move_to(destination : Vector2):
	var pos = owner.global_position
	var dir = pos.direction_to(destination)
	owner.set_direction(dir)

# Increment in a forward or backward way the index of the next point to go through
func increment_point_index():
	if owner.travel_forward == true:
		owner.next_point_index += 1
	else:
		owner.next_point_index -= 1
