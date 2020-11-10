extends Resource

class_name ChapterBase

export var levels_scenes_array : Array

func load_all_levels():
	var levels_array : Array = []
	
	for scene in levels_scenes_array:
		var lvl = load(scene)
		levels_array.append(lvl)
	
	return levels_array


func find_level_path(level_name: String) -> String:
	var level_id = find_level_id(level_name)
	return levels_scenes_array[level_id]


func load_next_level(level_name: String) -> Resource:
	var level_id = find_level_id(level_name)
	if level_id + 1 > levels_scenes_array.size():
		return null
	else:
		return load(levels_scenes_array[level_id + 1])

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
