extends SFX_AnimationBase
class_name SFX_Explosion

export var shake_magnitude : float = 4.0
export var shake_duration : float = 0.3

func play_animation():
	var current_scene = get_tree().get_current_scene()
	if(!current_scene is Level):
		return
	var camera_node = current_scene.find_node("Camera")
	if camera_node != null:
		camera_node.shake(shake_magnitude, shake_duration)
	set_visible(true)
	play()
	$AudioStreamPlayer2D.play()
