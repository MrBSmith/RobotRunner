extends MenuBase
class_name InputMenu

#Get the ActionList node, which is type VBoxContainer. It will contains all the input information
onready var _action_list = get_node("CanvasLayer/Column/ScrollContainer/ActionList")


func _ready():
	# profile_changed is emited at line55 of '$InputMapper.gd'
	var _err = $InputMapper.connect('profile_changed', self, 'rebuild')
	
	#Initialize all labels to display the controls and profile
	$CanvasLayer/Column/ProfilesMenu.initialize($InputMapper)
	#$InputMapper.change_profile($CanvasLayer/Column/ProfilesMenu.selected)

#This function will be executed when the signal emited from $InputMapper.gd [Line 55] will be emited.
func rebuild(input_profile, is_customizable = false):
	_action_list.clear() #Free all the children of ActionList in order to rebuild a profile
	for input_action in input_profile.keys(): #For every keys in the profile
		var line = _action_list.add_input_line(input_action, \
			input_profile[input_action], is_customizable) #Adds a new line to the Action list node. Which will display them on the screen vertically, one after another
			#If is_customizable is false, the "Change" button will be grey and not clickable.
		if is_customizable:
			var _err = line.connect('change_button_pressed', self, \
				'_on_InputLine_change_button_pressed', [input_action, line])
			#When change button has  been clicked, send the signal change_button_pressed to self

#This function will set the process input to false, so that the player can change the input.
func _on_InputLine_change_button_pressed(action_name, line):
	set_process_input(false)
	
	#Open the KeySelectMenu node, it will make the background looks darker and display the coresponding label information
	$CanvasLayer/KeySelectMenu.open()
	#Get the scancode of the pressed key
	var key_scancode = yield($CanvasLayer/KeySelectMenu, "key_selected")
	#Change the profile's action according to the key the player pressed
	$InputMapper.change_action_key(action_name, key_scancode)
	#Set the pressed key and display it
	line.update_key(key_scancode)
	
	#Resume the process when the user pressed a key
	set_process_input(true)

#If the player press the ui_cancel button (ref to the project settings, might me ESCAPE) it will queue free the menu and back to the game
func _input(event):
	if event.is_action_pressed('ui_cancel'):
		queue_free()
		get_tree().paused = false

#This function will queue free the Input Menu and back to the game
func _on_PlayButton_pressed():
	#For loop to get all the profile's coresponding keys
	for action_name in $InputMapper.get_selected_profile().keys(): #get the name, get the key
		$InputMapper.change_action_key(action_name, $InputMapper.get_selected_profile()[action_name]) #change the key
		
	queue_free()
	get_tree().paused = false
