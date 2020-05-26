extends Node

onready var normal_explosion = preload("res://Global/Autoloads/SFX/NormalExplosion/NormalExplosion.tscn")
onready var small_explosion = preload("res://Global/Autoloads/SFX/SmallExplosion/SmallExplosion.tscn")
onready var xion_explosion = preload("res://Global/Autoloads/SFX/XionExplosion/XionExplosion.tscn")

onready var normal_hit = preload("res://Global/Autoloads/SFX/Feedbacks/NormalHit/NormalHit.tscn")
onready var great_hit = preload("res://Global/Autoloads/SFX/Feedbacks/GreatHit/GreatHit.tscn")

onready var debris = preload("res://Global/Autoloads/SFX/Debris/Debris.tscn")


func play_SFX(fx: PackedScene, pos: Vector2):
	var fx_node = fx.instance()
	fx_node.set_global_position(pos)
	add_child(fx_node)
	fx_node.play_animation()



func scatter_sprite(body : Node, nb_debris : int, impulse_force: float = 100.0):
	var texture = body.get_node("Sprite").get_texture()
	
	var sprite_width : float = texture.get_width()
	var sprite_height : float = texture.get_height()
	
	var body_global_pos : Vector2 = body.get_global_position()
	var body_origin : Vector2 = body_global_pos
	body_origin.x = body_origin.x - (sprite_width / 2)
	body_origin.y = body_origin.y - (sprite_height / 2)
	
	var square_size = int(sqrt((sprite_width * sprite_height)/nb_debris))
	
	var row_len = int(sprite_width / square_size)
	var col_len = int(sprite_height / square_size)
	
	for i in range(row_len):
		for j in range(col_len):
			var debris_node = debris.instance()
			var debris_sprite = debris_node.get_node("Sprite")
			var collision_shape = RectangleShape2D.new()
			collision_shape.set_extents(Vector2(square_size / 2, square_size / 2))
			
			debris_node.get_node("CollisionShape2D").set_shape(collision_shape)
			
			var global_pos = Vector2(body_origin.x + i * square_size, body_origin.y + j * square_size)
			debris_node.set_global_position(global_pos)
			
			debris_sprite.set_texture(texture)
			debris_sprite.set_region(true)
			debris_sprite.set_region_rect(Rect2(i * square_size, j * square_size,
													 square_size, square_size))
			
			var epicenter_dir = global_pos.direction_to(body_global_pos)
			debris_node.apply_central_impulse(-(epicenter_dir * impulse_force * rand_range(0.7, 1.3)))
			
			call_deferred("add_child", debris_node)
