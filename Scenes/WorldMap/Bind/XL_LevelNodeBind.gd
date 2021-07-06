tool
extends LevelNodeBind
class_name XL_LevelNodeBind

#### ACCESSORS ####

func is_class(value: String): return value == "XL_LevelNodeBind" or .is_class(value)
func get_class() -> String: return "XL_LevelNodeBind"


#### BUILT-IN ####



#### VIRTUALS ####



#### LOGIC ####

func get_every_branching_line(tip_node: WorldMapNode, array_to_fill: Array, bind_line: Line2D = line):
	if not bind_line in array_to_fill:
		array_to_fill.append(bind_line)
	
	var tip_to_fetch = "start_cap_node" if tip_node == origin else "end_cap_node"
	for child in bind_line.get_children():
		if not child is XL_BindLine or (child.start_cap_node == null && child.end_cap_node == null):
			continue
		
		if child.get(tip_to_fetch) == tip_node:
			get_every_branching_line(tip_node, array_to_fill, child)



#### INPUTS ####



#### SIGNAL RESPONSES ####
