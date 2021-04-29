extends Event
class_name CameraEventBase

export var camera_new_zoom := Vector2.ONE
export var camera_new_speed : float = -1.0
export var zoom_duration : float = 3.0
export var follow_state : bool = false

func event():
	if !event_disabled: # Check if the camera event is disabled, if yes, the camera won't move.
		EVENTS.emit_signal("zoom_camera_to_query", camera_new_zoom, zoom_duration)
		if follow_state:
			EVENTS.emit_signal("camera_state_change_query", "Follow")
		else:
			EVENTS.emit_signal("move_camera_to_query", $Position2D.get_global_position(), false, camera_new_speed, INF)
		queue_free()
	else:
		print_debug("An Event has been triggered but is disabled")
