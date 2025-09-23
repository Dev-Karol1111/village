extends Camera2D

@export var drag_speed: float = 1.0
@export var zoom_step: float = 0.3
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0

var dragging := false
var last_mouse_pos := Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	# moving 
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			dragging = true
			last_mouse_pos = event.position
		else:
			dragging = false

	if event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_pos
		position -= delta * drag_speed * (1.0 / zoom.x)
		last_mouse_pos = event.position

	# Zoom
	if event is InputEventMouseButton:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN] and event.pressed:
			var old_zoom = zoom
			var zoom_dir = -1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1

			var mouse_pos_before = get_global_mouse_position()

			zoom += Vector2.ONE * zoom_step * zoom_dir * -1
			zoom.x = clamp(zoom.x, min_zoom, max_zoom)
			zoom.y = clamp(zoom.y, min_zoom, max_zoom)

			var mouse_pos_after = get_global_mouse_position()

			position += mouse_pos_before - mouse_pos_after
