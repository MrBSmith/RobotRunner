extends Node
class_name ChapterGenerator

const chapter_dir_path : String = "res://Scenes/Levels/"
const chapter_base_script = preload("res://AbstractClasses/ChapterBase.gd")
const debug := false


# Generate the chapters ressources dynamicly based on the folder hierarchy
# Loop through every folders and files in the current dir
# If it finds a chapter, generate the chapter, add it to GAME's chapter_array, and then call itself
# If it finds a level add it to the last chapter generated
static func create_chapters(path : String = "", array_to_fill: Array = []):
	if path == "":
		if debug:
			print("ERROR: the create_chapters method has no specified path")
		return
	
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true)
		var current_file_name : String = dir.get_next()
		
		while current_file_name != "":
			if dir.current_is_dir():
				
				# If the current folder is a chapter folder: 
				# Create a new chapter and add it to the GAME chapters_array
				# Then continue digging into the folder hierachy
				if current_file_name.findn("chapter") != -1 or current_file_name.findn("debug") != -1:
					if debug:
						print("Found chapter directory: " + current_file_name)
					var new_chapter = Resource.new()
					new_chapter.script = chapter_base_script
					array_to_fill.append(new_chapter)
					var current_chapter_path = get_current_file_path(dir, current_file_name)
					create_chapters(current_chapter_path, array_to_fill)
				
				# If the current folder is a level folder, digging into the folder hierachy
				elif current_file_name.findn("level") != -1:
					if debug:
						print("   Found level directory: " + current_file_name)
					var current_level_path = get_current_file_path(dir, current_file_name)
					create_chapters(current_level_path, array_to_fill)
			
			# If the file is a level scene, store it in the last chapter ressource created
			else:
				if current_file_name.findn(".tscn") != -1 && current_file_name.findn("level") != -1:
					if debug:
						print("       Found level file: " + current_file_name)
					var current_scene_path = get_current_file_path(dir, current_file_name)
					var last_chapter_index = len(array_to_fill) - 1
					array_to_fill[last_chapter_index].levels_scenes_array.append(current_scene_path)
			
			# Access the next file/folder
			current_file_name = dir.get_next()
	
	else:
		if debug:
			print("ERROR : the directory '" + path + "' can't be found")


# Retruns the path of the current file pointed by the dir object
static func get_current_file_path(dir : Directory, current_file_name : String) -> String:
	return dir.get_current_dir() + "/" + current_file_name
