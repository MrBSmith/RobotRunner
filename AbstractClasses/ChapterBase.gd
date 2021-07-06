extends Resource
class_name ChapterBase

export var levels_scenes_array : Array

func load_all_levels():
	var levels_array : Array = []
	
	for scene in levels_scenes_array:
		var lvl = load(scene)
		levels_array.append(lvl)
	
	return levels_array


func get_level_id_by_path(level_path: String):
	return levels_scenes_array.find(level_path)

func find_level_path(level_name: String) -> String:
	var level_id = find_level_id(level_name)
	if level_id != -1:
		return levels_scenes_array[level_id]
	else:
		return ""


func load_next_level(level_name: String) -> Resource:
	var level_id = find_level_id(level_name)
	if level_id + 1 > levels_scenes_array.size():
		return null
	else:
		return load(levels_scenes_array[level_id + 1])

func get_level_name(id: int) -> String:
	var level_path : String = levels_scenes_array[id]
	var elem_array = level_path.split("/")
	var file_name = elem_array[elem_array.size() - 1]
	
	return file_name.split(".")[0]

func get_level_path(id: int) -> String:
	return levels_scenes_array[id]

# Return the index of a given string in a given array
# Return -1 if the string wasn't found
func find_level_id(level_name: String) -> int:
	var index = 0
	for string in levels_scenes_array:
		if level_name.is_subsequence_of(string) or level_name == string:
			return index
		else:
			index += 1
	return -1


func load_level(index: int) -> Resource:
	return load(levels_scenes_array[index])
