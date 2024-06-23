@tool
extends Control

@export var label: String

func _ready():
	$Label.text = label
