class_name GardenTool
extends Spawnable

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var action_timer: Timer = $ActionTimer
@onready var action_area: Area2D = $ActionArea
@export var default_animation: StringName = &"idle"
@export var drop_cooldown: float = 0.3

@onready var grabbable_area_shape: CollisionShape2D = $GrabbableArea/CollisionShape2D

var drop_cooldown_timer: Timer
var facing_right: bool = false

signal tool_failed(action: String)

func _ready() -> void:
	super()
	sprite.play(default_animation)
	sprite.animation_finished.connect(_on_animation_end)
	action_timer.timeout.connect(sound.stop)

func use() -> bool:
	return false

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

func grab():
	pass

func drop():
	grabbable_area_shape.disabled = true
	await get_tree().create_timer(drop_cooldown).timeout
	grabbable_area_shape.disabled = false
