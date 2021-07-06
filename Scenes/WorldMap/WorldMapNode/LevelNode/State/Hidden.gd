extends StateBase
class_name LevelNode_HiddenState

#### ACCESSORS ####

func is_class(value: String): return value == "LevelNode_HiddenState" or .is_class(value)
func get_class() -> String: return "LevelNode_HiddenState"


#### BUILT-IN ####



#### VIRTUALS ####


func enter_state():
	owner.set_modulate(Color.white)
	owner.set_visible(false)

func exit_state():
	owner.set_visible(true)

#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
