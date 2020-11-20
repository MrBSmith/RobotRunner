extends ParallaxBackground

onready var viewport = get_tree().get_root() 

#### ACCESSORS ####

func is_class(value: String):
	return value == "" or .is_class(value)

func get_class() -> String:
	return ""

#### BUILT-IN ####

#func _physics_process(_delta):
#	_update_size()

#### LOGIC ####

func _update_size():
	for canvas_idx in get_child_count():
	
		var canvas_layer = self
		if not canvas_layer is CanvasLayer:
			continue
	
		for idx in canvas_layer.get_child_count():
	
			var layer_node = canvas_layer.get_child(idx)
			if not layer_node is ParallaxLayer:
				continue
	
			var sprite = layer_node.get_child(0)
	
			var tex_size = sprite.texture.get_size()
			var vp_size = viewport.size
			var vp_scale = viewport.canvas_transform.get_scale()
	
			var q = vp_size / tex_size
			q = q / vp_scale
			q = q.ceil()
			
			var x = q.x * tex_size.x
			var y = q.y * tex_size.y
	
			var new_size = Vector2(x, y)
			new_size *= 2 # just to be sure it covers all
	
			# Update mirroring
			var mirroring = layer_node.motion_mirroring
	
			if mirroring.x > 0.0:
				mirroring.x = new_size.x
	
			if mirroring.y > 0.0:
				mirroring.y = new_size.y

			layer_node.motion_mirroring = mirroring

			# Update sprite size
			var canvas_size
			if sprite is TextureRect:
				canvas_size = sprite.rect_size
			elif sprite is Sprite:
				canvas_size = sprite.region_rect.size

			if mirroring.x > 0.0:
				canvas_size.x = new_size.x

			if mirroring.y > 0.0:
				canvas_size.y = new_size.y

			if sprite is TextureRect:
				sprite.rect_size = canvas_size
			elif sprite is Sprite:
				sprite.region_rect.size = canvas_size

#### VIRTUALS ####



#### INPUTS ####



#### SIGNAL RESPONSES ####
