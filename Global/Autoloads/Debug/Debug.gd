extends Node

func _enter_tree() -> void:
	if OS.is_debug_build():
		var _err = get_tree().connect("node_added", self, "on_scene_tree_node_added")

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS


func _input(event):
	if OS.is_debug_build():
		if event.is_action_pressed("debug_fullscreen"):
			OS.window_fullscreen = !OS.window_fullscreen
		
		if event.is_action_pressed("debug_mute_sounds"):
			var master_bus_id = AudioServer.get_bus_index("Master")
			var is_master_muted = AudioServer.is_bus_mute(master_bus_id)
			AudioServer.set_bus_mute(master_bus_id, !is_master_muted)


func on_scene_tree_node_added(_node: Node):
	pass
#	if node is Level:
#		yield(node, "ready")
#		GameSaver.save_level_properties_as_json(node)
#
#		get_tree().disconnect("node_added", self, "on_scene_tree_node_added")
