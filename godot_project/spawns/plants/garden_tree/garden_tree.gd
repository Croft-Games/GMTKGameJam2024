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
var task_assignments: Array[Task] = [Task.IDLE, Task.WATER, Task.PRUNE]
var current_task: Task = Task.UNSET
var queued_task: Task = Task.UNSET
var previous_task: Task = Task.UNSET

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	collision_shape.disabled = true
	water_timer.timer.wait_time = 10
	prune_timer.timer.wait_time = 20
	idle_timer.wait_time = 5
	spawn_manager.spawned.connect(_on_spawn)
	water_timer.timer.timeout.connect(fail_task)
	prune_timer.timer.timeout.connect(fail_task)
	idle_timer.timeout.connect(set_queued_task)

signal failed_task()

func fail_task():
	failed_task.emit()
	var explosion_sound = $Explosion/AudioStreamPlayer2D
	explosion_sound.play()
	stop_timers()
	sprite.hide()
	collision_shape.disabled = true
	var explosion = $Explosion
	var explosion_timer = $Explosion/Timer
	explosion.frame = randi() % 9
	explosion.show()
	explosion_timer.timeout.connect(queue_free)
	explosion_timer.start()


func _on_spawn():
	show()
	collision_shape.disabled = false
	set_queued_task()

func stop_timers():
	water_timer.hide()
	water_timer.timer.stop()
	prune_timer.hide()
	prune_timer.timer.stop()
	idle_timer.stop()


func set_task(task: Task):
	print("set task")
	previous_task = current_task
	current_task = task
	stop_timers()
	if task == Task.WATER:
		set_state_dry()
	elif task == Task.PRUNE:
		set_state_overgrown()
	elif task == Task.IDLE:
		set_state_happy()
		print("setting to idle")
	else:
		print("setting to unset")

func set_random_task():
	var new_task: Task = current_task
	while (new_task == current_task) or (new_task == previous_task):
		new_task = task_assignments.pick_random()
	set_task(new_task)

func set_state_happy():
	if current_state != TreeState.HAPPY:
		current_state = TreeState.HAPPY
		sprite.play(&"happy")
		idle_timer.start()


func set_queued_task():
	print("timer expired. setting queued task")
	if queued_task != Task.UNSET:
		set_task(queued_task)
		queued_task = Task.UNSET
	else:
		set_random_task()


func set_state_dry():
	if current_state != TreeState.DRY:
		current_state = TreeState.DRY
		sprite.play(&"dry")
		water_timer.timer.start()
		water_timer.show()

func set_state_overgrown():
	if current_state != TreeState.OVERGROWN:
		current_state = TreeState.OVERGROWN
		sprite.play(&"overgrown")
		prune_timer.timer.start()
		prune_timer.show()

func water():
	water_timer.timer.stop()
	water_timer.hide()
	if current_state == TreeState.DRY:
		set_task(Task.IDLE)

func prune():
	prune_timer.timer.stop()
	prune_timer.hide()
	if current_state == TreeState.OVERGROWN:
		set_task(Task.IDLE)
