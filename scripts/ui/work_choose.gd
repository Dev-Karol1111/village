extends Control

var people : People

var works

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for work in PeopleManagment.avaible_works:
		$ItemList.add_item(work.name_var)


func _on_item_list_item_selected(index: int) -> void:
	works = PeopleManagment.avaible_works
	people.work = works[index].name_var 
	Signals.data_changed_ui.emit()
	#for people_tets in Managment.people:
	#	print(people_tets.work)


func _on_close_pressed() -> void:
	queue_free()
