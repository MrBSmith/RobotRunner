tool
extends Sprite
class_name WorldMapBackgroundElement

export var texture_array = []
onready var texture_index = randi() % texture_array.size() setget set_texture_index, get_texture_index

#### ACCESSORS ####

func is_class(value: String): return value == "WorldMapBackgroundElement" or .is_class(value)
func get_class() -> String: return "WorldMapBackgroundElement"

func set_texture_index(value: int):
	if value < 0 or value >= texture_array.size():
		return
	
	texture_index = value
	set_texture(texture_array[texture_index])

func get_texture_index() -> int: return texture_index


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####

func increment_texture_index(amount: int = 1):
	set_texture_index(wrapi(get_texture_index() + amount, 0, texture_array.size()))


func randomise_texture():
	var rng = texture_index
	while(rng == texture_index):
		rng = randi() % texture_array.size()
	
	set_texture_index(rng)

#### INPUTS ####



#### SIGNAL RESPONSES ####
