class_name Pond
extends Spawnable

func _ready() -> void:
	super()
	var sprite: AnimatedSprite2D = $AnimatedSprite2D
	sprite.play(["default", "round"].pick_random())

func get_visuals() -> Array[Node2D]:
	return [$AnimatedSprite2D]

func get_colliders() -> Array:
	return [$RefillArea/CollisionPolygon2D, $CollisionBox/CollisionPolygon2D]
