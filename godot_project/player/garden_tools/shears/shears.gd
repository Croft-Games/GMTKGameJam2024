extends GardenTool

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sound_timer: Timer = $AudioStreamPlayer2D/Timer
@onready var snipping_area: Area2D = $SnippingArea


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play(&"idle")
	sprite.animation_finished.connect(_on_animation_end)
	sound_timer.timeout.connect(sound.stop)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func use():
	sprite.play(&"snip")
	play_snip_sound()
	for area in snipping_area.get_overlapping_areas():
		var t = area.get_parent()
		if t is GardenTree:
			t.prune()

func _on_animation_end():
	if sprite.animation != "idle":
		sprite.play(&"idle")

func play_sound(from: float):
	sound.pitch_scale = randfn(1, 0.02)
	sound.play(from)
	sound_timer.start()

func play_snip_sound():
	play_sound(1)
