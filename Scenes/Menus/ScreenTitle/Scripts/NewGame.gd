extends MenuOptionsBase

# Give mainscene path, so it can be changed later (or loaded?)
onready var strMainScene = "res://Scenes/Main/Game.tscn"

# Player Selection -> New Game
func on_pressed():
	var _err = GAME.goto_next_level()
