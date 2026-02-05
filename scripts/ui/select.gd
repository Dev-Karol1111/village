extends Control

@export var options: Array[String] = ["Option1", "Option2"]
@export var option_selected: int = 1

var selected

signal value_changed(string: String)

@onready var option_label: Label = $"HBox/Label"


func _ready() -> void :
	selected = option_selected - 1
	# Translate option labels if they are translation keys
	var translated_option = options[selected]
	if translated_option in ["fullscreen", "windowed", "english", "polish"]:
		option_label.text = tr(translated_option)
	else:
		option_label.text = translated_option

func update(change: int):
	selected = (selected + change + len(options)) % len(options)
	# Translate option labels if they are translation keys
	var translated_option = options[selected]
	if translated_option in ["fullscreen", "windowed", "english", "polish"]:
		option_label.text = tr(translated_option)
	else:
		option_label.text = translated_option
	value_changed.emit(options[selected])

func select(change: int):
	update(change)


func _on_left_pressed() -> void :
	update(-1)


func _on_button_pressed() -> void :
	update(1)
