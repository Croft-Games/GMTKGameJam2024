extends Control

@onready var settings_panel = $MarginContainer/VBoxContainer/SettingsPanel

func show_settings():
	visible = true

func hide_settings():
	visible = false

func _on_back_button_pressed():
	hide_settings()
