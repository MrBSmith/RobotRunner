extends Event

export var target_name : String = ""
export var target_as_group : bool = false
export var method_name : String = ""
export var arguments_array : Array = []
export var queue_free_after_trigger : bool = true


# Call the given method in a single target or a group target
# Pass any number of arguments stored in the arguments_array to this method
func event():
	# Check for an empty field, send an error if there is one
	if target_name == "" or method_name == "":
		print("ERROR : The event %s has an undefined target and/or method to call" % name)
		return
	
	# Get the target(s) and store it in target_array
	var target_array : Array = []
	if target_as_group:
		target_array = get_tree().get_nodes_in_group(target_name)
	else:
		target_array.append(get_tree().get_current_scene().find_node(target_name))
	
	# Call the method in every target, and pass every argument in the array
	for target in target_array:
		if target.has_method(method_name):
			var call_def_funcref := funcref(target, "call_deferred")
			arguments_array.push_front(method_name)
			call_def_funcref.call_funcv(arguments_array)
	
	# Queue free this event if it should be
	if queue_free_after_trigger:
		queue_free()
