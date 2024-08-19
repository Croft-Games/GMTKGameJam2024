class_name Spawnable
extends Node2D

@onready var spawn_manager: SpawnManager = $SpawnManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_manager.spawn_started.connect(_on_start_spawn)
	spawn_manager.spawned.connect(_on_spawn)

func custom_hide():
	for v in get_visuals():
		v.hide()
	for c in get_colliders():
		c.disabled = true

func custom_show():
	for v in get_visuals():
		v.show()
	for c in get_colliders():
		c.disabled = false

func _on_start_spawn():
	custom_hide()

func _on_spawn():
	custom_show()

func get_visuals() -> Array[Node2D]:
	return []

func get_colliders() -> Array:
	return []

func highlight():
	if has_node("AnimatedSprite2D/Highlighter"):
		$AnimatedSprite2D/Highlighter.highlight()
