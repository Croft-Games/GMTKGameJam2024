extends Slider

@export var bus: StringName
var bus_index: int

func _ready():
	bus_index = AudioServer.get_bus_index(bus)
	var current_volume: float = db_to_linear(
		AudioServer.get_bus_volume_db(bus_index)
	)
	set_value_no_signal(current_volume)

func _on_value_changed(new_value: float):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(new_value))
