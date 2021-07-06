extends StateBase
class_name LevelNode_VisibleState

#### ACCESSORS ####

func is_class(value: String): return value == "LevelNode_VisibleState" or .is_class(value)
func get_class() -> String: return "LevelNode_VisibleState"


#### BUILT-IN ####



#### VIRTUALS ####


func enter_state():
	owner.set_modulate(Color.white)
	owner.set_visible(true)

#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
