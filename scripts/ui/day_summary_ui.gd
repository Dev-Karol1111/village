extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.pause_game.emit()
	Signals.event_happend.emit("time", "pause")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_skip_night_button_pressed() -> void:
	TimeManagment.set_time(TimeManagment.time.to_one_data() + 570)
	Signals.unpause_game.emit()
	Signals.event_happend.emit("time", "unpause")
	queue_free()

func _on_close_button_pressed() -> void:
	Signals.unpause_game.emit()
	Signals.event_happend.emit("time", "unpause")
	queue_free()
