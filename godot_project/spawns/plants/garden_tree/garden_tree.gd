class_name GardenTree
extends Node2D

@onready var water_timer: TaskTimer = $WaterTimer
@onready var prune_timer: TaskTimer = $PruneTimer
@onready var idle_timer: Timer = $IdleTimer
@onready var spawn_manager: Spawnable = $Spawnable
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionBox/CollisionShape2D

enum TreeState{SPAWNING, HAPPY, DRY, OVERGROWN}
var current_state: TreeState = TreeState.SPAWNING

enum Task{UNSET, IDLE, WATER, PRUNE}
var current_task: Task = Task.UNSET
var queued_task: Task = Task.UNSET

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	collision_shape.disabled = true
	water_timer.timer.wait_time = 10
	prune_timer.timer.wait_time = 20
	idle_timer.wait_time = 5
	spawn_manager.spawned.connect(_on_spawn)
	water_timer.timer.timeout.connect(set_state_dry)
	prune_timer.timer.timeout.connect(set_state_overgrown)
	idle_timer.timeout.connect(set_random_task)

func _on_spawn():
	show()
	collision_shape.disabled = false
	set_state_happy()

func set_task(task: Task):
	current_task = task
	water_timer.hide()
	water_timer.timer.stop()
	prune_timer.hide()
	prune_timer.timer.stop()
	if task == Task.WATER:
		water_timer.timer.start()
		water_timer.show()
	elif task == Task.PRUNE:
		prune_timer.timer.start()
		prune_timer.show()
	elif task == Task.IDLE:
		idle_timer.start()

func set_random_task():
	set_task(Task.values()[randi_range(1, Task.size() - 1)])

func set_state_happy():
	if current_state != TreeState.HAPPY:
		current_state = TreeState.HAPPY
		sprite.play(&"happy")
		if current_task == Task.UNSET:
			if queued_task == Task.UNSET:
				set_random_task()
			else:
				set_task(queued_task)
				queued_task = Task.UNSET


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
	water_timer.timer.stop()
	water_timer.hide()
	if current_state == TreeState.DRY:
		current_state = TreeState.HAPPY

func prune():
	prune_timer.timer.stop()
	prune_timer.hide()
	if current_state == TreeState.OVERGROWN:
		current_state = TreeState.HAPPY
