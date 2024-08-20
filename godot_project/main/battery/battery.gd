class_name Battery
extends Spawnable

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var color_rect: ColorRect = $AnimatedSprite2D/ColorRect
var is_active: bool = true
var stween: Tween

func _ready() -> void:
	super()
	var anim_degrees: float = 10
	var ranim_time: float = 0.8
	sprite.rotation_degrees = -anim_degrees
	var rtween = create_tween()
	rtween.set_ease(Tween.EASE_IN_OUT)
	rtween.set_trans(Tween.TRANS_SINE)
	rtween.set_loops()
	rtween.tween_property(sprite, "rotation_degrees", anim_degrees, ranim_time)
	rtween.tween_property(sprite, "rotation_degrees", -anim_degrees, ranim_time)

	var sanim_time: float = 1.6
	var small_scale: Vector2 = sprite.scale
	var big_scale: Vector2 = sprite.scale * 1.2
	stween = create_tween()
	stween.set_ease(Tween.EASE_IN_OUT)
	stween.set_trans(Tween.TRANS_SINE)
	stween.set_loops()
	stween.tween_property(sprite, "scale", big_scale, sanim_time)
	stween.tween_property(sprite, "scale", small_scale, sanim_time)

func get_visuals() -> Array[Node2D]:
	return [sprite]

func get_colliders() -> Array:
	return [$UpgradeArea/CollisionShape2D]

signal consumed()

func consume():
	consumed.emit()
	is_active = false
	stween.stop()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "scale", Vector2(sprite.scale.x / 20, sprite.scale.y * 2 ), 0.3)
	await tween.finished
	custom_hide()
	queue_free()
