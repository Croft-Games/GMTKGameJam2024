class_name Pond
extends Spawnable

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	super()
	sprite.play(["default", "round"].pick_random())

func get_visuals() -> Array[Node2D]:
	return [sprite]

func get_colliders() -> Array:
	return [$RefillArea/CollisionPolygon2D, $CollisionBox/CollisionPolygon2D]
