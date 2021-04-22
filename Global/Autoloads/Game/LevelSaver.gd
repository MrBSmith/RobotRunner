extends Node
class_name LevelSaver

const objects_datatype_storage = {
	"Collectable" : [],
	"BreakableObjectBase" : [],
	"Door" : ["open"],
	"DoorButton": ["push"],
	"Checkpoint": ["active"]
}

#### ACCESSORS ####

func is_class(value: String): return value == "LevelSaver" or .is_class(value)
func get_class() -> String: return "LevelSaver"


#### SAVE LEVEL ####

# Find recursivly every wanted nodes, and extract their wanted properties
static func serialize_level_properties(current_node : Node, dict_to_fill : Dictionary):
	var classes_to_scan_array = objects_datatype_storage.keys()
	for child in current_node.get_children():
		for node_class in classes_to_scan_array:
			if child.is_class(node_class):
				var object_properties = get_object_properties(child, node_class)
				
				dict_to_fill[child.get_path()] = object_properties
				continue
		
		if child.get_child_count() != 0:
			serialize_level_properties(child, dict_to_fill)


# Convert the data to a JSON file
static func save_level_properties_as_json(dir: String, level : Level):
	var dict_to_json : Dictionary = {}
	serialize_level_properties(level, dict_to_json)
	
	var json_file = File.new()
	var err = json_file.open(dir + "/" + level.name + ".json", File.WRITE)
	
	json_file.store_line(to_json(dict_to_json))
	json_file.close()


#### LOAD LEVEL ####


static func deserialize_level_properties(file_path : String) -> Dictionary:
	var level_properties  : String = ""
	var parsed_data : Dictionary = {}
	var load_file = File.new()
	
	if !load_file.file_exists(file_path):
		return parsed_data
	
	load_file.open(file_path, load_file.READ)
	level_properties = load_file.get_as_text()
	parsed_data = parse_json(level_properties)
	load_file.close()
	
	return parsed_data


# Take an object, find every properties needed in it and retrun the data as a dict
static func get_object_properties(object : Object, classname : String) -> Dictionary:
	var property_list : Array = objects_datatype_storage[classname]
	var property_data_dict : Dictionary = {}
	property_data_dict['name'] = object.get_name()
	
	for property in property_list:
		if property in object:
			property_data_dict[property] = object.get(property)
		elif object.has_method("get_" + property):
			property_data_dict[property] = object.call("get_" + property)
		else:
			print("Property : " + property + " could not be found in " + object.name)

	return property_data_dict


# LOADER DEBUG METHOD
# Print the current state of the level data
static func print_level_data(dict: Dictionary):
	for obj_path in dict.keys():
		for property in dict[obj_path].keys():
			var to_print = property + ": " + String(dict[obj_path][property])
			if property != "name":
				to_print = "	" + to_print
			print(to_print)


# Load the json file corresponding to the given level_name
# Return a dictionary containing every objects with their path as a key and a property dict as value
# The property dict contains each property name as key and property value as value
static func load_level_properties_from_json(dir: String, level_name : String) -> Dictionary:
	var loaded_level_properties : Dictionary = {}
	var loaded_objects : Dictionary = deserialize_level_properties(dir + level_name + ".json")
	for object_dict in loaded_objects.keys():
		var property_dict : Dictionary = {}
		for keys in loaded_objects[object_dict].keys():
			if keys == "name":
				continue
			var property_value
			var string_property_value = String(loaded_objects[object_dict][keys])
			match get_string_value_type(string_property_value):
				"Vector2" : property_value = get_vector_from_string(string_property_value)
				"int"  : property_value = int(string_property_value)
				"float" : property_value = float(string_property_value)
				"bool" : property_value = get_bool_from_string(string_property_value)
			property_dict[keys] = property_value
		loaded_level_properties[object_dict] = property_dict
	
	return loaded_level_properties


static func build_level_from_loaded_properties(dir: String, level : Level):
	if !level.is_inside_tree():
		yield(level, "tree_entered")
	
	var level_properties : Dictionary = load_level_properties_from_json(dir, level.get_name())
	level.apply_loaded_properties(level_properties)


# Get the type of a value string (vector2 bool float or int) by checking its content
static func get_string_value_type(value : String) -> String: 
	if '(' in value:
		return "Vector2"
	if value.countn('true') == 1 or value.countn('false') == 1:
		return "bool"
	if '.' in value:
		return "float"
		
	return "int"


# Navigate through SAVE_DIR/tscn/ and /json/ then remove all files and folders there
### IGNORE . , .. , AND HIDDEN FILES/FOLDERS 
#### ARGS : display_warning (DEBUG.gd > on game start > true = display warnings)
#### ARGS : display_warning (NewGame.gd > when button NewGame pressed on menu > false = doesn't display warnings)
static func delete_all_level_temp_saves(dir_path: String, display_warning : bool = false):
	var dir = Directory.new()
	
	var folders_array : Array = [dir_path]
	
	for folder in folders_array:
		if dir.open(folder) == OK:
			if display_warning:
				print(folder + " has been opened successfully")
			dir.list_dir_begin(true, true)
			var file_name = dir.get_next()
			if display_warning:
				if file_name == "":
					print("No folder or file detected in " + folder)
			while file_name != "":
				if dir.current_is_dir():
					if display_warning:
						print("Found dir: " + file_name)
					dir.remove(file_name)
				else:
					if display_warning:
						print("Found file: " + file_name)
					dir.remove(file_name)
				file_name = dir.get_next()
			dir.list_dir_end()
		else:
			print("An error occured when trying to access the path : " + folder)


# Delete the .json temporary saves
static func delete_level_temp_saves(dir_path: String, level_name: String):
	var dir = Directory.new()
	var json_path : String = dir_path + level_name + ".json"
	
	if dir.file_exists(json_path):
		dir.remove(json_path)


# Convert String variable to Vector2 by removing some characters and splitting commas
# return Vector2
static func get_vector_from_string(string_vector : String) -> Vector2:
	string_vector = string_vector.trim_prefix('(')
	string_vector = string_vector.trim_suffix(')')
	var split_string_array = string_vector.split(',')
	split_string_array[1] = split_string_array[1].trim_prefix(' ')
	return Vector2(float(split_string_array[0]),float(split_string_array[1]))


# Convert String variable to Boolean
# return bool
static func get_bool_from_string(string_bool : String) -> bool:
	return string_bool.countn('true') == 1
