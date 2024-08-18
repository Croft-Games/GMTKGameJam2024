class_name GardenTool
extends Spawnable

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var action_timer: Timer = $ActionTimer
@onready var action_area: Area2D = $ActionArea
@export var default_animation: StringName = &"idle"

var facing_right: bool = false

signal tool_failed(action: String)

func _ready() -> void:
	super()
	sprite.play(default_animation)
	sprite.animation_finished.connect(_on_animation_end)
	action_timer.timeout.connect(sound.stop)

func use():
	pass

func facing_mult() -> float:
	return (1 if facing_right else -1)

func set_facing(right: bool):
	if facing_right == right:
		return
	facing_right = right
	for v in get_visuals():
		if v is Sprite2D or v is AnimatedSprite2D:
			v.flip_h = right
	for c in get_colliders():
		c.position.x = absf(c.position.x) * facing_mult()

func get_visuals() -> Array[Node2D]:
	return [$AnimatedSprite2D]

func get_colliders() -> Array:
	return [$GrabbableArea/CollisionShape2D, $ActionArea/CollisionShape2D]

func _on_animation_end():
	if sprite.animation != default_animation:
		sprite.play(default_animation)

func play_sound(from: float):
	sound.pitch_scale = randfn(1, 0.02)
	sound.play(from)
	action_timer.start()
