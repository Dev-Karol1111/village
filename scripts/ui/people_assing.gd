extends Control

signal closed(items)

@export var max_select := 2
@export var items := []

@onready var itemlist := $ItemList

var selected_list := []


func _ready() -> void:
	itemlist.select_mode = ItemList.SELECT_TOGGLE
	for item in items:
		itemlist.add_item(item)
	itemlist.multi_selected.connect(_on_item_toggled)


func _on_close_pressed() -> void:
	closed.emit(selected_list)
	queue_free()


func _on_item_toggled(index: int, selected: bool) -> void:
	var item = items[index]
	if selected:
		if len(selected_list) < max_select:
			selected_list.append(item)
		else:
			itemlist.deselect(index)
	else:
		selected_list.erase(item)