class_name PlayArea
extends Node2D

@onready var top_boundary: StaticBody2D = $Top
@onready var bottom_boundary: StaticBody2D = $Bottom
@onready var left_boundary: StaticBody2D = $Left
@onready var right_boundary: StaticBody2D = $Right

@export var default_width: int = 1600
@export var default_height: int = 900
var current_size: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_top(y: float):
	top_boundary.position.y = -y

func set_bottom(y: float):
	bottom_boundary.position.y = y

func set_left(x: float):
	left_boundary.position.x = -x

func set_right(x: float):
	right_boundary.position.x = x

func set_boundaries(width: float, height: float):
	var y: float = height / 2
	var x: float = width / 2
	set_top(y)
	set_bottom(y)
	set_left(x)
	set_right(x)

func set_boundaries_from_size():
	set_boundaries(default_width * current_size, default_height * current_size)

func set_size(size: float):
	current_size = size
	set_boundaries_from_size()

func increment_size(by: float):
	current_size += by
	set_boundaries_from_size()

func multiply_size(by: float):
	current_size += by
	set_boundaries_from_size()
