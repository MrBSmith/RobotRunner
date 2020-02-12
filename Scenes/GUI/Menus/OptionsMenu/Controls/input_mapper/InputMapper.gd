extends Node

signal profile_changed(new_profile, is_customizable)

var current_profile_id = 0
var profiles = {
	0: 'profile_azerty',
	1: 'profile_qwerty',
	2: 'profile_custom',
}
var profile_azerty = {
	'jump_player1': KEY_Z,
	'move_left_player1': KEY_Q,
	'move_right_player1': KEY_D,
	'teleport_player1': KEY_S,
	'action_player1': KEY_E,
	
	'jump_player2': KEY_UP,
	'move_left_player2': KEY_LEFT,
	'move_right_player2': KEY_RIGHT,
	'teleport_player2': KEY_DOWN,
	'action_player2': KEY_SHIFT,
	
	'game_restart': KEY_R
}
var profile_qwerty = {
	'jump_player1': KEY_W,
	'move_left_player1': KEY_A,
	'move_right_player1': KEY_D,
	'teleport_player1': KEY_S,
	'action_player1': KEY_E,
	
	'jump_player2': KEY_UP,
	'move_left_player2': KEY_LEFT,
	'move_right_player2': KEY_RIGHT,
	'teleport_player2': KEY_DOWN,
	'action_player2': KEY_SHIFT,
	
	'game_restart': KEY_R
}
var profile_custom = profile_azerty

func change_profile(id):
	current_profile_id = id
	var profile = get(profiles[id])
	var is_customizable = true if id == 2 else false
	
	for action_name in profile.keys():
		change_action_key(action_name, profile[action_name])
	emit_signal('profile_changed', profile, is_customizable)
	return profile

func change_action_key(action_name, key_scancode):
	erase_action_events(action_name)

	var new_event = InputEventKey.new()
	new_event.set_scancode(key_scancode)
	InputMap.action_add_event(action_name, new_event)
	get_selected_profile()[action_name] = key_scancode

func erase_action_events(action_name):
	var input_events = InputMap.get_action_list(action_name)
	for event in input_events:
		InputMap.action_erase_event(action_name, event)

func get_selected_profile():
	return get(profiles[current_profile_id])

func _on_ProfilesMenu_item_selected(ID):
	change_profile(ID)
