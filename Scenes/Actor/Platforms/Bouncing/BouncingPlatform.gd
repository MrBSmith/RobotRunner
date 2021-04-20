extends RobotPlatformBase
class_name BouncingPlatform

func is_class(value: String): return value == "BouncingPlatform" or .is_class(value)
func get_class() -> String: return "BouncingPlatform"

export var bodies_trigger_array : PoolStringArray = []

export var bouncing_duration : float = 0
export var bouncing_impulse_force : float = 750.0

onready var triggerarea_node = $TriggerArea
onready var platform_collisionshape_node = $CollisionShape2D
var triggerarea_body_trigger : PhysicsBody2D = null

#### ACCESSORS ####

#### BUILT-IN ####

func _ready():
	if $TriggerArea != null:
		var _err = $TriggerArea.connect("area_triggered", self, "on_bouncing_area_triggered")
		if "triggering_bodies" in $TriggerArea and !bodies_trigger_array.empty():
			$TriggerArea.triggering_bodies = bodies_trigger_array
		if "trigger_cooldown" in $TriggerArea:
			$TriggerArea.set_trigger_cooldown(bouncing_duration + 0.3)

#### VIRTUALS ####

#### LOGIC ####

func impulse_object(): # HIT THE TARGETTED OBJECT WITH AN IMPULSION
	#method code after physic refacto
	pass

#### INPUTS ####

#### SIGNAL RESPONSES ####

func on_bouncing_area_triggered():
	if triggerarea_node.body_triggerring_area != null:
		triggerarea_body_trigger = triggerarea_node.body_triggerring_area
			
		set_state("Bouncing")
		impulse_object()
