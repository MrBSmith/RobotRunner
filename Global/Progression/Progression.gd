extends Resource

export (int, -1, 99) var chapter = -1 setget set_chapter, get_chapter
export (int, -1, 99) var level = 0 setget set_level, get_level
export (int, 0, 99) var checkpoint = 0 setget set_checkpoint, get_checkpoint
export (int, 0, 999) var dialogue = 0
export (int, 0, 999999999) var main_xion = 0 setget set_main_xion, get_main_xion
export (int, 0, 9999) var main_materials = 0 setget set_main_materials, get_main_materials

var saved_level : PackedScene
var main_stored_objects : Dictionary

#### ACCESSORS ####

func set_chapter(value: int): chapter = value
func get_chapter() -> int: return chapter
func add_to_chapter(value: int): set_chapter(get_chapter() + value)

func set_level(value: int): level = value
func get_level() -> int: return level
func add_to_level(value: int): set_level(get_level() + value)

func set_checkpoint(value: int): checkpoint = value
func get_checkpoint() -> int: return checkpoint
func add_to_checkpoint(value: int): set_checkpoint(get_checkpoint() + value)

func set_main_xion(value: int): main_xion = value
func get_main_xion() -> int: return main_xion
func add_to_main_xion(value: int): set_main_xion(get_main_xion() + value)

func set_main_materials(value: int): main_materials = value
func get_main_materials() -> int: return main_materials
func add_to_main_materials(value: int): set_main_materials(get_main_materials() + value)

# ! Collectable Progression Explaination !
#	- When a checkpoint is reached by any player, the <main>progression
#		(GAME.progression xion/materials) will get the current
#		<level>progression (SCORE.xion/materials) to save it.
#
#	- When a player die and didn't reach any checkpoint, the <main>progression
#		will remain at 0 and this value will be sent to the <level>progression
#		so that it prevents progression duplication.
#
#	- When a player die but he reached a checkpoint before,
#		the <main>progression will be sent to the <level>progression to LOAD
#		the lastest saved progression.
#
#	- When players go to the next level, the <level>progression will be saved
#		as well into the <main>progression. This works like the checkpoint
#		system.
#
#	- When players respawn in a level or appear when a level start,
#		the HUD will instantly refresh and display the lastest saved
#		<main> progression
