class_name TaskTimer
extends Node2D

@onready var timer: Timer = $Timer
@onready var moving_line: Sprite2D = $MovingLine
@onready var exclamation_mark: AnimatedSprite2D = $ExclamationMark
@onready var current_progress: TextureProgressBar =$CurrentProgress
@export var color: Color = Color.WHITE
var time_curvature: float = 2

func _ready() -> void:
	current_progress.tint_progress = color

func _process(delta: float) -> void:
	var proportion: float = timer.time_left / timer.wait_time
	var visual_proportion: float = ((1 + exp(-time_curvature)) - exp(-time_curvature * proportion)) * proportion
	moving_line.rotation = -TAU * visual_proportion
	current_progress.value = visual_proportion
	exclamation_mark.visible = (visual_proportion < 0.25)

func start():
	timer.start()
	show()

func stop():
	timer.stop()
	hide()
