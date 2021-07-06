extends MenuBase
class_name InputMenu

#Get the ActionList node, which is type VBoxContainer. It will contains all the visual input information
onready var _action_list = get_node("CanvasLayer/Column/ScrollContainer/ActionList")
onready var inputmapper_node = get_node_or_null("InputMapper")
onready var profiles_menu_node = get_node_or_null("CanvasLayer/Column/ProfilesMenu")
onready var key_select_menu = get_node_or_null("CanvasLayer/KeySelectMenu")

#### ACCESSORS ####

#### BUILT-IN ####

func _ready():
	# profile_changed is emited from inputmapper_node.gd
	var _err = inputmapper_node.connect('profile_changed', self, '_update')
	
	#Initialize all labels to display the profiles in the dropdown element and inputs
	profiles_menu_node.initialize(inputmapper_node)

#### LOGIC ####

#This method update the entire input menu and display all the action names and action keys according to a profile
#Will be executed when the signal from inputmapper_node.gd will be emited.
func _update(input_profile : Dictionary, is_customizable = false):
	_action_list.clear()
	for input_action in input_profile.keys():
		var line = _action_list.add_input_line(input_action, \
			input_profile[input_action], is_customizable)
			
		if is_customizable: #If is_customizable is false, the "Change" button will be grey and not clickable.
			var _err = line.connect('change_button_pressed', self, \
				'_on_InputLine_change_button_pressed', [input_action, line])
			#When change button has  been clicked, send the signal change_button_pressed to self

#Save all input changes if the player press Play button or Escape Key in the Input Menu
#To optimize the execution, we want to make sure that this method is only executed if the player IS NOT in the Custom Profile
#	Reason : change_action_key is immediately executed when the player change a key so it is useless to execute the method again
#	When the player leaves the menu
func _save_changes():
	if inputmapper_node.current_profile_id != inputmapper_node.PROFILES_PRESET.CUSTOM:
		for action_name in inputmapper_node.get_selected_profile().keys():
			inputmapper_node.change_action_key(action_name, inputmapper_node.get_selected_profile()[action_name])

#### INPUT ####

#If the player press the ui_cancel button (ref to the project settings, might me ESCAPE)
#It will queue free the menu and back to the game
func _input(event : InputEvent):
	if event.is_action_pressed('ui_cancel'):
		_save_changes()
		queue_free()
		get_tree().paused = false

#### SIGNAL RESPONSES ####

func _on_InputLine_change_button_pressed(action_name : String, line : InputLine):
	set_process_input(false)
	key_select_menu.open()
	var key_scancode = yield(key_select_menu, "key_selected")
	inputmapper_node.change_action_key(action_name, key_scancode)
	line.update_key(key_scancode)
	
	#Resume the process when the user pressed a key
	set_process_input(true)

#This function will queue free the Input Menu and back to the game
func _on_PlayButton_pressed():
	_save_changes()
	queue_free()
	get_tree().paused = false
