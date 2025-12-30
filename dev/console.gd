extends Control

@onready var input : LineEdit = $LineEdit
@onready var output : Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	input.text = ""
	output.text = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_J:
		visible = not visible 


func _on_line_edit_text_submitted(new_text: String) -> void:
	var data = new_text.split(" ")
	input.text = ""
	
	if data[0] == "/set":
		if data[1] == "time":
			if !data[2].is_valid_int(): return
			TimeManagment.set_time(int(data[2]))
			output.text = output.text + "\n time set to %s" % data[2]
		if data[1] == "speed":
			if !data[2].is_valid_int(): return
			Managment.multiple_speed = data[2]
			output.text = output.text + "\n time speed set to %s" % data[2]
