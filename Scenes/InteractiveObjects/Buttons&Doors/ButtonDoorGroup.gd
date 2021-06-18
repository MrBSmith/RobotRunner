tool
extends Node2D
class_name ButtonDoorGroup

var button_line_door_scene = preload("res://Scenes/InteractiveObjects/Buttons&Doors/ButtonLineDoor/ButtonLineDoor.tscn")

signal door_added(door)
signal door_removed(door)
signal button_added(button)
signal button_removed(button)

#### BUILT-IN ####

func _ready():
	if Engine.editor_hint:
		var scene_tree = get_tree()
		var _err = scene_tree.connect("node_added", self, "_on_tree_node_added")
		_err = scene_tree.connect("node_removed", self, "_on_tree_node_removed")
		_err = connect("door_added", self, "_on_door_added")
		_err = connect("door_removed", self, "_on_door_removed")
		_err = connect("button_added", self, "_on_button_added")
		_err = connect("button_removed", self, "_on_button_removed")
	else:
		for button in fetch_buttons():
			var _err = button.connect("triggered", self, "_on_button_triggered")
			_err = button.connect("untriggered", self, "_on_button_untriggered")
		
		for door in fetch_doors():
			if door is GreatDoor:
				var _err = door.connect("opened_changed", self, "_on_great_door_opened_changed")

#### LOGIC ####

func fetch_buttons() -> Array:
	var buttons_array = []
	for child in get_children():
		if child is DoorButton:
			buttons_array.append(child)
	return buttons_array


func fetch_doors() -> Array:
	var doors_array = []
	for child in get_children():
		if child is Door:
			doors_array.append(child)
	return doors_array


func open_all_doors(open: bool = true) -> void:
	for child in get_children():
		if child.is_class("Door"):
			child.open(open)


func are_all_button_triggered() -> bool:
	for child in get_children():
		if child.is_class("DoorButton"):
			if !child.is_pushed():
				return false
	return true


#### SIGNAL RESPONSES ####

func _on_button_triggered() -> void:
	if are_all_button_triggered():
		open_all_doors()


func _on_button_untriggered() -> void:
	open_all_doors(false)


func _on_tree_node_added(node: Node) -> void:
	if node.get_parent() != self:
		return
	
	if node is Door:
		emit_signal("door_added", node)
	elif node is DoorButton:
		emit_signal("button_added", node)


func _on_tree_node_removed(node: Node) -> void:
	if node.get_parent() != self:
		return
	
	if node is Door:
		emit_signal("door_removed", node)
	
	elif node is DoorButton:
		emit_signal("button_removed", node)


func _on_door_added(door: Door) -> void:
	var buttons_array = fetch_buttons()
	print("%s added" % door.name)
	
	for button in buttons_array:
		var line = button_line_door_scene.instance()
		button.call_deferred("add_child", line)
		line.set_door_node_path(String(door.get_path()))
		line.call_deferred("set_owner", owner)
		print("Connected %s to %s" % [button.name, door.name])


func _on_door_removed(door: Door) -> void:
	var buttons_array = fetch_buttons()
	print("%s removed" % door.name)
	
	for button in buttons_array:
		for child in button.get_children():
			if child is ButtonLineDoor && child.get_door_node_path() == String(door.get_path()):
				print("Disconnect %s form %s" % [button.name, door.name])
				child.queue_free()


func _on_button_added(button: DoorButton) -> void:
	var doors_array = fetch_doors()
	print("%s added" % button.name)
	
	for door in doors_array:
		var line = button_line_door_scene.instance()
		button.call_deferred("add_child", line)
		line.call_deferred("set_owner", owner)
		line.set_door_node_path(String(door.get_path()))
		print("Connected %s to %s" % [button.name, door.name])


func _on_button_removed(_button: DoorButton) -> void:
	pass


func _on_great_door_opened_changed(open: bool):
	if open:
		for button in fetch_buttons():
			if button is DoorPushButton:
				button.set_stay_triggered(true)
