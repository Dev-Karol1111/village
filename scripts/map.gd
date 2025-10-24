extends Node2D

@onready var tilemap_layer: TileMapLayer = $TileMapLayer
@onready var ui_opened_node : Node = $Mode/opened

var block = ["transport", 0] # list, index
var block_data : BuildsBase

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		block_data = load("res://Builds/buildsList.tres").get(block[0])[block[1]]
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

	if not _can_afford():
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

	for bett in Managment.betting.values():
		var cell = tilemap_layer.get_cell_atlas_coords(tile_coords)
		if cell.x == bett.game_texture_tileset_x and cell.y == bett.game_texture_tileset_y:
			var ui = load("res://scenes/ui/build_ui.tscn").instantiate()
			ui.data = bett
			ui.cords = tile_coords
			ui_opened_node.add_child(ui)
			return

func _can_afford() -> bool:
	if block_data in Managment.free_places:
		return true
	for product in block_data.products_need_to_build.keys():
		var value
		if Managment.products.get(product.name):
			value = Managment.products.get(product.name)
		else:
			value = 0
		if block_data.products_need_to_build[product] <= value:
			pass
		else:
			return false
	return true	

func _can_place_block(tile_coords: Vector2i) -> bool:
	var cell = tilemap_layer.get_cell_atlas_coords(tile_coords)
	return not (cell == Vector2i(block_data.game_texture_tileset_x, block_data.game_texture_tileset_y) or cell != Vector2i(0,0))

func _place_block(tile_coords: Vector2i) -> void:
	if block_data.type == "betting":
		Managment.betting.set(tile_coords, block_data)
	if block_data.type == "house":
		Managment.add_people(block_data.living_people)
		Managment.houses.append(tile_coords)
	if Vector2i(block_data.game_texture_tileset_x, block_data.game_texture_tileset_y) == Vector2i(1,0): # droga
		var data = check_road(tile_coords.x, tile_coords.y)
		tilemap_layer.set_cell(tile_coords, 0, data[0], data[1]) #0 - source
		_update_roads_around(tile_coords)
	else:
		tilemap_layer.set_cell(tile_coords, 0, Vector2i(block_data.game_texture_tileset_x, block_data.game_texture_tileset_y)) #0 - source

	if block_data in Managment.free_places:
		Managment.free_places[block_data] -= 1
		if Managment.free_places[block_data] <= 0:
			Managment.free_places.erase(block_data)
	else:	
		for product in block_data.products_need_to_build.keys():
			Managment.products[product.name] -= block_data.products_need_to_build[product]
	Signals.data_changed_ui.emit()

func _remove_block(tile_coords: Vector2i) -> void:
	var cell = tilemap_layer.get_cell_atlas_coords(tile_coords)
	for _bett in Managment.betting.keys():
		var bett = Managment.betting[_bett]
		if bett.game_texture_tileset_y == cell.y and bett.game_texture_tileset_x == cell.x:
			Managment.avaible_workers += Managment.working_places[_bett]
			Managment.betting.erase(bett)
			break
	if tile_coords in Managment.houses:
		Managment.add_people(-4) # 4 - value of people in house
	tilemap_layer.set_cell(tile_coords, 0, Vector2i(0,0))
	if Vector2i(block_data.game_texture_tileset_x, block_data.game_texture_tileset_y) == Vector2i(1,0):
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
		new_block = Vector2i(block_data.game_texture_tileset_x, block_data.game_texture_tileset_y)
		radio = degrees[90]			
	else:
		new_block = Vector2i(block_data.game_texture_tileset_x, block_data.game_texture_tileset_y)
		radio = 0
		
	if !second:
		return [new_block, radio]
	else:
		if (tilemap_layer.get_cell_atlas_coords(pos) in blocks):
			tilemap_layer.set_cell(Vector2i(x,y), 0 , new_block, radio) #0 - source
			