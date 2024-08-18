class_name TaskTimer
extends Node2D

@onready var timer: Timer = $Timer
@onready var moving_line: Sprite2D = $MovingLine
@onready var exclamation_mark: AnimatedSprite2D = $ExclamationMark
@onready var current_progress: TextureProgressBar =$CurrentProgress
@export var color: Color = Color.WHITE


func _ready() -> void:
	current_progress.tint_progress = color

func _process(delta: float) -> void:
	var proportion: float = timer.time_left / timer.wait_time
	moving_line.rotation = -TAU * proportion
	current_progress.value = proportion
	exclamation_mark.visible = (proportion < 0.25)

func start():
	timer.start()
	show()

func stop():
	timer.stop()
	hide()
