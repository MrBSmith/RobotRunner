extends MenuBase

onready var resume_label_node = get_node("HBoxContainer/V_OptContainer/Resume")
var screen_width : float = ProjectSettings.get("display/window/size/width")
var screen_height : float = ProjectSettings.get("display/window/size/height")


# Set the GUI layer to be at the origin of the screen
func _ready():
	resume_label_node.connect("resume", self, "on_resume")
	margin_left = -screen_width
	margin_top = -screen_height
	
func on_resume():
	queue_free()
