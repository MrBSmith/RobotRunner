extends RobotPlatformBase
class_name BouncingPlatform

func is_class(value: String): return value == "BouncingPlatform" or .is_class(value)
func get_class() -> String: return "BouncingPlatform"
export var debug : bool = false #DISABLE WHEN FEATURE IS FINISHED

export var bodies_trigger_array : PoolStringArray = []

export var bouncing_duration : float = 0
export var bouncing_impulse_force : float = 750.0

onready var platform_collisionshape_node = $CollisionShape2D
onready var platform_rebouncecollisionshape_node = $TriggerArea/RebounceCollisionShape

var rebounce : bool = false
var platform_body_trigger : PhysicsBody2D = null

#### ACCESSORS ####

#### BUILT-IN ####

func _ready():
	if $TriggerArea != null:
		var _err = $TriggerArea.connect("area_triggered", self, "on_bouncing_area_triggered")
		if "trigger_cooldown" in $TriggerArea:
			$TriggerArea.set_trigger_cooldown(bouncing_duration + 0.3)
			
	if platform_rebouncecollisionshape_node != null:
		platform_rebouncecollisionshape_node.set_disabled(true)

#### VIRTUALS ####

#### LOGIC ####

func impulse_object(): # HIT THE TARGETTED OBJECT WITH AN IMPULSION
	if debug:
		print(platform_body_trigger.get_class())
	
	if platform_body_trigger.is_class("ActorBase"):
		platform_body_trigger.velocity.y -= bouncing_impulse_force

#### INPUTS ####

#### SIGNAL RESPONSES ####

func on_bouncing_area_triggered(body_trigger : PhysicsBody2D):
	if !rebounce:
		if body_trigger != null:
			platform_body_trigger = body_trigger
			
		set_state("Bouncing")
		impulse_object()
	else:
		impulse_object()
