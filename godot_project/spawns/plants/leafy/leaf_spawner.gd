class_name LeafSpawner
extends CPUParticles2D

@export var stream: AudioStream
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sound.stream = stream

func emit():
	emitting = true
	sound.play()
	$AudioStreamPlayer2D/Timer.start()
