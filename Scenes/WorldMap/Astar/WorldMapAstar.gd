extends AStar2D
class_name WorldMapAStar

#### ACCESSORS ####

func is_class(value: String): return value == "WolrdMapAStar" or .is_class(value)
func get_class() -> String: return "WolrdMapAStar"


#### BUILT-IN ####



#### VIRTUALS ####

func _compute_cost(_from_id: int, _to_id: int) -> float:
	return 1.0


func _estimate_cost(_from_id: int, _to_id: int) -> float:
	return 1.0


#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
