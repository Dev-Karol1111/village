extends Camera2D

@export var drag_speed: float = 1.0
@export var zoom_step: float = 0.3
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0

var dragging := false
var last_mouse_pos := Vector2.ZERO

var cursor_scale := 1.5

func _ready() -> void:
	_set_cursor("res://assets/ui/cursor-normal.png")

func _unhandled_input(event: InputEvent) -> void:
	# Middle mouse drag
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			dragging = true
			last_mouse_pos = event.position
			_set_cursor("res://assets/ui/cursor-moving.png")
		else:
			dragging = false
			_set_cursor("res://assets/ui/cursor-normal.png")

	elif event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_pos
		position -= delta * drag_speed * (1.0 / zoom.x)
		last_mouse_pos = event.position

	# Zoom with scroll wheel
	if event is InputEventMouseButton and event.pressed:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var zoom_dir = -1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1
			var mouse_pos_before = get_global_mouse_position()

			zoom += Vector2.ONE * zoom_step * zoom_dir * -1
			zoom.x = clamp(zoom.x, min_zoom, max_zoom)
			zoom.y = clamp(zoom.y, min_zoom, max_zoom)

			var mouse_pos_after = get_global_mouse_position()
			position += mouse_pos_before - mouse_pos_after
			
			
func _set_cursor(path: String):
	var tex: Texture2D = load(path)
	if tex:
		var img := tex.get_image()
		img.resize(int(img.get_width() * cursor_scale), int(img.get_height() * cursor_scale))
		var scaled_tex := ImageTexture.create_from_image(img)

		var hotspot = Vector2(scaled_tex.get_width() / 2.0, scaled_tex.get_height() / 2.0)
		Input.set_custom_mouse_cursor(scaled_tex, Input.CURSOR_ARROW, hotspot)