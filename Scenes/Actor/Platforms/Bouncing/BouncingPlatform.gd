extends RobotPlatformBase
class_name BouncingPlatform

func is_class(value: String): return value == "BouncingPlatform" or .is_class(value)
func get_class() -> String: return "BouncingPlatform"

export var bouncing_duration : float = 0

#### ACCESSORS ####

#### BUILT-IN ####

func _ready():
	if $TriggerArea != null:
		var _err = $TriggerArea.connect("area_triggered", self, "on_bouncing_area_triggered")
		if "trigger_cooldown" in $TriggerArea:
			$TriggerArea.set_trigger_cooldown(bouncing_duration + 0.5)

#### VIRTUALS ####

#### LOGIC ####

#### INPUTS ####

#### SIGNAL RESPONSES ####

func on_bouncing_area_triggered():
	set_state("Bouncing")
