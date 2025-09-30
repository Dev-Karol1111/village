extends Node2D

@onready var tilemap_layer: TileMapLayer = $TileMapLayer

var block : Array = [Vector2i(1,0), 0, 0] # title cord, source, price
var can_build := false

func _unhandled_input(event: InputEvent) -> void:
	if !can_build:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Managment.moneys - block[2] < 0:
			return
		var mouses_pos = get_global_mouse_position()
		var local_pos = tilemap_layer.to_local(mouses_pos)
		
		var title_cords = Vector2i(int(floor(local_pos.x / 16)), int(floor(local_pos.y / 16)))
	
		if block[0] == Vector2i(1,0):
			var data = check_road(title_cords.x, title_cords.y)
			tilemap_layer.set_cell(title_cords, block[1] , data[0], data[1])
			check_road(title_cords.x, title_cords.y+1, true)
			check_road(title_cords.x, title_cords.y-1, true)
			check_road(title_cords.x+1, title_cords.y, true)
			check_road(title_cords.x-1, title_cords.y, true)
		else:
			tilemap_layer.set_cell(title_cords, block[1] , block[0])
		
		Managment.moneys -= block[2]
		Signals.data_changed.emit()
	
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT: 
		var mouses_pos = get_global_mouse_position()
		var local_pos = tilemap_layer.to_local(mouses_pos)
		
		var title_cords = Vector2i(int(floor(local_pos.x / 16)), int(floor(local_pos.y / 16)))
		
		tilemap_layer.set_cell(title_cords, 0, Vector2i(0,0))
		if block[0] == Vector2i(1,0):
			check_road(title_cords.x, title_cords.y+1, true)
			check_road(title_cords.x, title_cords.y-1, true)
			check_road(title_cords.x+1, title_cords.y, true)
			check_road(title_cords.x-1, title_cords.y, true)

	
	
func check_road(x : int, y : int, second := false):
	
	var flip_h = TileSetAtlasSource.TRANSFORM_FLIP_H
	var flip_v = TileSetAtlasSource.TRANSFORM_FLIP_V
	var transpose = TileSetAtlasSource.TRANSFORM_TRANSPOSE
	
	var blocks = [Vector2i(1,0) ,Vector2i(0,3), Vector2i(1,3), Vector2i(2,3)]	

	var degrees = {
		90 : flip_h + transpose,
		180 : flip_v + flip_h,
		270 : flip_v + transpose
				  }
	
	var block_map: Array[bool] = []
	var pos = Vector2i(x, y)
	
	block_map.append(tilemap_layer.get_cell_atlas_coords(pos + Vector2i(0, -1)) in blocks) 
	block_map.append(tilemap_layer.get_cell_atlas_coords(pos + Vector2i(1, 0)) in blocks) 
	block_map.append(tilemap_layer.get_cell_atlas_coords(pos + Vector2i(0, 1)) in blocks)  
	block_map.append(tilemap_layer.get_cell_atlas_coords(pos + Vector2i(-1, 0)) in blocks) 
	
	var new_block	
	var radio	
	if 	block_map[0] and block_map[1] and block_map[2] and block_map[3]:
		new_block = Vector2i(2,3)
		radio = 0
	elif block_map[0] and block_map[1] and block_map[2]:
		new_block = Vector2i(1,3)
		radio = degrees[90] 
	elif block_map[1] and block_map[2] and block_map[3]:
		new_block = Vector2i(1,3)
		radio = degrees[180]
	elif block_map[2] and block_map[3] and block_map[0]:
		new_block = Vector2i(1,3)
		radio = degrees[270]
	elif block_map[3] and block_map[0] and block_map[1]:
		new_block = Vector2i(1,3)
		radio = 0
	elif block_map[0] and block_map[1]:
		new_block = Vector2i(0,3)
		radio = 0
	elif block_map[1] and block_map[2]:
		new_block = Vector2i(0,3)
		radio = degrees[90]
	elif block_map[2] and block_map[3]:
		new_block = Vector2i(0,3)
		radio = degrees[180]
	elif block_map[3] and block_map[0]:
		new_block = Vector2i(0,3)
		radio = degrees[270]  		
	elif block_map[0] or block_map[2]:
		new_block = block[0]
		radio = degrees[90]			
	else:
		new_block = block[0]
		radio = 0
		
	if !second:
		return [new_block, radio]
	else:
		if (tilemap_layer.get_cell_atlas_coords(pos) in blocks):
			tilemap_layer.set_cell(Vector2i(x,y), block[1] , new_block, radio)
		
	
		
	
		
	
