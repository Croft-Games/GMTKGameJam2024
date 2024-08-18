extends GardenTool

const max_water_level: int = 5

var water_level: int = max_water_level

func use():
	if water_level < max_water_level:
		for area in action_area.get_overlapping_areas():
			var p = area.get_parent()
			if p is Pond:
				refill()
				return
	if water_level > 0:
		sprite.play(&"pour")
		play_water_sound()
		water_level -= 1
		for area in action_area.get_overlapping_areas():
			var t = area.get_parent()
			if t is GardenPlant:
				t.water()
	else:
		play_empty_sound()

func play_water_sound():
	play_sound(1)

func play_empty_sound():
	play_sound(10.4)

func refill():
	water_level = max_water_level
	play_sound(8)
