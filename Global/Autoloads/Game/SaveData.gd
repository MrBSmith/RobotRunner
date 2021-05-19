extends Node
class_name SaveData

const level_property_to_serialize = {
	"Collectable" : [],
	"BreakableObjectBase" : [],
	"Door" : ["openned"],
	"DoorButton": ["pushed"],
	"Checkpoint": ["active"]
}

var settings ={
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
			"last_level": -1,
			"visited_levels": [],
			"xion": 0,
			"gear": 0
		}
	}
