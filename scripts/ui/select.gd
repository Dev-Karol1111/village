extends Control

@export var options : Array[String] = ["Option1", "Option2"]
@export var option_selected : int = 1

var selected

signal value_changed(string: String)

@onready var option_label : Label = $"HBox/Label"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selected = option_selected - 1
	option_label.text = options[selected]

func update(change: int):
	selected = (selected + change + len(options)) % len(options)
	option_label.text = options[selected]
	value_changed.emit(options[selected])
	

func _on_left_pressed() -> void:
	update(-1)
	

func _on_button_pressed() -> void:
	update(1)
