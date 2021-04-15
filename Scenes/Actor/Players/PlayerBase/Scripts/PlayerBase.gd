extends ActorBase
class_name Player

#warning-ignore:unused_signal
signal layer_change

# Store all the children references
onready var inputs_node = get_node("Inputs")
onready var SFX_node = get_node("SFX")
onready var anim_player_node = get_node("AnimationPlayer")

export var player_id : int = 1 setget , get_player_id

var dirLeft : int = 0 
var dirRight : int = 0

var teleport_node : Area2D = null
var level_node : Node

var active : bool = true

#### ACCESSORS ####

func is_class(value: String): return value == "Player" or .is_class(value)
func get_class() -> String: return "Player"

func set_jump_force(value : int): jump_force = value
func get_jump_force() -> int: return jump_force

func get_extents() -> Vector2: return $CollisionShape2D.get_shape().get_extents()

func set_active(value: bool):
	active = value
	
	if active:
		set_modulate(Color.white)
	else:
		set_modulate(Color.gray)
		set_direction(Vector2.ZERO)

func get_active() -> bool: return active

func get_player_id() -> int : return player_id

#### BUILT-IN ####

func _ready():
	var _err = anim_player_node.connect("animation_finished", self, "on_animation_finished")
	_err = connect("layer_change", self, "on_layer_change")
	add_to_group("Players")


#### LOGIC ####


# Triggers the overheat animation
# Called by the cloud when a player enters it
func overheat():
	anim_player_node.play("Overheat")


# Triggers the fadeOut animation
# Called by the greatdoor when a player exit the level
func fade_out():
	anim_player_node.play("FadeOut")


# Stops the overheat animation
func stop_overheat():
	var anim : String = anim_player_node.get_current_animation()
	if anim == "Overheat":
		anim_player_node.stop(true)
		animated_sprite_node.set_modulate(Color.white)


# Called when the robot is destroyed, triggers the death animation, the gameover,
# and destroy this instance
func destroy():
	EVENTS.emit_signal("play_SFX", "normal_explosion", global_position)
	GAME.gameover()
	queue_free()

#### INPUT RESPONSES ####

func _input(event):
	if !active:
		return
	
	if event.is_action_pressed(inputs_node.get_input("MoveLeft")):
		dirLeft = 1
	
	elif event.is_action_released(inputs_node.get_input("MoveLeft")):
		dirLeft = 0
	
	elif event.is_action_pressed(inputs_node.get_input("MoveRight")):
		dirRight = 1
	
	elif event.is_action_released(inputs_node.get_input("MoveRight")):
		dirRight = 0
	
	set_direction(Vector2(dirRight - dirLeft, 0))


#### SIGNALS RESPONSES ####

# Triggers the explosion and the destruction of the robot
func on_animation_finished(animation: String):
	if animation == "Overheat":
		destroy()
	if animation == "FadeOut":
		queue_free()


func on_xion_received():
	anim_player_node.play("MagentaFlash")


# If the player is on a teleport point and enter layer change, teleport him to the assigned teleport destiation
func on_layer_change():
	if teleport_node != null:
		teleport_node.teleport_layer(self)
		$LayerChangeAudio.play()
