extends Sprite2D

@export var texture_options: Array[Texture2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = texture_options.pick_random()
	flip_h = bool(randi() % 2)
	scale = scale * randfn(1, 0.2)
