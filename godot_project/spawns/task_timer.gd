class_name TaskTimer
extends Node2D

@onready var timer: Timer = $Timer
@onready var progress_bar: Polygon2D = $ProgressBar
@onready var current_progress: Polygon2D = $ProgressBar/CurrentProgress
@export var color: Color = Color.WHITE

var max_size: float = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_progress.color = color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var proportion: float = timer.time_left / timer.wait_time
	current_progress.scale.x = proportion

func show_progress():
	progress_bar.show()

func hide_progress():
	progress_bar.hide()
