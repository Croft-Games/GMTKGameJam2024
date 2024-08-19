class_name FruitDepot
extends Spawnable

func get_visuals() -> Array[Node2D]:
	return [$AnimatedSprite2D]

func get_colliders() -> Array:
	return [$DepositArea/CollisionShape2D, $CollisionBox/CollisionShape2D]
