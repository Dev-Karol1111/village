extends Node2D

@onready var tilemap_layer: TileMapLayer = $TileMapLayer
@onready var ui_opened_node : Node = $Mode/opened

var block : Array = [Vector2i(1,0), 0, 0, 0] # title cord, source, price, index

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var local_pos = tilemap_layer.to_local(mouse_pos)
		var tile_coords = Vector2i(int(floor(local_pos.x / 16)), int(floor(local_pos.y / 16)))

		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_left_click(tile_coords)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_handle_right_click(tile_coords)


func _handle_left_click(tile_coords: Vector2i) -> void:
	if Managment.mode == "normal":
		_open_build_ui(tile_coords)
		return

	if not _can_afford(block[2]):
		return

	if not _can_place_block(tile_coords):
		return

	_place_block(tile_coords)



func _handle_right_click(tile_coords: Vector2i) -> void:
	if Managment.mode == "normal":
		return

	_remove_block(tile_coords)
	
func _open_build_ui(tile_coords: Vector2i) -> void:
	for child in ui_opened_node.get_children():
		child.queue_free()

	for bett in Managment.betting:
		var cell = tilemap_layer.get_cell_atlas_coords(tile_coords)
		if cell.x == bett.game_texture_tileset_x and cell.y == bett.game_texture_tileset_y:
			var ui = load("res://scenes/ui/build_ui.tscn").instantiate()
			ui_opened_node.add_child(ui)
			return

func _can_afford(cost: int) -> bool:
	return Managment.moneys - cost >= 0

func _can_place_block(tile_coords: Vector2i) -> bool:
	var cell = tilemap_layer.get_cell_atlas_coords(tile_coords)
	return not (cell == block[0] or cell != Vector2i(0,0))

func _place_block(tile_coords: Vector2i) -> void:
	if load("res://Builds/buildsList.tres").builds[block[3]].type == "betting":
		Managment.betting.append(load("res://Builds/buildsList.tres").builds[block[3]])

	if block[0] == Vector2i(1,0): # droga
		var data = check_road(tile_coords.x, tile_coords.y)
		tilemap_layer.set_cell(tile_coords, block[1], data[0], data[1])
		_update_roads_around(tile_coords)
	else:
		tilemap_layer.set_cell(tile_coords, block[1], block[0])

	Managment.moneys -= block[2]
	Signals.data_changed.emit()

func _remove_block(tile_coords: Vector2i) -> void:
	tilemap_layer.set_cell(tile_coords, 0, Vector2i(0,0))
	if block[0] == Vector2i(1,0):
		_update_roads_around(tile_coords)

func _update_roads_around(tile_coords: Vector2i) -> void:
	check_road(tile_coords.x, tile_coords.y+1, true)
	check_road(tile_coords.x, tile_coords.y-1, true)
	check_road(tile_coords.x+1, tile_coords.y, true)
	check_road(tile_coords.x-1, tile_coords.y, true)

	
	
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
		
	
		
	
		
	
