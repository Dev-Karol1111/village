extends Node2D

@onready var title = $title
@onready var message = $message

var can_skip = false

func _ready() -> void:
	Signals.add_toturial.connect(add_toturial)
	Signals.del_toturial_frontend.connect(del_toturial)
	visible = false

func add_toturial(title_input : String, message_input : String, can_skip_input := false):
	title.text = title_input
	message.text = message_input
	can_skip = can_skip_input
	visible = true

func del_toturial():
	visible = false

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_skip:
			del_toturial()
			Signals.del_toturial_backend.emit()
