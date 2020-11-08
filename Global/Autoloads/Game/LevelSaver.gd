extends Node

export var debug : bool = false

var objects_datatype_storage = {
	'BreakableObjectBase': [],
	'Checkpoint': ['active'],
	'Event': [],
	'DoorButton':['is_push'],
	'Door':['is_open']
}

#### ACCESSORS ####



#### BUILT-IN ####



#### LOGIC ####

func save_level(level: Node, dict_to_fill: Dictionary):
	dict_to_fill.clear()
	save_level_as_tscn(level)
	save_level_state(level, dict_to_fill)
	
	if debug:
		print_level_data(dict_to_fill)


# Save the level in a .tscn file
func save_level_as_tscn(level: Node2D):
	var saved_level = PackedScene.new()
	saved_level.pack(level)
	var _err = ResourceSaver.save("res://Scenes/Levels/SavedLevel/saved_level.tscn", saved_level)
	GAME.progression.saved_level = saved_level


# Find recursivly every wanted nodes
func save_level_state(current_node : Node, dict_to_fill : Dictionary):
	var classes_to_scan_array = objects_datatype_storage.keys()
	for child in current_node.get_children():
		for node_class in classes_to_scan_array:
			if child.is_class(node_class):
				var object_properties = get_object_properties(child, node_class)
				
				dict_to_fill[child.get_path()] = object_properties
				continue
		
		if child.get_child_count() != 0:
			save_level_state(child, dict_to_fill)


# Take an object, find every properties needed in it and retrun the data as a dict
func get_object_properties(object : Object, classname : String) -> Dictionary:
	var property_list : Array = objects_datatype_storage[classname]
	var property_data_dict : Dictionary = {}
	property_data_dict['name'] = object.get_name()
	
	for property in property_list:
		if property in object:
			property_data_dict[property] = object.get(property)
		else:
			print("Property : " + property + " could not be found in " + object.name)

	return property_data_dict


func print_level_data(dict: Dictionary):
	for obj_path in dict.keys():
		for property in dict[obj_path].keys():
			var to_print = property + ": " + String(dict[obj_path][property])
			if property != "name":
				to_print = "	" + to_print
			print(to_print)


#### VIRTUALS ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
