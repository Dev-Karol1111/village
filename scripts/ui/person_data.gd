extends Control


var people : People

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()
	Signals.data_changed_ui.connect(update)
	

func update():
	$name.text = people.name
	$age.text = tr("age") + ': ' + str(people.age)
	$gender.text = tr("gender") + ': ' + tr(people.gender)
	$health.text = tr("health") + ': ' + str(people.healt)
	$work.text = tr("work") + ': ' + tr(people.work)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var work_select = load("res://scenes/ui/work_choose.tscn").instantiate()
	work_select.people = people
	$CanvasLayer.add_child(work_select)


func _on_experiment_pressed() -> void:
	var work_select = load("res://scenes/ui/experiment_assing.tscn").instantiate()
	work_select.people = people
	$CanvasLayer.add_child(work_select)
