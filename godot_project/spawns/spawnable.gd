class_name Spawnable
extends Node2D

@onready var build_sound: AudioStreamPlayer2D = $BuildupSound
@onready var pop_sound: AudioStreamPlayer2D = $PopSound
@onready var spawn_timer: Timer = $SpawnTimer
@onready var parent = get_parent()

@export var pop_sounds: Array[AudioStream] = []

const buildup_time: float = 13.65

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pop_sounds.shuffle()
	pop_sound.stream = pop_sounds[0]
	spawn_timer.timeout.connect(spawn_in)
	start_spawn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_spawn(after: float = 10):
	spawn_timer.wait_time = after
	build_sound.pitch_scale = buildup_time / after
	build_sound.play()
	spawn_timer.start()

signal spawned

func spawn_in():
	pop_sound.play()
	spawned.emit()
