extends Area2D
class_name TriggerArea

const CLASS = "TriggerArea"

export var all_players : bool = false
export var trigger_cooldown : float = 0 setget set_trigger_cooldown, get_trigger_cooldown

var passed_players : Array = []

var triggered : bool = false setget set_triggered, is_triggered

signal area_triggered

func get_class() -> String:
	return CLASS
func is_class(value : String) -> bool:
	return value == CLASS

func set_trigger_cooldown(value : float):
	trigger_cooldown = value
func  get_trigger_cooldown() -> float:
	return trigger_cooldown

func _ready():
	var _err = connect("body_entered", self, "on_body_entered")

# When the tiggers is set to true, send the signal to the event node 
# (Should be a parent of this node)
func set_triggered(value: bool, trigger_body : PhysicsBody2D = null):
	triggered = value
	$CollisionShape2D.call_deferred("set_disabled", value)
	
	if "rebounce" in owner:
		owner.rebounce = !value
		$RebounceCollisionShape.call_deferred("set_disabled", !value)
	
	if triggered:
		emit_signal("area_triggered", trigger_body) #emit the signal to the parent
		
	if is_triggered():
		var trigger_cd_timer = Timer.new()
		trigger_cd_timer.set_one_shot(true)
		add_child(trigger_cd_timer)
		trigger_cd_timer.start(trigger_cooldown)
		yield(trigger_cd_timer, "timeout")
		set_triggered(false)
		trigger_cd_timer.queue_free()
		if "rebounce" in owner:
			owner.rebounce = false
			$RebounceCollisionShape.call_deferred("set_disabled", false)
		

func is_triggered() -> bool:
	return triggered


# Detect a player entering the area
# If only one player is needed, send the triggered signal
# If all the players are needed, wait until all the player are in the area to send the signal
func on_body_entered(body : PhysicsBody2D):
	if body == null or body == owner:
		return

	if body.is_class("Player"):
			if all_players == false:
				set_triggered(true, body)
			else:
				if !(body in passed_players):
					passed_players.append(body)
				if len(passed_players) >= 2:
					set_triggered(true, body)
	elif "bodies_trigger_array" in owner:
		if body.get_class() in owner.bodies_trigger_array:
			set_triggered(true, body)
		else:
			return
	else:
		return
