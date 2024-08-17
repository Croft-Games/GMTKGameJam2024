extends CharacterBody2D

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var light: PointLight2D = $PlayerSprite/PointLight2D
@onready var trail: CPUParticles2D = $PlayerSprite/CPUParticles2D
@onready var move_sound: AudioStreamPlayer2D = $MovementSound

@export var base_speed: float = 200

var speed_multiplier: float = 1
enum PlayerState{IDLE, MOVING}
var current_state: PlayerState = PlayerState.IDLE

const idle_light_colour: Color = Color("#ffdf3c")
const idle_light_position: Vector2 = Vector2(-80, -220)
const move_light_colour: Color = Color("#cf4833")
const move_light_position: Vector2 = Vector2(-100, -215)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var move_input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_input * base_speed * speed_multiplier
	if velocity.x != 0:
		var scale_mult: int = -1 if velocity.x > 0 else 1
		player_sprite.scale.x = absf(player_sprite.scale.x) * scale_mult

	if velocity.is_zero_approx():
		set_state_idle()
	else:
		set_state_moving()

func set_state_moving():
	if current_state != PlayerState.MOVING:
		current_state = PlayerState.MOVING
		player_sprite.play(&"move", speed_multiplier)
		light.color = move_light_colour
		light.position = move_light_position
		trail.emitting = true
		move_sound.play()

func set_state_idle():
	if current_state != PlayerState.IDLE:
		current_state = PlayerState.IDLE
		player_sprite.play(&"idle")
		light.color = idle_light_colour
		light.position = idle_light_position
		trail.emitting = false
		move_sound.stop()


func _physics_process(delta: float) -> void:
	move_and_slide()
