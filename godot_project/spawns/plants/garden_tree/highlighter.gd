extends Sprite2D

@export var highlight_time: float = 1

func _ready() -> void:
	hide()
	modulate = Color.TRANSPARENT

func highlight():
	show()
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, highlight_time/2)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, highlight_time/2)
	await tween.finished
	hide()
