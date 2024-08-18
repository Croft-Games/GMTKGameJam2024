class_name SpawnManager
extends Node2D

@onready var build_sound: AudioStreamPlayer2D = $BuildupSound
@onready var pop_sound: AudioStreamPlayer2D = $PopSound
@onready var spawn_timer: Timer = $SpawnTimer
@onready var light: PointLight2D = $PointLight2D

@export var pop_sounds: Array[AudioStream] = []

const buildup_time: float = 13.65

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pop_sound.stream = pop_sounds.pick_random()
	spawn_timer.timeout.connect(spawn_in)
	light.hide()

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
	var pulse_tween = light.create_tween()
	pulse_tween.set_ease(Tween.EASE_IN_OUT)
	pulse_tween.set_trans(Tween.TRANS_SINE)
	var num_loops = 5
	pulse_tween.set_loops()
	pulse_tween.set_speed_scale(speed_scale)
	pulse_tween.tween_property(light, "texture_scale", 2, buildup_time / num_loops)
	pulse_tween.tween_property(light, "texture_scale", 1, buildup_time / num_loops)

func spawn_in():
	pop_sound.play()
	light.hide()
	spawned.emit()
