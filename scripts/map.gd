extends Node2D

@onready var tilemap_layer: TileMapLayer = $TileMapLayer
@export var block_id: int = 1  # ID kafelka do stawiania

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouses_pos = get_global_mouse_position()
		var local_pos = tilemap_layer.to_local(mouses_pos)
		
		var title_cords = Vector2i(int(floor(local_pos.x / 16)),
			int(floor(local_pos.y / 16))
		)
		
		tilemap_layer.set_cell(title_cords, 0, Vector2i(2,0))
