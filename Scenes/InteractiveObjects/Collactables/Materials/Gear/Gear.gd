extends CollactableBase
class_name MaterialCollactable

onready var timer_node = $Timer
onready var animated_sprite_node = $AnimatedSprite
onready var trigger_area_node = $TriggerArea

onready var raycast_node = $RayCast

var targeted_player : Player = null

func _physics_process(_delta):
	if targeted_player != null:
		raycast_node.search_for_target(targeted_player)


func _ready():
	var _err = timer_node.connect("timeout", self, "on_timer_timeout")
	_err = animated_sprite_node.connect("animation_finished", self, "on_animation_finished")
	_err = trigger_area_node.connect("body_entered", self, "on_trigger_area_body_entered")
	_err = trigger_area_node.connect("body_exited", self, "on_trigger_area_body_exited")
	_err = raycast_node.connect("target_found", self, "on_raycast_target_found")

	if is_collected:
		queue_free()

func on_timer_timeout():
	animated_sprite_node.play()
	timer_node.start()


func on_animation_finished():
	animated_sprite_node.set_frame(0)
	animated_sprite_node.stop()


func on_trigger_area_body_entered(body: PhysicsBody2D):
	if body is Player:
		raycast_node.search_for_target(body)


func on_trigger_area_body_exited(body: PhysicsBody2D):
	if body is Player:
		targeted_player = null


func on_raycast_target_found(target: Node):
	aimed_character_weakref = weakref(target)
	SCORE.on_approch_collactable()


func collect():
	.collect()
	animated_sprite_node.set_visible(false)
	SCORE.set_materials(SCORE.get_materials() + 1)
