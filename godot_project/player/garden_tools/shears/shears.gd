extends GardenTool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	sprite.play(&"idle")
	sprite.animation_finished.connect(_on_animation_end)
	sound_timer.timeout.connect(sound.stop)


func use():
	sprite.play(&"snip")
	play_snip_sound()
	for area in action_area.get_overlapping_areas():
		var t = area.get_parent()
		if t is GardenPlant:
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
