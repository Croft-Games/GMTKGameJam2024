extends Node2D

var elapsed_time: float = 0

@export var possible_spawns: Array[PackedScene] = []
@export var spawn_weights: Array[float] = []

@onready var background: ColorRect = $Background
@onready var play_area: PlayArea = $PlayArea
@onready var camera: Camera2D = $Camera2D
const initial_zoom: float = 1
@onready var spawn_timer: Timer = $SpawnTimer
@onready var boundary_finder: RayCast2D = $BoundaryFinder
@onready var first_plant: GardenPlant = $First
@onready var health_bar: ProgressBar = $HUDCanvas/HUD/MarginContainer/HealthBar
const max_health: float = 100
var passive_health_regen: float = 0.05
var active_health_regen: float = 2

var health: float = max_health
var fail_damage: float = 10
var health_bar_move_speed: float = 10

var expansion_rate: float = 0.005
const init_tree_dist: float = 250
var game_active: bool = true

var tasks_completed: int = 0
var max_plants: int = 0
var current_plants: int = 1

var unlocked_tasks: Array = [GardenPlant.Task.PRUNE]

var object_counts: Dictionary = {}
@export var spawn_dropoff: float = 1

@export var unlock_reqs: Dictionary = {
	GardenPlant.Task.WATER: [2, 4],
	GardenPlant.Task.COLLECT: [1, 5, 6],
}
var unlock_progress: Dictionary = {
	GardenPlant.Task.WATER: 0,
	GardenPlant.Task.COLLECT: 0,
}
var unlock_started: Dictionary = {
	GardenPlant.Task.WATER: false,
	GardenPlant.Task.COLLECT: false,
}
var unlock_delays: Dictionary = {
	GardenPlant.Task.WATER: 27,
	GardenPlant.Task.COLLECT: 62,
}


func sum(values) -> float:
	var total: float = 0
	for item in values:
		total += item
	return total

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.max_value = max_health
	assert(possible_spawns.size() == spawn_weights.size())
	spawn_timer.timeout.connect(spawn_element)
	first_plant.position = Vector2.ZERO
	while not first_plant.spawn_manager.is_valid_spawn_location():
		first_plant.position = random_vec() * init_tree_dist
	first_plant.queued_task = GardenPlant.Task.PRUNE
	first_plant.spawn_manager.start_spawn()
	first_plant.failed_task.connect(task_failed)
	first_plant.completed_task.connect(task_completed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_active:
		elapsed_time += delta
		if health <= 0:
			game_over()
		health = clampf(health + passive_health_regen * delta, 0, max_health)
		set_zoom_from_elapsed_time()

		try_unlock(GardenPlant.Task.WATER)
		try_unlock(GardenPlant.Task.COLLECT)
	health_bar.value = move_toward(health_bar.value, health, health_bar_move_speed * delta)

func try_unlock(task):
	if (not unlock_started[task]) and (elapsed_time > unlock_delays[task]):
		start_unlock(task)

func start_unlock(task):
	unlock_started[task] = true
	var reqs = unlock_reqs[task]
	for i in reqs:
		var new_spawn: Spawnable = spawn_element(possible_spawns[i])
		new_spawn.spawn_manager.spawned.connect(unlock_task_for_plants.bind(task))

func unlock_task_for_plants(task):
	unlock_progress[task] = unlock_progress[task] + 1
	if (task not in unlocked_tasks) and unlock_progress[task] >= unlock_reqs[task].size():
		unlocked_tasks.append(task)
		for ch in get_children():
			if ch is GardenPlant:
				ch.unlock_task(task)
		for ch in get_children():
			if ch is GardenPlant:
				if task in ch.task_assignments:
					ch.queued_task = task
					break

func restart():
	get_tree().reload_current_scene()

func back_to_menu():
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

func task_completed():
	health += active_health_regen
	tasks_completed += 1

func task_failed():
	health -= fail_damage
	current_plants -= 1

func game_over():
	spawn_timer.stop()
	game_active = false
	health_bar.hide()
	for ch in get_children():
		if ch is GardenPlant:
			ch.stop_timers()
	$HUDCanvas/HUD/GameOverPanel.show()
	$HUDCanvas/HUD/GameOverPanel/VBoxContainer/HBoxContainer/MaxPlants/StatValue.text = str(max_plants)
	$HUDCanvas/HUD/GameOverPanel/VBoxContainer/HBoxContainer/TasksCompleted/StatValue.text = str(tasks_completed)
	$HUDCanvas/HUD/GameOverPanel/VBoxContainer/HBoxContainer/TotalTime/StatValue.text = str(elapsed_time).pad_decimals(1)

func random_vec():
	return Vector2.from_angle(randf_range(-PI, PI))

func set_zoom_from_elapsed_time():
	var play_size: float = exp(elapsed_time * expansion_rate)
	camera.zoom = (initial_zoom / play_size) * Vector2.ONE
	play_area.set_size(play_size)
	background.scale = Vector2(1 / camera.zoom.x, 1 / camera.zoom.y)

func is_unlocked(i):
	if i < 0:
		return false
	if (not GardenPlant.Task.WATER in unlocked_tasks) and (i in unlock_reqs[GardenPlant.Task.WATER]):
		return false
	if (not GardenPlant.Task.COLLECT in unlocked_tasks) and (i in unlock_reqs[GardenPlant.Task.COLLECT]):
		return false
	return true


func _select_random_spawn():
	var modified_spawn_weights: Array[float] = []
	for i in possible_spawns.size():
		var packed_scene = possible_spawns[i]
		var obj_count = object_counts.get(packed_scene, 0)
		modified_spawn_weights.append(spawn_weights[i] * exp(-obj_count * spawn_dropoff))
	var sum_of_spawn_weights: float = sum(modified_spawn_weights)
	var n: float = randf_range(0, sum_of_spawn_weights)
	var t: float = 0
	var e: int = -1
	while not is_unlocked(e):
		for i in possible_spawns.size():
			t += modified_spawn_weights[i]
			if n < t:
				e = i
				break
	return possible_spawns[e]

func is_spawnable(item):
	return is_instance_valid(item) and item is Spawnable

func generate_spawn_position():
	boundary_finder.target_position = random_vec() * play_area.right_boundary.position.x * 2
	boundary_finder.force_raycast_update()
	return boundary_finder.get_collision_point() * minf(randfn(0.8, 0.1), 1.0)

func spawn_element(packed_scene = null) -> Spawnable:
	if packed_scene == null:
		packed_scene = _select_random_spawn()
	var new_spawn = packed_scene.instantiate()
	if new_spawn is Spawnable:
		add_child(new_spawn)
		new_spawn.position = Vector2.ZERO
		while not new_spawn.spawn_manager.is_valid_spawn_location():
			new_spawn.position = generate_spawn_position()
		new_spawn.spawn_manager.start_spawn()
		if new_spawn is GardenPlant:
			new_spawn.failed_task.connect(task_failed)
			new_spawn.completed_task.connect(task_completed)
			current_plants += 1
			max_plants = max(current_plants, max_plants)
			for task in unlocked_tasks:
				new_spawn.unlock_task(task)
		object_counts[packed_scene] = object_counts.get(packed_scene, 0) + 1
	return new_spawn
