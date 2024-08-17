extends Sprite2D

@export var texture_options: Array[Texture2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = texture_options.pick_random()
	flip_h = randi() % 2
	scale = randfn(0.065, 0.005) * Vector2.ONE
