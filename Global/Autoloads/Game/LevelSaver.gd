extends Node

export var debug : bool = false

var objects_datatype_storage = {
	'ParallaxLayer': ['position']
}

#### ACCESSORS ####



#### BUILT-IN ####



#### LOGIC ####

# Save the current state of the level: Call both the .tscn save and the serialized save in the given dict
func save_level(level: Node, dict_to_fill: Dictionary):
	dict_to_fill.clear()
	save_level_as_tscn(level)
	
	if debug:
		print_level_data(dict_to_fill)


# Save the level in a .tscn file
func save_level_as_tscn(level: Node2D):
	var saved_level = PackedScene.new()
	var level_name = level.get_name()
	saved_level.pack(level)
	var _err = ResourceSaver.save("res://Scenes/Levels/SavedLevel/tscn/saved_" + level_name + ".tscn", saved_level)
	GAME.progression.saved_level = saved_level


# Find recursivly every wanted nodes, and extract their wanted properties
func serialize_level_properties(current_node : Node, dict_to_fill : Dictionary):
	var classes_to_scan_array = objects_datatype_storage.keys()
	for child in current_node.get_children():
		for node_class in classes_to_scan_array:
			if child.is_class(node_class):
				var object_properties = get_object_properties(child, node_class)
				
				dict_to_fill[child.get_path()] = object_properties
				continue
		
		if child.get_child_count() != 0:
			serialize_level_properties(child, dict_to_fill)


# Take an object, find every properties needed in it and retrun the data as a dict
# => NEVER CALLED, Except by serialize_level_properties method
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

# Convert the data to a JSON file
# => Called by game.gd
func save_level_properties_as_json(file_name : String, level : Level):
	var dict_to_json : Dictionary
	serialize_level_properties(level, dict_to_json)
	
	var json_file = File.new()
	json_file.open("res://Scenes/Levels/SavedLevel/json/" + file_name + ".json", File.WRITE)
	json_file.store_line(to_json(dict_to_json))
	json_file.close()


# Print the current state of the level data
func print_level_data(dict: Dictionary):
	for obj_path in dict.keys():
		for property in dict[obj_path].keys():
			var to_print = property + ": " + String(dict[obj_path][property])
			if property != "name":
				to_print = "	" + to_print
			print(to_print)

func load_level_properties_from_json(level_loaded_from_scene : bool, level_name : String) -> Dictionary:
	var loaded_level_properties : Dictionary
	if level_loaded_from_scene:
		var loaded_objects : Dictionary = GAME.deserialize_level_properties("res://Scenes/Levels/SavedLevel/json/"+level_name+".json")
		for object_dict in loaded_objects.keys():
			var property_dict : Dictionary
			for keys in loaded_objects[object_dict].keys():
				if keys == "name":
					continue
				var property_value
				match get_string_value_type(loaded_objects[object_dict][keys]):
					"Vector2" : property_value = get_vector_from_string(loaded_objects[object_dict][keys])
					"int"  : property_value = int(loaded_objects[object_dict][keys])
					"float" : property_value = float(loaded_objects[object_dict][keys])
					"bool" : property_value = get_bool_from_string(loaded_objects[object_dict][keys])
				property_dict[keys] = property_value
			loaded_level_properties[object_dict] = property_dict
		#print(loaded_level_properties)
	return loaded_level_properties

func apply_properties_to_level(level : Level, dict_properties : Dictionary):
	for object_path in dict_properties.keys():
		object_path = object_path.trim_prefix('root/')
		var object = get_tree().get_root().get_node(object_path)
		for property in dict_properties[object_path].keys():
			object.set(property, dict_properties[object_path][property])
			print(object)

func build_level_from_loaded_properties(level : Level):
	var level_properties : Dictionary = load_level_properties_from_json(level.is_loaded_from_save, level.get_name())
	apply_properties_to_level(level, level_properties)

# Get the type of a value string (vector2 bool float or int) by checking its content
func get_string_value_type(value : String) -> String:
	if '(' in value:
		return "Vector2"
	if value.countn('true') == 1 or value.countn('false') == 1:
		return "bool"
	if '.' in value:
		return "float"
		
	return "int"

# Convert String variable to Vector2 by removing some characters and splitting commas
# return Vector2
func get_vector_from_string(string_vector : String) -> Vector2:
	string_vector = string_vector.trim_prefix('(')
	string_vector = string_vector.trim_suffix(')')
	var split_string_array = string_vector.split(',')
	split_string_array[1] = split_string_array[1].trim_prefix(' ')
	return Vector2(float(split_string_array[0]),float(split_string_array[1]))

# Convert String variable to Boolean
# return bool
func get_bool_from_string(string_bool : String) -> bool:
	return string_bool.countn('true') == 1
	
#### VIRTUALS ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
