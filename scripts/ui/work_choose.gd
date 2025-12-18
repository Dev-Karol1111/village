extends Control

var people : People

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var works = load("res://resources/work_list.tres")
	for work in works.works_list:
		$ItemList.add_item(work.name_var)


func _on_item_list_item_selected(index: int) -> void:
	var works = load("res://resources/work_list.tres")
	people.work = works.works_list[index].name_var 
	Signals.data_changed_ui.emit()
	#for people_tets in Managment.people:
	#	print(people_tets.work)


func _on_close_pressed() -> void:
	queue_free()
