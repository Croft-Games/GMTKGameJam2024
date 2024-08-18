class_name GardenTool
extends Spawnable

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sound_timer: Timer = $AudioStreamPlayer2D/Timer
@onready var action_area: Area2D = $ActionArea

var facing_right: bool = false

func _ready() -> void:
	sprite.play(&"idle")
	sprite.animation_finished.connect(_on_animation_end)
	sound_timer.timeout.connect(sound.stop)

func use():
	pass

func set_facing(right: bool):
	if facing_right == right:
		return
	facing_right = right
	for v in get_visuals():
		if v is Sprite2D or v is AnimatedSprite2D:
			v.flip_h = right
	for c in get_colliders():
		print()
		print(right)
		print(c)
		print(c.position.x)
		c.position.x = absf(c.position.x) * (1 if right else -1)
		print(c.position.x)

func get_visuals() -> Array[Node2D]:
	return [$AnimatedSprite2D]

func get_colliders() -> Array[CollisionShape2D]:
	return [$GrabbableArea/CollisionShape2D, $ActionArea/CollisionShape2D]

func _on_animation_end():
	if sprite.animation != "idle":
		sprite.play(&"idle")

func play_sound(from: float):
	sound.pitch_scale = randfn(1, 0.02)
	sound.play(from)
	sound_timer.start()
