extends Node2D

var elapsed_time: float = 0
var time_since_last_spawn: float = 0
var spawn_rate: float = 0.5
var furthest_spawn: float = 0

@export var possible_spawns: Array = []

@onready var play_area: PlayArea = $PlayArea
@onready var camera: Camera2D = $Camera2D
const initial_zoom: float = 1

var expansion_rate: float = 0.005

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta

	time_since_last_spawn += delta

	set_zoom_from_elapsed_time()


func set_zoom_from_elapsed_time():
	var play_size: float = exp(elapsed_time * expansion_rate)
	camera.zoom = (initial_zoom / play_size) * Vector2.ONE
	play_area.set_size(play_size)

func spawn_element():
	pass
