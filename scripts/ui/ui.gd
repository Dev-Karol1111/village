extends Node

@onready var money_label : Label = $points/Label
@onready var people_label : Label = $people/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.data_changed_ui.connect(update_data)
	update_data()

	
func update_data():
	money_label.text = "%s" % Managment.legacy_points
	people_label.text = "%s" % Managment.people_count
