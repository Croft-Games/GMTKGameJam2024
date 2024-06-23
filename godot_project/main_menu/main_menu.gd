extends Control

@onready var settings_page = $SettingsPage

func _ready():
	$MenuContainer/VBoxContainer/HBoxContainer/VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://main/main.tscn")


func _on_settings_button_pressed():
	settings_page.visible = true
	


func _on_exit_pressed():
	get_tree().quit()
