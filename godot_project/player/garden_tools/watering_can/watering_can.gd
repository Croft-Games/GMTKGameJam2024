extends GardenTool

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sound_timer: Timer = $AudioStreamPlayer2D/Timer
@onready var watering_area: Area2D = $WateringArea

const max_water_level: int = 5

var water_level: int = max_water_level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	sprite.play(&"idle")
	sprite.animation_finished.connect(_on_animation_end)
	sound_timer.timeout.connect(sound.stop)


func get_visuals() -> Array[Node2D]:
	return [$AnimatedSprite2D]

func get_colliders() -> Array[CollisionShape2D]:
	return [$GrabbableArea/CollisionShape2D, $WateringArea/CollisionShape2D]

func use():
	for area in watering_area.get_overlapping_areas():
		var p = area.get_parent()
		if p is Pond:
			refill()
			return
	if water_level > 0:
		sprite.play(&"pour")
		play_water_sound()
		water_level -= 1
		for area in watering_area.get_overlapping_areas():
			var t = area.get_parent()
			if t is GardenTree:
				t.water()
	else:
		play_empty_sound()

func _on_animation_end():
	if sprite.animation != "idle":
		sprite.play(&"idle")

func play_sound(from: float):
	sound.pitch_scale = randfn(1, 0.02)
	sound.play(from)
	sound_timer.start()

func play_water_sound():
	play_sound(1)

func play_empty_sound():
	play_sound(10.4)

func refill():
	water_level = max_water_level
	play_sound(8)
