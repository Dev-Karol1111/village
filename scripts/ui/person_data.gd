extends Control

## UI panel displaying individual person information
var person: People

func _ready() -> void:
	update_display()
	Signals.data_changed_ui.connect(update_display)

func update_display():
	$name.text = person.name
	$age.text = tr("age") + ": " + str(person.age)
	$gender.text = tr("gender") + ": " + tr(person.gender)
	$health.text = tr("health") + ": " + str(person.healt)
	$work.text = tr("work") + ": " + tr(person.work)

func _on_button_pressed() -> void:
	var selection_ui = load("res://scenes/ui/selection_ui.tscn").instantiate()
	selection_ui.selection_mode = selection_ui.SelectionMode.WORK_CHOOSE
	selection_ui.title_text = tr("choose work")
	selection_ui.person = person
	$CanvasLayer.add_child(selection_ui)

func _on_experiment_pressed() -> void:
	var selection_ui = load("res://scenes/ui/selection_ui.tscn").instantiate()
	selection_ui.selection_mode = selection_ui.SelectionMode.EXPERIMENT_ASSIGN
	selection_ui.title_text = tr("assign to experiment")
	selection_ui.person = person
	$CanvasLayer.add_child(selection_ui)
