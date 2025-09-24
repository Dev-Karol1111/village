extends Node2D

@onready var tilemap_layer: TileMapLayer = $TileMapLayer

var block : Array = [Vector2i(1,0), 0] # title cord, source
var can_build := false

func _unhandled_input(event: InputEvent) -> void:
	if !can_build:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouses_pos = get_global_mouse_position()
		var local_pos = tilemap_layer.to_local(mouses_pos)
		
		var title_cords = Vector2i(int(floor(local_pos.x / 16)), int(floor(local_pos.y / 16)))
		
		tilemap_layer.set_cell(title_cords, block[1] , block[0])
	
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT: 
		var mouses_pos = get_global_mouse_position()
		var local_pos = tilemap_layer.to_local(mouses_pos)
		
		var title_cords = Vector2i(int(floor(local_pos.x / 16)), int(floor(local_pos.y / 16)))
		
		tilemap_layer.set_cell(title_cords, 0, Vector2i(1,0))