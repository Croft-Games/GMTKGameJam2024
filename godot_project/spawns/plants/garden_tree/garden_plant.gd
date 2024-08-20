class_name GardenPlant
extends Spawnable

var water_timer: TaskTimer
var prune_timer: TaskTimer
var fruit_timer: TaskTimer
@onready var idle_timer: Timer = $IdleTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var leaf_spawner: LeafSpawner
var dry_spawner: LeafSpawner
var apple_spawner: LeafSpawner

enum TreeState{SPAWNING, HAPPY, DRY, OVERGROWN, FRUIT, DEAD}
var current_state: TreeState = TreeState.SPAWNING

enum Task{UNSET, IDLE, WATER, PRUNE, COLLECT}
@export var task_assignments: Array[Task] = [Task.IDLE, Task.PRUNE]
var current_task: Task = Task.UNSET
@export var queued_task: Task = Task.UNSET
var previous_task: Task = Task.UNSET
var unlocked_tasks: Array[Task] = [Task.IDLE, Task.PRUNE]
var non_tasks: Array[Task] = [Task.UNSET, Task.IDLE]

@export var task_timers: Dictionary = {
	Task.IDLE: [15, 3],
	Task.PRUNE: [15, 3],
	Task.WATER: [26, 3],
	Task.COLLECT: [22, 5],
}

var base_timer_scale: Vector2 = Vector2.ONE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	do_spawn_animation = false  # use custom logic instead
	if Task.PRUNE in task_assignments:
		leaf_spawner = $LeafSpawner
		prune_timer = $PruneTimer
		prune_timer.timer.wait_time = 10
		prune_timer.timer.timeout.connect(fail_task)
		base_timer_scale = prune_timer.scale
	if Task.WATER in task_assignments:
		dry_spawner = $DryEffectSpawner
		water_timer = $WaterTimer
		water_timer.timer.wait_time = 25
		water_timer.timer.timeout.connect(fail_task)
	if Task.COLLECT in task_assignments:
		apple_spawner = $AppleSpawner
		fruit_timer = $FruitTimer
		fruit_timer.timer.wait_time = 20
		fruit_timer.timer.timeout.connect(fail_task)
	idle_timer.wait_time = 10
	idle_timer.timeout.connect(set_queued_task)

signal completed_task()
signal failed_task(plant: GardenPlant)

func set_timer_scale(scale: float):
	for t in [prune_timer, water_timer, fruit_timer]:
		if t != null:
			t.scale = base_timer_scale * scale

func unlock_task(task: Task):
	if task not in unlocked_tasks:
		unlocked_tasks.append(task)

func fail_task():
	failed_task.emit(self)
	stop_timers()
	var explosion_sound: AudioStreamPlayer2D = $Explosion/AudioStreamPlayer2D
	explosion_sound.play()
	var explosion: AnimatedSprite2D = $Explosion
	var explosion_timer = $Explosion/Timer
	explosion.show()
	explosion.play()
	set_state_dead()
	explosion_timer.timeout.connect(explosion_sound.stop)
	explosion.animation_finished.connect(explosion.hide)
	explosion_timer.start()

func complete_task():
	completed_task.emit()

# The below functions tell the spawn manager what to enable/disable

func get_visuals() -> Array[Node2D]:
	return [$AnimatedSprite2D]

func get_colliders() -> Array:
	return [$InteractionBox/CollisionShape2D, $CollisionBox/CollisionShape2D]

func _on_spawn():
	super()
	set_queued_task()
	if current_task in non_tasks and queued_task in non_tasks:
		leaf_spawner.emit()

func stop_timers():
	# todo reduce task code duplication
	if water_timer != null:
		water_timer.hide()
		water_timer.timer.stop()
	if prune_timer != null:
		prune_timer.hide()
		prune_timer.timer.stop()
	if fruit_timer != null:
		fruit_timer.hide()
		fruit_timer.timer.stop()
	idle_timer.stop()


func set_task(task: Task):
	previous_task = current_task
	current_task = task
	stop_timers()
	if task == Task.WATER:
		set_state_dry()
	elif task == Task.PRUNE:
		set_state_overgrown()
	elif task == Task.COLLECT:
		set_state_fruit()
	elif task == Task.IDLE:
		set_state_happy()

func set_random_task():
	var new_task: Task = current_task
	while (new_task == current_task) or (new_task not in unlocked_tasks):
		new_task = task_assignments.pick_random()
	set_task(new_task)

func set_state_happy():
	if current_state != TreeState.HAPPY:
		current_state = TreeState.HAPPY
		sprite.play(&"happy")
		idle_timer.wait_time = get_wait_time(Task.IDLE)
		idle_timer.start()


func set_queued_task():
	if queued_task != Task.UNSET:
		set_task(queued_task)
		queued_task = Task.UNSET
	else:
		set_random_task()

func get_wait_time(task: Task) -> float:
	var timer_params: Array = task_timers[task]
	return randfn(timer_params[0], timer_params[1])

func set_state_dry():
	if current_state != TreeState.DRY:
		current_state = TreeState.DRY
		sprite.play(&"dry")
		water_timer.timer.wait_time = get_wait_time(Task.WATER)
		water_timer.timer.start()
		water_timer.show()
		dry_spawner.emit()

func set_state_overgrown():
	if current_state != TreeState.OVERGROWN:
		current_state = TreeState.OVERGROWN
		sprite.play(&"overgrown")
		prune_timer.timer.wait_time = get_wait_time(Task.PRUNE)
		prune_timer.timer.start()
		prune_timer.show()
		leaf_spawner.emit()

func set_state_fruit():
	if current_state != TreeState.FRUIT:
		current_state = TreeState.FRUIT
		sprite.play(&"fruit")
		fruit_timer.timer.wait_time = get_wait_time(Task.COLLECT)
		fruit_timer.timer.start()
		fruit_timer.show()
		apple_spawner.emit()

func set_state_dead():
	if current_state != TreeState.DEAD:
		current_state = TreeState.DEAD
		sprite.play(&"dead")
		stop_timers()

func water():
	if water_timer != null:
		water_timer.timer.stop()
		water_timer.hide()
	if current_state == TreeState.DRY:
		set_task(Task.IDLE)
		complete_task()

func prune():
	if prune_timer != null:
		prune_timer.timer.stop()
		prune_timer.hide()
	if current_state == TreeState.OVERGROWN:
		set_task(Task.IDLE)
		complete_task()

func collect() -> bool:
	if fruit_timer != null:
		fruit_timer.timer.stop()
		fruit_timer.hide()
	if current_state == TreeState.FRUIT:
		set_task(Task.IDLE)
		complete_task()
		return true
	return false
