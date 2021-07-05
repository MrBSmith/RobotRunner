extends MenuBase
class_name InputMenu

#Get the ActionList node, which is type VBoxContainer. It will contains all the visual input information
onready var _action_list = get_node("CanvasLayer/Column/ScrollContainer/ActionList")


func _ready():
	# profile_changed is emited at line78 of '$InputMapper.gd'
	var _err = $InputMapper.connect('profile_changed', self, 'rebuild')
	
	#Initialize all labels to display the profiles in the dropdown element and inputs
	$CanvasLayer/Column/ProfilesMenu.initialize($InputMapper)

#This function will be executed when the signal from $InputMapper.gd [Line 78] will be emited.
func rebuild(input_profile, is_customizable = false):
	_action_list.clear()
	for input_action in input_profile.keys():
		var line = _action_list.add_input_line(input_action, \
			input_profile[input_action], is_customizable)
			
		if is_customizable: #If is_customizable is false, the "Change" button will be grey and not clickable.
			var _err = line.connect('change_button_pressed', self, \
				'_on_InputLine_change_button_pressed', [input_action, line])
			#When change button has  been clicked, send the signal change_button_pressed to self

func _on_InputLine_change_button_pressed(action_name, line):
	set_process_input(false)
	$CanvasLayer/KeySelectMenu.open()
	var key_scancode = yield($CanvasLayer/KeySelectMenu, "key_selected")
	$InputMapper.change_action_key(action_name, key_scancode)
	line.update_key(key_scancode)
	
	#Resume the process when the user pressed a key
	set_process_input(true)

#If the player press the ui_cancel button (ref to the project settings, might me ESCAPE)
#It will queue free the menu and back to the game
func _input(event):
	if event.is_action_pressed('ui_cancel'):
		save_changes()
		queue_free()
		get_tree().paused = false

#This function will queue free the Input Menu and back to the game
func _on_PlayButton_pressed():
	save_changes()
	queue_free()
	get_tree().paused = false

#Save all input changes if the player press Play button or Escape Key in the Input Menu
#To optimize the execution, we want to make sure that this method is only executed if the player IS NOT in the Custom Profile
#	Reason : change_action_key is immediately executed when the player change a key so it is useless to execute the method again
#	When the player leaves the menu
func save_changes():
	if $InputMapper.current_profile_id != $InputMapper.CUSTOM_PROFILE:
		for action_name in $InputMapper.get_selected_profile().keys():
			$InputMapper.change_action_key(action_name, $InputMapper.get_selected_profile()[action_name])
