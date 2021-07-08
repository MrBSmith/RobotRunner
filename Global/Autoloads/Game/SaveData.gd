extends Node
class_name SaveData

const level_property_to_serialize = {
	"Collectable" : [],
	"XionCrate" : []
}

var settings = {
		"system":{
			"slot_id": 1,
			"save_name": "none",
			"time": "unknown"
		},
		"audio":{
			"music": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")),
			"sounds": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sounds"))
		},
		"controls":{
			"jump_player1": InputMap.get_action_list("jump_player1")[0].scancode,
			"move_left_player1": InputMap.get_action_list("move_left_player1")[0].scancode,
			"move_right_player1": InputMap.get_action_list("move_right_player1")[0].scancode,
			"teleport_player1": InputMap.get_action_list("teleport_player1")[0].scancode,
			"action_player1": InputMap.get_action_list("action_player1")[0].scancode,
				
			"jump_player2": InputMap.get_action_list("jump_player2")[0].scancode,
			"move_left_player2": InputMap.get_action_list("move_left_player2")[0].scancode,
			"move_right_player2": InputMap.get_action_list("move_right_player2")[0].scancode,
			"teleport_player2": InputMap.get_action_list("teleport_player2")[0].scancode,
			"action_player2": InputMap.get_action_list("action_player2")[0].scancode,
				
			"game_restart": InputMap.get_action_list("game_restart")[0].scancode,
			"HUD_switch_state": InputMap.get_action_list("HUD_switch_state")[0].scancode,
			"display_console": InputMap.get_action_list("display_console")[0].scancode
		},
		"progression":{
			"chapter": -1,
			"last_level": -1,
			"visited_levels": [],
			"xion": 0,
			"gear": 0
		}
	}

var default_input_profiles = {
	"azerty":{
		"jump_player1": KEY_Z,
		"move_left_player1": KEY_Q,
		"move_right_player1": KEY_D,
		"teleport_player1": KEY_S,
		"action_player1": KEY_E,
			
		"jump_player2": KEY_UP,
		"move_left_player2": KEY_LEFT,
		"move_right_player2": KEY_RIGHT,
		"teleport_player2": KEY_DOWN,
		"action_player2": KEY_SHIFT,
			
		"game_restart": KEY_F1,
		"HUD_switch_state": KEY_F2,
		"display_console": KEY_F3
	},
	"qwerty":{
		"jump_player1": KEY_W,
		"move_left_player1": KEY_A,
		"move_right_player1": KEY_D,
		"teleport_player1": KEY_S,
		"action_player1": KEY_E,
			
		"jump_player2": KEY_UP,
		"move_left_player2": KEY_LEFT,
		"move_right_player2": KEY_RIGHT,
		"teleport_player2": KEY_DOWN,
		"action_player2": KEY_SHIFT,
			
		"game_restart": KEY_F1,
		"HUD_switch_state": KEY_F2,
		"display_console": KEY_F3
	},
	"custom":{
		"jump_player1": KEY_Z,
		"move_left_player1": KEY_Q,
		"move_right_player1": KEY_D,
		"teleport_player1": KEY_S,
		"action_player1": KEY_E,
			
		"jump_player2": KEY_UP,
		"move_left_player2": KEY_LEFT,
		"move_right_player2": KEY_RIGHT,
		"teleport_player2": KEY_DOWN,
		"action_player2": KEY_SHIFT,
			
		"game_restart": KEY_F1,
		"HUD_switch_state": KEY_F2,
		"display_console": KEY_F3
	}
}
