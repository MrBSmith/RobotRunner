extends Control

onready var _action_list = get_node("CanvasLayer/Column/ScrollContainer/ActionList")
var screen_width : float = ProjectSettings.get("display/window/size/width")
var screen_height : float = ProjectSettings.get("display/window/size/height")

func _ready():
	$InputMapper.connect('profile_changed', self, 'rebuild')
	$CanvasLayer/Column/ProfilesMenu.initialize($InputMapper)
	$InputMapper.change_profile($CanvasLayer/Column/ProfilesMenu.selected)
	margin_left = -screen_width
	margin_top = -screen_height
	
func rebuild(input_profile, is_customizable=false):
	_action_list.clear()
	for input_action in input_profile.keys():
		var line = _action_list.add_input_line(input_action, \
			input_profile[input_action], is_customizable)
		if is_customizable:
			line.connect('change_button_pressed', self, \
				'_on_InputLine_change_button_pressed', [input_action, line])

func _on_InputLine_change_button_pressed(action_name, line):
	set_process_input(false)
	
	$KeySelectMenu.open()
	var key_scancode = yield($KeySelectMenu, "key_selected")
	$InputMapper.change_action_key(action_name, key_scancode)
	line.update_key(key_scancode)
	
	set_process_input(true)

func _input(event):
	if event.is_action_pressed('ui_cancel'):
		queue_free()
		get_tree().paused = false

func _on_PlayButton_pressed():
	queue_free()
	get_tree().paused = false
