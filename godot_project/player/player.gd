class_name Player
extends CharacterBody2D

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var light: PointLight2D = $PlayerSprite/PointLight2D
@onready var trail: CPUParticles2D = $PlayerSprite/CPUParticles2D
@onready var dust_cloud: AnimatedSprite2D = $PlayerSprite/DustCloud
@onready var move_sound: AudioStreamPlayer2D = $MovementSound
@onready var equip_sound: AudioStreamPlayer2D = $EquipSound
@onready var drop_sound: AudioStreamPlayer2D = $DropSound
@onready var upgrade_sound: AudioStreamPlayer2D = $UpgradeSound
@onready var interaction_box: Area2D = $InteractionBox
@onready var interaction_shape: CollisionShape2D = $InteractionBox/CollisionShape2D

@export var base_speed: float = 400

enum PlayerState{IDLE, MOVING}
var current_state: PlayerState = PlayerState.IDLE

const idle_light_colour: Color = Color("#ffdf3c")
const idle_light_position: Vector2 = Vector2(-80, -220)
const move_light_colour: Color = Color("#cf4833")
const move_light_position: Vector2 = Vector2(-100, -215)

var equipped_tool: GardenTool = null
var tool_slowdown: float = 0.5

var batteries_collected: int = 0
var speed_multiplier: float = 1
@export var base_acceleration: float = 1200
@export var base_friction: float = 3000
@export var base_deceleration: float = 4000
var target_velocity: Vector2 = Vector2.ZERO

var facing_right: bool = false

var active_tool_offset: Vector2 = Vector2(-50, -1)
@onready var interaction_box_offset = interaction_shape.position

const base_sprite_scale: float = 0.065

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_sprite.scale = base_sprite_scale * Vector2.ONE
	dust_cloud.animation_finished.connect(switch_dust_to_loop)
	set_state_idle(true)

func flip_direction():
	set_facing(not facing_right)

func vector_from_facing(vector: Vector2) -> Vector2:
	var x_mul: float = -1 if facing_right else 1
	return Vector2(vector.x * x_mul, vector.y)

func set_facing(right: bool):
	facing_right = right
	player_sprite.scale = vector_from_facing(base_sprite_scale * Vector2.ONE)
	interaction_shape.position = vector_from_facing(interaction_box_offset)

func compute_speed() -> float:
	var tool_multiplier: float = exp(-tool_slowdown * int(equipped_tool != null))
	var battery_multiplier: float = float(2 + batteries_collected) / 2
	speed_multiplier = tool_multiplier * battery_multiplier
	return speed_multiplier * base_speed

func get_move_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var move_input: Vector2 = get_move_input()
	if move_input.x != 0:
		set_facing(move_input.x > 0)

	if velocity.is_zero_approx():
		set_state_idle()
	else:
		set_state_moving()

	_move_tool()
	for col in interaction_box.get_overlapping_areas():
		var p = col.get_parent()
		if p is Battery:
			get_battery(p)

func _physics_process(delta: float) -> void:
	var move_input: Vector2 = get_move_input()
	target_velocity = move_input * compute_speed()
	var dotted: float = velocity.normalized().dot(target_velocity.normalized())
	var accel: float = base_acceleration
	if velocity.is_zero_approx():
		accel = base_acceleration
	elif target_velocity.is_zero_approx() or is_zero_approx(dotted):
		accel = base_friction * get_current_speed_as_mult()
	elif dotted < 0:
		accel = base_deceleration
	accel = accel * (4 + batteries_collected) / 4
	velocity = velocity.move_toward(target_velocity, accel * delta)
	trail.emitting = (velocity.length() > 800 and dotted < 0.5)
	move_and_slide()

func get_current_speed_as_mult() -> float:
	return maxf(1, velocity.length() / base_speed)

signal battery_collected

func get_battery(battery: Battery):
	if battery.is_active:
		battery.consume()
		batteries_collected += 1
		trail.amount += 5
		upgrade_sound.play()
		battery_collected.emit()


func set_state_moving(force: bool = false):
	if force or current_state != PlayerState.MOVING:
		current_state = PlayerState.MOVING
		var speed_mult: float = get_current_speed_as_mult()
		player_sprite.play(&"move", speed_mult)
		move_sound.pitch_scale = speed_mult
		light.color = move_light_colour
		light.position = move_light_position
		dust_cloud.show()
		dust_cloud.play("start")
		move_sound.play()

func switch_dust_to_loop():
	dust_cloud.play("loop")

func set_state_idle(force: bool = false):
	if force or current_state != PlayerState.IDLE:
		current_state = PlayerState.IDLE
		player_sprite.play(&"idle")
		light.color = idle_light_colour
		light.position = idle_light_position
		trail.emitting = false
		move_sound.stop()
		dust_cloud.hide()

func _move_tool():
	if equipped_tool != null:
		equipped_tool.position = position + vector_from_facing(active_tool_offset)
		equipped_tool.set_facing(facing_right)

signal used_tool(actually_used: bool)
signal grabbed_tool(actually_grabbed: bool)

func equip(tool: GardenTool):
	connect_tool(tool)
	equipped_tool = tool
	equip_sound.play()
	grabbed_tool.emit(true)

func connect_tool(tool: GardenTool):
	tool.tool_failed.connect(_on_tool_failed)

func disconnect_tool(tool: GardenTool):
	tool.tool_failed.disconnect(_on_tool_failed)

func grab_tool():
	for area in interaction_box.get_overlapping_areas():
		var t = area.get_parent()
		if t is GardenTool and t != equipped_tool:
			equip(t)
			return
	grabbed_tool.emit(false)

func use_tool():
	if equipped_tool != null:
		used_tool.emit(equipped_tool.use())

func drop_tool():
	if equipped_tool != null:
		disconnect_tool(equipped_tool)
		drop_sound.play()
		equipped_tool.drop()
		equipped_tool = null

func _on_tool_failed(action: String):
	$SadSound.play()
	$ExclamationMark.show()
	$ExclamationMark/Timer.start()
	if action == "water":
		$NoWater.show()
		$NoWater/Timer.start()
	elif action == "fruit":
		$FullBasket.show()
		$FullBasket/Timer.start()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("grab_tool"):
		if equipped_tool == null:
			grab_tool()
		else:
			drop_tool()
	if event.is_action_pressed("use_tool"):
		use_tool()
