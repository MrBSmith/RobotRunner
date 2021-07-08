extends Node
class_name Progression

export (int, -1, 99) var chapter = -1 setget set_chapter, get_chapter
export (int, -1, 99) var last_level = 0 setget set_last_level_id, get_last_level_id
export (int, -1, 99) var checkpoint = -1 setget set_checkpoint, get_checkpoint
#export (int, 0, 999) var dialogue = 0
export (int, 0, 999999999) var xion = 0 setget set_xion, get_xion
export (int, 0, 9999) var gear = 0 setget set_gear, get_gear

# Stock the scene path of every already visited levels 
var visited_levels := Array()

#### ACCESSORS ####

func set_chapter(value: int): chapter = value
func get_chapter() -> int: return chapter
func add_to_chapter(value: int): set_chapter(get_chapter() + value)

func set_last_level_id(value: int): last_level = value
func get_last_level_id() -> int: return last_level
func add_to_last_level_id(value: int): set_last_level_id(get_last_level_id() + value)

func set_checkpoint(value: int): checkpoint = value
func get_checkpoint() -> int: return checkpoint
func add_to_checkpoint(value: int): set_checkpoint(get_checkpoint() + value)

func set_xion(value: int):
	if xion != value:
		xion = value
		EVENTS.emit_signal("collectable_amount_updated", "Xion", xion)

func get_xion() -> int: return xion
func add_to_xion(value: int): set_xion(get_xion() + value)

func set_gear(value: int):
	if gear != value:
		gear = value
		EVENTS.emit_signal("collectable_amount_updated", "Gear", gear)

func get_gear() -> int: return gear
func add_to_gear(value: int): set_gear(get_gear() + value)


#### BUILT-IN ####

func _ready():
	var _err = EVENTS.connect("collectable_amount_collected", self, "_on_collectable_amount_collected")
	_err = EVENTS.connect("update_HUD", self, "_on_update_HUD")

#### LOGIC ####

func append_visited_level(level: Level) -> void:
	if not level is Level:
		push_error("The given value isn't a Level")
		return
	
	var level_scene_path = GAME.current_chapter.find_level_path(level.name)
	if not level_scene_path in visited_levels:
		visited_levels.append(level_scene_path)

func reload_save_ressources(save_id : int):
	if GameLoader.find_corresponding_save_file(GAME.SAVE_GAME_DIR, save_id) != "":
		set_gear(GameLoader.get_save_property_value(GAME.SAVE_GAME_DIR, "gear", save_id))
		set_xion(GameLoader.get_save_property_value(GAME.SAVE_GAME_DIR, "xion", save_id))
	else:
		set_gear(0)
		set_xion(0)

#### SIGNAL RESPONSES ####

func _on_collectable_amount_collected(obj: Collectable, amount: int):
	var col_type = obj.get_collectable_name()
	
	match(col_type):
		"Xion": add_to_xion(amount)
		"Gear": add_to_gear(amount)


func _on_update_HUD():
	EVENTS.emit_signal("collectable_amount_updated", "Xion", xion)
	EVENTS.emit_signal("collectable_amount_updated", "Gear", gear)
