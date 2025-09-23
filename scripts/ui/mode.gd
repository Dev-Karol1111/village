extends CanvasLayer

var edit_mode := false

@onready var mode_button : Button = $"Mode"
@onready var edit_menu : Node  = $"Edit"

@export var map : NodePath

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	edit_menu.change_visible.emit(false)
	edit_menu.map = map

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mode_pressed() -> void:
	edit_mode = !edit_mode
	if edit_mode:
		mode_button.icon = load("res://assets/ui/exit_edit.png")
		edit_menu.change_visible.emit(true)
	else:
		mode_button.icon = load("res://assets/ui/edit.png")
		edit_menu.change_visible.emit(false)
	
