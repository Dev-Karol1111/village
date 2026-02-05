extends Control

## Unified selection UI that can handle people assignment, work selection, and experiment assignment
## Supports both single-select and multi-select modes

signal closed(selected_items: Array)

enum SelectionMode {
	PEOPLE_ASSIGN,    # Multi-select for assigning people to houses
	WORK_CHOOSE,      # Single-select for choosing work for a person
	EXPERIMENT_ASSIGN # Single-select for assigning person to experiment
}

@export var selection_mode: SelectionMode = SelectionMode.PEOPLE_ASSIGN
@export var title_text: String = "Select"
@export var max_select: int = 2  # Only used for PEOPLE_ASSIGN mode
@export var items: Array = []  # Only used for PEOPLE_ASSIGN mode

# Used for WORK_CHOOSE and EXPERIMENT_ASSIGN modes
var person: People

@onready var title_label: Label = $Label
@onready var item_list: ItemList = $ItemList
@onready var close_button: Button = $close

var selected_list: Array = []
var works_list: Array[WorkBase] = []
var experiments_list: Array = []

func _ready() -> void:
	title_label.text = title_text
	_setup_selection_mode()
	_populate_items()

func _setup_selection_mode() -> void:
	match selection_mode:
		SelectionMode.PEOPLE_ASSIGN:
			item_list.select_mode = ItemList.SELECT_TOGGLE
			item_list.multi_selected.connect(_on_item_toggled)
		SelectionMode.WORK_CHOOSE, SelectionMode.EXPERIMENT_ASSIGN:
			item_list.select_mode = ItemList.SELECT_SINGLE
			item_list.item_selected.connect(_on_item_selected)

func _populate_items() -> void:
	match selection_mode:
		SelectionMode.PEOPLE_ASSIGN:
			# Use provided items array
			for item in items:
				item_list.add_item(item)
		
		SelectionMode.WORK_CHOOSE:
			# Load works from PeopleManagment
			works_list = PeopleManagment.available_works
			for work in works_list:
				var work_name = work.name_var.to_lower().replace(" ", " ")
				item_list.add_item(tr(work_name))
		
		SelectionMode.EXPERIMENT_ASSIGN:
			# Load experiments from Managment
			experiments_list = Managment.available_experiments.keys()
			for experiment in experiments_list:
				var experiment_name = experiment.name_var.to_lower()
				item_list.add_item(tr(experiment_name))

func _on_item_toggled(index: int, selected: bool) -> void:
	# Only used for PEOPLE_ASSIGN mode (multi-select)
	var item = items[index]
	if selected:
		if len(selected_list) < max_select:
			selected_list.append(item)
		else:
			item_list.deselect(index)
	else:
		selected_list.erase(item)

func _on_item_selected(index: int) -> void:
	# Used for WORK_CHOOSE and EXPERIMENT_ASSIGN modes (single-select)
	match selection_mode:
		SelectionMode.WORK_CHOOSE:
			if person and index < works_list.size():
				person.work = works_list[index].name_var
				Signals.data_changed_ui.emit()
				queue_free()
		
		SelectionMode.EXPERIMENT_ASSIGN:
			if person and index < experiments_list.size():
				var experiment_key = experiments_list[index]
				Managment.available_experiments[experiment_key].append(person)
				queue_free()

func _on_close_pressed() -> void:
	match selection_mode:
		SelectionMode.PEOPLE_ASSIGN:
			closed.emit(selected_list)
		SelectionMode.WORK_CHOOSE, SelectionMode.EXPERIMENT_ASSIGN:
			# For single-select modes, just close without selection
			pass
	queue_free()
