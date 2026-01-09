extends Control

var people : People

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for work in Managment.avaible_experiments.keys():
		$ItemList.add_item(work.name_var)


func _on_item_list_item_selected(index: int) -> void:
	var key = Managment.avaible_experiments.keys()[index]
	Managment.avaible_experiments[key].append(people)


func _on_close_pressed() -> void:
	queue_free()