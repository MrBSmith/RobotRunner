extends Event

export var active : bool = false

onready var animated_sprite_node = $AnimatedSprite

signal checkpoint_reached

func _ready():
	var _err
	_err = animated_sprite_node.connect("animation_finished", self, "on_animation_finished")
	_err = connect("checkpoint_reached",GAME,"on_checkpoint_reached")

func event():
	emit_signal("checkpoint_reached")
	trigger_animation()


func trigger_animation():
	animated_sprite_node.play("Trigger")
	$AnimationPlayer.play("LightUp")


func set_active(value : bool):
	active = value
	if active:
		trigger_animation()
		for area in triggers_area_array:
			area.get_node("CollisionShape2D").call_deferred("set_disabled", true)


func on_animation_finished():
	if animated_sprite_node.get_animation() == "Trigger":
		animated_sprite_node.play("Active")
