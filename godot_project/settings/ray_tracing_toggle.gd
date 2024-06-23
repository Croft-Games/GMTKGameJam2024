extends CheckButton


# Called when the node enters the scene tree for the first time.
func _ready():
	set_pressed_no_signal(Settings.ray_tracing)


func _toggled(toggled_on: bool):
	Settings.ray_tracing = toggled_on
