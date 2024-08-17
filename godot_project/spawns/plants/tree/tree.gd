class_name GameTree
extends Node2D

@onready var water_timer: TaskTimer = $WaterTimer
@onready var prune_timer: TaskTimer = $PruneTimer
@onready var spawn_manager: Spawnable = $Spawnable
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionBox/CollisionShape2D

enum TreeState{SPAWNING, HAPPY, DRY, OVERGROWN}
var current_state: TreeState = TreeState.SPAWNING


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	collision_shape.disabled = true
	water_timer.timer.wait_time = 10
	prune_timer.timer.wait_time = 20
	spawn_manager.spawned.connect(_on_spawn)
	water_timer.timer.timeout.connect(set_state_dry)
	prune_timer.timer.timeout.connect(set_state_overgrown)

func _on_spawn():
	show()
	collision_shape.disabled = false
	set_state_happy()

func set_state_happy():
	if current_state != TreeState.HAPPY:
		current_state = TreeState.HAPPY
		sprite.play(&"happy")
		water_timer.timer.start()
		prune_timer.timer.start()

func set_state_dry():
	if current_state != TreeState.DRY:
		current_state = TreeState.DRY
		sprite.play(&"dry")

func set_state_overgrown():
	if current_state != TreeState.OVERGROWN:
		current_state = TreeState.OVERGROWN
		sprite.play(&"overgrown")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func water():
	if current_state == TreeState.DRY:
		current_state = TreeState.HAPPY

func prune():
	if current_state == TreeState.OVERGROWN:
		current_state = TreeState.HAPPY
