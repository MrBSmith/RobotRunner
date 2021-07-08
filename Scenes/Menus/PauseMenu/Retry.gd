extends MenuOptionsBase

func on_pressed():
	if(get_tree().paused):
		#Player Selection -> Retry on pause menu
		get_tree().paused = false
		var _err = GAME.goto_last_level()
