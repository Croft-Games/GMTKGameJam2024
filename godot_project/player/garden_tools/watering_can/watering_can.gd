extends GardenTool

const max_water_level: int = 3

var water_level: int = max_water_level
var is_pouring: bool = false

func _ready() -> void:
	super()
	action_timer.timeout.connect(stop_pouring)

func stop_pouring():
	is_pouring = false
	sprite.play(&"idle")

func _process(delta: float) -> void:
	if is_pouring:
		for area in action_area.get_overlapping_areas():
			var t = area.get_parent()
			if t is GardenPlant:
				t.water()

func use():
	if water_level < max_water_level:
		for area in action_area.get_overlapping_areas():
			var p = area.get_parent()
			if p is Pond:
				refill()
				return
	if water_level > 0:
		if not is_pouring:
			sprite.play(&"pour")
			play_water_sound()
			water_level -= 1
			is_pouring = true
	else:
		empty_animation()

func play_water_sound():
	play_sound(1)

func play_empty_sound():
	play_sound(10.4)

func refill():
	water_level = max_water_level
	play_sound(8)

func empty_animation():
	play_empty_sound()
	var empty_tween = create_tween()
	empty_tween.set_trans(Tween.TRANS_SINE)
	empty_tween.set_ease(Tween.EASE_IN_OUT)
	empty_tween.tween_property(sprite, "rotation_degrees", -15 * facing_mult(), 0.2)
	empty_tween.tween_property(sprite, "rotation_degrees", 15 * facing_mult(), 0.2)
	empty_tween.tween_property(sprite, "rotation_degrees", 0, 0.2)
