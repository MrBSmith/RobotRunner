extends Area2D
class_name TriggerArea

const CLASS = "TriggerArea"

export var triggering_bodies : PoolStringArray = ["Player"]
export var all_players : bool = false
export var trigger_cooldown : float = 0 setget set_trigger_cooldown, get_trigger_cooldown


var passed_players : Array = []
var body_triggerring_area : PhysicsBody2D = null

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
func set_triggered(value: bool, triggering_body : PhysicsBody2D = null):
	triggered = value
	$CollisionShape2D.call_deferred("set_disabled", value)
		
	if is_triggered():
		body_triggerring_area = triggering_body
		emit_signal("area_triggered") #emit the signal to the parent
		
		if trigger_cooldown > 0:
			var trigger_cd_timer = Timer.new() #create timer
			trigger_cd_timer.set_one_shot(true) #set one shot
			add_child(trigger_cd_timer) #add timer to scene
			trigger_cd_timer.start(trigger_cooldown) #start the timer
			yield(trigger_cd_timer, "timeout") #wait for timeout
			set_triggered(false) #recursive function to set triggered to false
			trigger_cd_timer.queue_free() #remove timer
		

func is_triggered() -> bool:
	return triggered


func is_body_triggering_type(body) -> bool:
	for type in triggering_bodies:
		if body.is_class(type):
			return true
	return false

# Detect a player entering the area
# If only one player is needed, send the triggered signal
# If all the players are needed, wait until all the player are in the area to send the signal
func on_body_entered(body : PhysicsBody2D):
	if body == null or body == owner:
		return
		
	if is_body_triggering_type(body):
		if all_players == false:
			set_triggered(true, body)
		else:
			if body.is_class("Player"):
				if !(body in passed_players):
					passed_players.append(body)
				if len(passed_players) >= 2:
					set_triggered(true, body)
