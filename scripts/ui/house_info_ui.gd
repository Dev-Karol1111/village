extends Control

## UI panel displaying house information and allowing people assignment
@onready var house_name_label: Label = $TextureRect/name
@onready var people_label: Label = $TextureRect/Label

var house_data: HouseBase

func _ready() -> void:
	Signals.close_ui.connect(func(): queue_free())
	update_display()

func update_display():
	house_name_label.text = house_data.name
	var people_text = ""
	var count = 0
	
	for person in house_data.liveing_people:
		count += 1
		if count > house_data.max_people:
			break
		people_text += " * " + person.name + "\n"
	
	var header_text = tr("living people") + " (%s/%s):\n" % [count, house_data.max_people]
	people_label.text = header_text + people_text

func _on_button_pressed() -> void:
	var selection_ui = load("res://scenes/ui/selection_ui.tscn").instantiate()
	var person_names = []
	
	for person in Managment.people:
		person_names.append(person.name)
	
	selection_ui.selection_mode = selection_ui.SelectionMode.PEOPLE_ASSIGN
	selection_ui.title_text = tr("people assing")
	selection_ui.items = person_names
	selection_ui.max_select = house_data.max_people
	selection_ui.closed.connect(_on_people_assigned)
	$CanvasLayer.add_child(selection_ui)

func _on_people_assigned(selected_names: Array):
	house_data.liveing_people.clear()
	for person in Managment.people:
		for selected_name in selected_names:
			if selected_name == person.name:
				house_data.liveing_people.append(person)
	update_display()