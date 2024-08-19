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

var _sum_of_spawn_weights: float = 1

var tasks_completed: int = 0
var max_plants: int = 0
var current_plants: int = 1

func sum(values) -> float:
	var total: float = 0
	for item in values:
		total += item
	return total

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.max_value = max_health
	assert(possible_spawns.size() == spawn_weights.size())
	_sum_of_spawn_weights = sum(spawn_weights)
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
	health_bar.value = move_toward(health_bar.value, health, health_bar_move_speed * delta)

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


func _select_random_spawn():
	var n: float = randf_range(0, _sum_of_spawn_weights)
	var t: float = 0
	for i in possible_spawns.size():
		t += spawn_weights[i]
		if n < t:
			return possible_spawns[i]
	return possible_spawns[0]

func is_spawnable(item):
	return is_instance_valid(item) and item is Spawnable

func generate_spawn_position():
	boundary_finder.target_position = random_vec() * play_area.right_boundary.position.x * 2
	boundary_finder.force_raycast_update()
	return boundary_finder.get_collision_point() * minf(randfn(0.8, 0.1), 1.0)

func spawn_element():
	var new_spawn = _select_random_spawn().instantiate()
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
