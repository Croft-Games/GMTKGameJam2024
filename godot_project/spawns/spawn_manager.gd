class_name SpawnManager
extends Node2D

@onready var build_sound: AudioStreamPlayer2D = $BuildupSound
@onready var pop_sound: AudioStreamPlayer2D = $PopSound
@onready var spawn_timer: Timer = $SpawnTimer
@onready var light: PointLight2D = $PointLight2D
@onready var spawn_shape_cast: ShapeCast2D = $SpawnBlockBubble/ShapeCast2D
@onready var spawn_block_bubble: CollisionShape2D = $SpawnBlockBubble/CollisionShape2D

@export var pop_sounds: Array[AudioStream] = []
@export var spawn_bubble_size: float = 100

const buildup_time: float = 13.65

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pop_sound.stream = pop_sounds.pick_random()
	spawn_timer.timeout.connect(spawn_in)
	light.hide()
	spawn_block_bubble.shape = CircleShape2D.new()
	spawn_block_bubble.shape.radius = spawn_bubble_size

signal spawn_started
signal spawned

func start_spawn(after: float = -1):
	if after <= 0:
		after = randfn(6, 2)
	light.show()
	spawn_started.emit()
	spawn_timer.wait_time = after
	var speed_scale = buildup_time / after
	build_sound.pitch_scale = speed_scale
	build_sound.play()
	spawn_timer.start()

	light.texture_scale = 0.01
	var pulse_tween = light.create_tween()
	pulse_tween.set_ease(Tween.EASE_IN)
	pulse_tween.set_trans(Tween.TRANS_BOUNCE)
	pulse_tween.tween_property(light, "texture_scale", 4, buildup_time)

func spawn_in():
	pop_sound.play()
	light.hide()
	spawned.emit()

func is_valid_spawn_location():
	spawn_shape_cast.force_shapecast_update()
	return not spawn_shape_cast.is_colliding()
