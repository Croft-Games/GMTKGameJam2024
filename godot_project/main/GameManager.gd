extends Node2D

var elapsed_time: float = 0
var time_since_last_spawn: float = 0
var spawn_rate: float = 0.5
var furthest_spawn: float = 0

@export var possible_spawns: Array[PackedScene] = []

@onready var play_area: PlayArea = $PlayArea
@onready var camera: Camera2D = $Camera2D
const initial_zoom: float = 1
@onready var spawn_timer: Timer = $SpawnTimer
@onready var boundary_finder: RayCast2D = $BoundaryFinder
@onready var first_tree: GardenTree = $Tree

var expansion_rate: float = 0.005
const init_tree_dist: float = 250

var spawned_items: Array = []
const spawn_spacing_sq: float = 80_000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_timer.timeout.connect(spawn_element)
	var first_pos: Vector2 = Vector2.ZERO
	while not valid_spawn(first_pos):
		first_pos = random_vec() * init_tree_dist
	first_tree.position = first_pos
	first_tree.queued_task = GardenTree.Task.PRUNE
	for ch in get_children():
		if ch.has_node("Spawnable"):
			spawned_items.append(ch)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta
	set_zoom_from_elapsed_time()

func random_vec():
	return Vector2.from_angle(randf_range(-PI, PI))

func set_zoom_from_elapsed_time():
	var play_size: float = exp(elapsed_time * expansion_rate)
	camera.zoom = (initial_zoom / play_size) * Vector2.ONE
	play_area.set_size(play_size)

func valid_spawn(pos: Vector2) -> bool:
	if pos == Vector2.ZERO:
		return false
	for item in spawned_items:
		if pos.distance_squared_to(item.position) < spawn_spacing_sq:
			return false
	return true

func spawn_element():
	var new_spawn = possible_spawns.pick_random().instantiate()
	var spawn_position: Vector2 = first_tree.position
	while not valid_spawn(spawn_position):
		boundary_finder.target_position = random_vec() * play_area.right_boundary.position.x * 2
		boundary_finder.force_raycast_update()
		spawn_position = boundary_finder.get_collision_point() * minf(randfn(0.8, 0.1), 1.0)
	new_spawn.position = spawn_position
	add_child(new_spawn)
	spawned_items.append(new_spawn)
