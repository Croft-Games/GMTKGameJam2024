extends GardenTool

@export var sounds: Dictionary = {}
const max_fruit_level: int = 3
var fruit_level: int = 0

func _ready() -> void:
	super()
	set_fruit_level(0)

func use():
	if fruit_level > 0:
		for area in action_area.get_overlapping_areas():
			var p = area.get_parent()
			if p is FruitDepot:
				empty_fruit()
				return
	if fruit_level >= max_fruit_level:
		tool_failed.emit("fruit")
		play_full_sound()
		return
	for area in action_area.get_overlapping_areas():
		var t = area.get_parent()
		if t is GardenPlant:
			var collected_fruit: bool = t.collect()
			if collected_fruit:
				collect_fruit()

func play_collect_sound():
	sound.stream = sounds["collect"]
	play_sound(0)

func play_empty_sound():
	sound.stream = sounds["drop"]
	play_sound(0)

func play_full_sound():
	pass
	#sound.stream = sounds["full"]
	#play_sound(0)

func empty_fruit():
	set_fruit_level(0)
	play_empty_sound()

func set_fruit_level(level: int):
	fruit_level = level
	if level <= 0:
		sprite.play(&"empty")
	elif level == 1:
		sprite.play(&"one_third")
	elif level == 2:
		sprite.play(&"two_thirds")
	else:
		sprite.play(&"full")

func collect_fruit():
	set_fruit_level(fruit_level + 1)
	play_collect_sound()
