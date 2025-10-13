extends CanvasLayer

@onready var mode_button : Button = $"Mode"
@onready var edit_menu : Node  = $"Edit"

@export var map : NodePath


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	edit_menu.change_visible.emit(false)
	edit_menu.map = get_node(map) 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_mode_pressed() -> void:
	var map_node = get_node(map)
	Managment.mode = ("normal" if Managment.mode == "edit" else "edit")
	if Managment.mode == "edit":
		mode_button.icon = load("res://assets/ui/exit_edit.png")
		edit_menu.change_visible.emit(true)
	else:
		mode_button.icon = load("res://assets/ui/edit.png")
		edit_menu.change_visible.emit(false)
	


func _on_save_pressed() -> void:
	load("res://scripts/save_managment.gd").new().save(get_node(map).get_child(0))


func _on_load_pressed() -> void:
	load("res://scripts/save_managment.gd").new().load(get_node(map).get_child(0))
