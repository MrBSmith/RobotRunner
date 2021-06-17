tool
extends Liquid
class_name Water

#### WATER ####

## USE: CHANGE THE SIZE OF THE POOL BY CHANGING THE SCALE OF THIS NODE ##
## PLEASE DO NOT CHANGE CHILDREN SIZE OR SCALE TO CHANGE THE SIZE ##

onready var iceblock_scene = load("res://Scenes/InteractiveObjects/BreakableObjects/Blocks/IceBlock/M/MIceBlock.tscn")
onready var floating_line_node = get_node_or_null("FloatingLine")

var M_IceBlocks_node : Node2D

#### ACCESSORS ####

func is_class(value: String): return value == "Water" or .is_class(value)
func get_class() -> String: return "Water"


#### BUILT-IN ####

func _ready():
	var size = $LiquidShader.get_region_rect().size
	floating_line_node.set_position(Vector2(0, -size.y / 2))

#### LOGIC ####

# Create an iceblock on interaction, the position of the hit box has to be inside the water area to truly happen
func interact(global_pos : Vector2):
	if collision_shape != null:
		if is_position_in_area(global_pos, collision_shape):
			var iceblock = iceblock_scene.instance()
			add_child(iceblock)
			iceblock.set_global_position(global_pos)
			iceblock.set_floating_line(floating_line_node.global_position.y)


# Return true if the given position is inside the given area, false if not
func is_position_in_area(pos: Vector2, collision_shape : CollisionShape2D) -> bool:
	var shape_pos = collision_shape.get_global_position()
	var shape_ext = collision_shape.get_shape().get_extents()
	
	return pos.y > shape_pos.y - shape_ext.y && pos.y < shape_pos.y + shape_ext.y && pos.x > shape_pos.x - shape_ext.x && pos.x < shape_pos.x + shape_ext.x


# Setup the floating on the given body
func body_floating(body : PhysicsBody2D, float_or_not : bool):
	if !body.has_method("set_floating"):
		return
	
	body.set_floating(float_or_not)
	
	if float_or_not == true:
		body.floating_line_y = floating_line_node.global_position.y


#### SIGNAL RESPONSES ####

# Make every ice block floating while they are in the water area
func on_body_entered(body):
	if body.is_class("IceBlock"):
		body_floating(body, true)
		
	if body is RigidBody2D or body is KinematicBody2D:
		particules_node.global_position.x = body.global_position.x
		particules_node.set_emitting(true)


# Whenever a body exits the area of this interact object, set his interact reference to null
func on_body_exited(body):
	if body.is_class("IceBlock"):
		body_floating(body, false)
