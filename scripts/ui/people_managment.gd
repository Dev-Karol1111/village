extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for people in Managment.people:
		var person_data = load("res://scenes/ui/person_data.tscn").instantiate()
		person_data.people = people
		$"Scroll/VBox".add_child(person_data)
	
	Signals.close_ui.connect(func(): queue_free())
		