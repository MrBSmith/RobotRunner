tool
extends EditorPlugin
class_name WorldMapEditor

var last_node_selected : Node = null
var current_node_selected : Node = null

var button_dict : Dictionary = {}

var bind_origin : WorldMapNode = null
var bind_dest_array : Array = []
var editor_interface : EditorInterface

var bind_mode : bool = false setget set_bind_mode
var last_level_node_pos = Vector2.INF

var handeled_objects = ["WorldMapNode", "WorldMapBackgroundElement", "LevelNodeBind"]

var debug_mode : bool = false

#### ACCESSORS ####

func is_class(value: String): return value == "WorldMapEditor" or .is_class(value)
func get_class() -> String: return "WorldMapEditor"

func set_bind_mode(value: bool):
	if value != bind_mode:
		bind_mode = value
		
		if bind_mode == false:
			_unselect_all_level_nodes()
			bind_origin = null
			bind_dest_array = []
			destroy_button("Confirm bind")
			destroy_button("Abort bind")
		else:
			destroy_button("Create bind")
			generate_button("Abort bind")

#### BUILT-IN ####

func _enter_tree() -> void:
	editor_interface = get_editor_interface()


func _exit_tree() -> void:
	destroy_every_buttons()


func handles(obj: Object) -> bool:
	if !is_object_handled(obj):
		destroy_every_buttons()
	
	if obj == null or not obj is Node:
		return false
	
	yield(get_tree(), "idle_frame")
	
	if obj is WorldMapNode:
		if bind_mode == false:
			generate_button("Create Bind")
		
		if obj.get_binds_count() > 0:
			generate_button("Delete Binds")
		
	elif obj is WorldMapBackgroundElement:
		generate_button("Previous Texture")
		generate_button("Next Texture")
		generate_button("Random Texture")
		
	elif obj is LevelNodeBind:
		generate_button("Reroll Bind Gen")
	
	return is_object_handled(obj)


func edit(object: Object) -> void:
	if !is_object_handled(object):
		return
	
	last_node_selected = current_node_selected
	current_node_selected = object
	
	if bind_mode && current_node_selected is WorldMapNode:
		add_destination(current_node_selected)


func add_destination(node: WorldMapNode):
	if not node in bind_dest_array && node != bind_origin:
		if node.owner.are_level_nodes_bounded(bind_origin, node):
			return
		bind_dest_array.append(node)
		current_node_selected.set_editor_select_state(WorldMapNode.EDITOR_SELECTED.BIND_DESTINATION)
		generate_button("Confirm bind")


func destroy_every_buttons():
	for key in button_dict.keys():
		destroy_button(key)


func is_object_handled(obj: Object) -> bool:
	if obj == null: return false
	for obj_class in handeled_objects:
		if obj.is_class(obj_class):
			return true
	return false


#### VIRTUALS ####



#### LOGIC ####

func generate_button(button_name: String):
	var snake_cased_button_name = button_name.to_lower().replace(" ", "_")
	
	if !button_dict.has(button_name) or button_dict[button_name] == null:
		button_dict[button_name] = Button.new()
		button_dict[button_name].set_text(button_name)
		add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, button_dict[button_name])
		var _err = button_dict[button_name].connect("pressed", self, "_on_" + snake_cased_button_name + "_button_pressed")
		
		if debug_mode:
			print(button_name + " button added")


func destroy_button(button_name: String):
	var button = button_dict[button_name] if button_dict.has(button_name) else null
	if button != null:
		button.queue_free()
		button_dict.erase(button_name)
		if debug_mode:
			print(button_name + " button destroyed")


func _unselect_all_level_nodes() -> void:
	if bind_origin != null:
		bind_origin.set_editor_select_state(WorldMapNode.EDITOR_SELECTED.UNSELECTED)
	
	for node in bind_dest_array:
		node.set_editor_select_state(WorldMapNode.EDITOR_SELECTED.UNSELECTED)


func forward_canvas_gui_input(event: InputEvent) -> bool:
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		var selection = editor_interface.get_selection()
		var selected_nodes = selection.get_selected_nodes()
		
		if selected_nodes.empty():
			destroy_every_buttons()
		
		if !event.is_pressed():
			for node in selected_nodes:
				var level_node_pos = selected_nodes[0].get_position()
				if level_node_pos == last_level_node_pos:
					break
				
				if node is WorldMapNode:
					node.emit_signal("position_changed")
		else:
			if !selected_nodes.empty():
				last_level_node_pos = selected_nodes[0].get_position()
	
	return false



#### INPUTS ####



#### SIGNAL RESPONSES ####


func _on_create_bind_button_pressed():
	if !bind_mode:
		set_bind_mode(true)
		bind_origin = current_node_selected
		current_node_selected.set_editor_select_state(WorldMapNode.EDITOR_SELECTED.BIND_ORIGIN)


func _on_confirm_bind_button_pressed():
	for bind_dest in bind_dest_array:
		bind_origin.emit_signal("add_bind_query", bind_origin, bind_dest)
	
	set_bind_mode(false)


func _on_abort_bind_button_pressed():
	set_bind_mode(false)


func _on_delete_binds_button_pressed():
	current_node_selected.emit_signal("remove_all_binds_query", current_node_selected)


func _on_previous_texture_button_pressed():
	if current_node_selected is WorldMapBackgroundElement:
		current_node_selected.increment_texture_index(-1)


func _on_next_texture_button_pressed():
	if current_node_selected is WorldMapBackgroundElement:
		current_node_selected.increment_texture_index(1)


func _on_random_texture_button_pressed():
	if current_node_selected is WorldMapBackgroundElement:
		current_node_selected.randomise_texture()


func _on_reroll_bind_gen_button_pressed():
	if current_node_selected is LevelNodeBind:
		current_node_selected.reroll_line_gen()


func _on_world_map_node_removed(node: Node) -> void:
	if node is WorldMapNode:
		node.emit_signal("remove_all_binds_query", node)
