extends Node
class_name GameSaver

const debug : bool = false

#### LOGIC ####

# Create the directories 
static func create_dirs(dir_path : String, directories_to_create : Array):
	var dir = Directory.new()
	
	if !is_dir_exist(dir_path):
		dir.open("res://")
		dir.make_dir(dir_path)
	
	for directory_to_check in directories_to_create:
		if !is_dir_exist(dir_path + "/" + directory_to_check):
			if debug:
				print("DIRECTORY DOES NOT EXIST. Creating one in " + dir_path + "...")
			dir.open(dir_path)
			dir.make_dir(directory_to_check)
			
			var created_directory_path : String = dir_path + "/" + directory_to_check
			if debug:
				##### IF DEBUG THIS WILL DISPLAY IN THE CONSOLE THE NEWLY CREATED FILE
				print("Done ! Directory can in be found in : " + created_directory_path)


static func is_dir_exist(dir_path : String) -> bool:
	var dir = Directory.new()
	var dirExist : bool = dir.dir_exists(dir_path)
	return dirExist


# This method will return an array of every file considered as a SAVE FILE
static func find_all_saves_directories(dir: String) -> Array:
	var saves_directory = Directory.new()
	var error = saves_directory.open(dir)
	var files = []

	if error == OK:
		if debug:
			print("SUCCESSFULLY LOADED SETTINGS CFG FILE. SUCCESS CODE : " + str(error))
			print("From GameSaver.gd : Method Line 130 - Print Line 137+138")

		saves_directory.list_dir_begin(true, true)
		while true:
			var file = saves_directory.get_next()
			if file == "":
				break
			else:
				files.append(file)
		saves_directory.list_dir_end()

		return files

	else:
		if debug:
			print("FAILED TO LOAD SETTINGS CFG FILE. ERROR CODE : " + str(error))
		return []



#### SAVE GAME ####


# Get audio and controls project settings and set them into a dictionary.
# This dictionary _settings will be used later to save and load anytime a user wishes to
static func settings_update_keys(settings_dictionary : Dictionary, save_name : String = ""):
	for section in settings_dictionary:
			match(section):
				"system":
					settings_dictionary[section]["time"] = OS.get_datetime()
					settings_dictionary[section]["save_name"] = save_name
				"audio":
					for keys in settings_dictionary[section]:
						if str(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(keys.capitalize()))) == "-1.#INF":
							AudioServer.set_bus_volume_db(AudioServer.get_bus_index(keys.capitalize()), -100)
						settings_dictionary[section][keys] = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(keys.capitalize()))
				"controls":
					for keys in settings_dictionary[section]:
						settings_dictionary[section][keys] = InputMap.get_action_list(keys)[0].scancode
				"gameplay":
					for keys in settings_dictionary[section]:
						match(keys):
							"level_id":
								settings_dictionary[section][keys] = GAME.progression.get_level()
							"checkpoint_reached":
								settings_dictionary[section][keys] = GAME.progression.get_checkpoint()
							"xion":
								settings_dictionary[section][keys] = GAME.progression.get_xion()
							"gear":
								settings_dictionary[section][keys] = GAME.progression.get_gear()
				_:
					pass


# Transfer every temp level .json file to the given destination
static func transfer_level_save_to(temp_save_dir: String, dest_dir: String):
	var dir := Directory.new()
	
	if dir.open(temp_save_dir) == OK:
		var err = dir.list_dir_begin(true, true)
		print_debug("dir navigation error code: " + String(err))
		var file = dir.get_next()
		
		while file != "":
			err = dir.copy(temp_save_dir + "/" + file, dest_dir + "/" + file)
			print_debug("dir copy error code: " + String(err))
			file = dir.get_next()
		
		dir.list_dir_end()


static func settings_update_save_name(settings_dictionary  : Dictionary, save_name : String):
	settings_dictionary["system"]["save_name"] = save_name


# Save settings into a config file : res://saves/save1/2/3
static func save_settings(path : String, save_name : String):
	settings_update_keys(GAME._settings, save_name)
	for section in GAME._settings.keys():
		for key in GAME._settings[section]:
			GAME._config_file.set_value(section, key, GAME._settings[section][key])
			
	GAME._config_file.save(path + "/settings.cfg")



#### LOAD GAME ####


# Load the settings found in the ConfigFile settings.cfg at given path (default res://saves/save1/2/3
static func load_settings(dir: String, slot_id : int):
	var inputmapper = InputMapper.new()

	var save_name : String = find_corresponding_save_file(dir, slot_id)

	if save_name == "":
		return
	
	var save_path : String = dir + "/" + save_name + "/"
	var savecfg_path : String = dir + "/" + save_name + "/settings.cfg"
	
	var error = GAME._config_file.load(savecfg_path)

	if error == OK:
		if debug:
			print("SUCCESSFULLY LOADED SETTINGS CFG FILE. SUCCESS CODE : " + str(error))
			print("From GameSaver.gd : Method Line 87 - Print Line 102+103")
		for section in GAME._config_file.get_sections():
			match(section):
				"audio":
					#set audio settings
					for audio_keys in GAME._config_file.get_section_keys(section):
						AudioServer.set_bus_volume_db(AudioServer.get_bus_index(audio_keys.capitalize()), GAME._config_file.get_value(section, audio_keys))
				"controls":
					#set controls settings
					for control_keys in GAME._config_file.get_section_keys(section):
						inputmapper.change_action_key(control_keys, GAME._config_file.get_value(section, control_keys))
				"gameplay":
					for keys in GAME._config_file.get_section_keys(section):
						match(keys):
							"level_id": GAME.progression.set_level(GAME._config_file.get_value(section, keys))
							"checkpoint_reached": GAME.progression.set_checkpoint(GAME._config_file.get_value(section, keys))
							"xion": GAME.progression.set_xion(GAME._config_file.get_value(section, keys))
							"gear": GAME.progression.set_gear(GAME._config_file.get_value(section, keys))
				_:
					pass
	else:
		if debug:
			print("FAILED TO LOAD SETTINGS CFG FILE. ERROR CODE : " + str(error))
		return
	
	return save_path


# This method will return the path of the save file that has been found according to the specified save_id
static func find_corresponding_save_file(dir: String, save_id : int) -> String:
	for file in find_all_saves_directories(dir):

		var error = GAME._config_file.load(dir + "/" + file + "/settings.cfg")

		if error == OK:
			var file_save_id : int = GAME._config_file.get_value("system","slot_id")
			if save_id == file_save_id:
				return str(file)
		else:
			if debug:
				print("FAILED TO LOAD SETTINGS CFG FILE. ERROR CODE : " + str(error))
			return ""

	return ""


static func get_save_cfg_property_value_by_name_and_cfgid(dir: String, cfgproperty_name : String, save_id : int):
	var save_path : String

	save_path = find_corresponding_save_file(dir, save_id)
	
	var savecfg_path : String = dir + "/" + save_path + "/settings.cfg"
	var error = GAME._config_file.load(savecfg_path)
	
	if error == OK:
		if debug:
			print("SUCCESSFULLY LOADED SETTINGS CFG FILE. SUCCESS CODE : " + str(error))
			print("From GameSaver.gd : Method Line 180 - Print Line 192+193")
		for section in GAME._config_file.get_sections():
			for keys in GAME._config_file.get_section_keys(section):
				if keys == cfgproperty_name:
					var property_value = GAME._config_file.get_value(section, keys)
					return property_value
	else:
		if debug:
			print("FAILED TO LOAD SETTINGS CFG FILE. ERROR CODE : " + str(error))
		return ""
	
	return ""

