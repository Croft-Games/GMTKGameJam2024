class_name Pond
extends Node2D

func get_visuals() -> Array[Node2D]:
	return [$AnimatedSprite2D]

func get_colliders() -> Array[CollisionShape2D]:
	return [$RefillArea/CollisionPolygon2D, $CollisionBox/CollisionPolygon2D]
