extends Node2D


var has_moved: bool = false
var has_grabbed: bool = false
var has_used: bool = false

func on_first_move():
	if not has_moved:
		has_moved = true
		$Movement.hide()
		if not has_grabbed:
			$Grab.show()

signal highlight_tools
signal highlight_plants

func on_grab(actually_grabbed: bool):
	if has_grabbed:
		return
	if actually_grabbed:
		$Grab.hide()
		has_grabbed = true
		if not has_used:
			$Use.show()
	else:
		highlight_tools.emit()

func use(actually_used: bool):
	if not has_used:
		if actually_used:
			has_used = true
			$Use.hide()
		else:
			highlight_plants.emit()

func _input(event: InputEvent) -> void:
	if has_moved:
		return
	for a in ["move_left", "move_right", "move_up", "move_down"]:
		if event.is_action_pressed(a):
			on_first_move()
			return
