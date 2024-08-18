class_name Pond
extends Spawnable

func get_visuals() -> Array[Node2D]:
	return [$AnimatedSprite2D]

func get_colliders() -> Array:
	return [$RefillArea/CollisionPolygon2D, $CollisionBox/CollisionPolygon2D]
