extends LineEdit
class_name SaveNameField

var namestaken_info_node
var submitsave_button
var save_folders : Array = []

#### ACCESSORS ####

func is_class(value: String): return value == "SaveNameField" or .is_class(value)
func get_class() -> String: return "SaveNameField"

#### BUILT-IN ####

func _ready():
	var _err
	_err = connect("text_changed", self, "_on_text_changed")
	
	save_folders = DirNavHelper.fetch_dir_content(GAME.SAVE_GAME_DIR, DirNavHelper.DIR_FETCH_MODE.DIR_ONLY)

#### LOGIC ####

func check_if_name_is_already_taken(name : String) -> bool:
	var is_taken : bool = false
	for savefile in save_folders:
		if savefile.to_upper().capitalize() == name.to_upper().capitalize():
			is_taken = true
			return is_taken
		else:
			is_taken = false
			continue
	return is_taken


#### VIRTUALS ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_text_changed(new_text):
	var allowed_characters = "[A-Za-z_ ]"
	var old_caret_position = self.caret_position
	
	var word = ''
	var regex = RegEx.new()
	regex.compile(allowed_characters)
	for textchar in regex.search_all(new_text):
		word += textchar.get_string()
	self.set_text(word)
	caret_position = old_caret_position
	
	if check_if_name_is_already_taken(word):
		namestaken_info_node.visible = true
		submitsave_button.disabled = true
	else:
		namestaken_info_node.visible = false
		submitsave_button.disabled = false
