extends RobotPlatformBase
class_name BouncingPlatform

func is_class(value: String): return value == "BouncingPlatform" or .is_class(value)
func get_class() -> String: return "BouncingPlatform"

export var bodies_trigger_array : PoolStringArray = []

export var bouncing_duration : float = 0
export var bouncing_impulse_force := Vector2.ZERO

onready var platform_collisionshape_node = $CollisionShape2D

#### ACCESSORS ####

#### BUILT-IN ####

func _ready():
#	if "trigger_cooldown" in $TriggerArea:
#		$TriggerArea.set_trigger_cooldown(bouncing_duration + 0.3)
	pass

#### VIRTUALS ####

#### LOGIC ####

func bounce(body : Node):
	set_state("Bouncing")
	impulse_object(body)
	animated_sprite_node.set_flip_h(bouncing_impulse_force.x > 0)

# Hit the targetted object with an impulsion
func impulse_object(body : Node): 
	if body.has_method("add_impulse"):
		body.add_impulse("bounce", bouncing_impulse_force)

#### INPUTS ####

#### SIGNAL RESPONSES ####

# Function override
func _on_area_trigger_triggered():
	var body = $AreaTrigger.instance_triggering
	._on_area_trigger_triggered()
	bounce(body)
