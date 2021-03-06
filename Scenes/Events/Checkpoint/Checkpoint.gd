extends Event
class_name Checkpoint

export var active : bool = false setget set_active, is_active

onready var animated_sprite_node = $AnimatedSprite

var is_ready : bool = false

#### ACCESSORS ####

func is_class(value: String): return value == "Checkpoint" or .is_class(value)
func get_class() -> String: return "Checkpoint"

func set_active(value : bool):
	if !is_ready:
		yield(self, "ready")
	
	active = value
	if active:
		activate_checkpoint(!$AreaTrigger.set_enabled(false))

func is_active() -> bool: return active

#### BUILT-IN ####

func _ready():
	var _err = animated_sprite_node.connect("animation_finished", self, "on_animation_finished")
	
	is_ready = true

#### VIRTUALS ####

func event():
	set_active(true)
	EVENTS.emit_signal("checkpoint_reached", get_tree().get_current_scene(), get_index())


#### LOGIC ####

func trigger_animation():
	animated_sprite_node.play("Trigger")
	$AnimationPlayer.play("LightUp")


func activate_checkpoint(instant: bool = false):
	if !instant:
		trigger_animation()
	else:
		$AnimatedSprite/Light2D.set_energy(1.0)
		animated_sprite_node.play("Trigger")


#### SIGNAL RESPONSES ####

func on_animation_finished():
	if animated_sprite_node.get_animation() == "Trigger":
		animated_sprite_node.play("Active")
