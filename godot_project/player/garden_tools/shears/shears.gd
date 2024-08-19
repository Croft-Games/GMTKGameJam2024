extends GardenTool


func use():
	sprite.play(&"snip")
	play_snip_sound()
	for area in action_area.get_overlapping_areas():
		var t = area.get_parent()
		if t is GardenPlant:
			t.prune()

func play_snip_sound():
	play_sound(1)
