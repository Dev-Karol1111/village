extends Node2D

## Main map controller handling tile placement, building interactions, and road connections
@onready var tilemap_layer: TileMapLayer = $TileMapLayer
@onready var ui_opened_node: Node = $Mode/opened

## Currently selected building type [category, index]
var selected_building: Array = ["transport", 0]
var current_building_data: BuildsBase

## Valid grass tile coordinates for building placement
const GRASS_TILES: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 2), Vector2i(2, 2)]

## Dictionary mapping placed building coordinates to their data
var placed_buildings: Dictionary[Vector2i, BuildsBase]

func _ready() -> void:
	Managment.tilemap = $TileMapLayer
	if Managment.continue_preevious_game:
		load("res://scripts/save_managment.gd").new().load(tilemap_layer)
	Managment.init()
	Signals.building_ended.connect(_on_building_finished)

func _unhandled_input(event: InputEvent) -> void:
	if Managment.totally_pause:
		return
	
	if event is InputEventMouseButton and event.pressed:
		current_building_data = load("res://Builds/buildsList.tres").get(selected_building[0])[selected_building[1]]
		var mouse_pos = get_global_mouse_position()
		var local_pos = tilemap_layer.to_local(mouse_pos)
		var tile_coords = Vector2i(int(floor(local_pos.x / 32)), int(floor(local_pos.y / 32)))

		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_left_click(tile_coords)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_handle_right_click(tile_coords)


func _handle_left_click(tile_coords: Vector2i) -> void:
	if Managment.mode == "normal":
		_open_building_ui(tile_coords)
		return

	if not _can_afford_building():
		return

	if not _can_place_building(tile_coords):
		return

	_place_building(tile_coords)



func _handle_right_click(tile_coords: Vector2i) -> void:
	if Managment.mode == "normal":
		return

	_remove_building(tile_coords)

## Opens the appropriate UI for a building at the given tile coordinates
func _open_building_ui(tile_coords: Vector2i) -> void:
	Signals.close_ui.emit()

	# Check for betting buildings (workplaces)
	for building_dict in Managment.betting.values():
		var building_data = building_dict["data"]
		var cell = tilemap_layer.get_cell_atlas_coords(tile_coords)
		if cell.x == building_data.game_texture_tileset_x and cell.y == building_data.game_texture_tileset_y:
			var ui = load("res://scenes/ui/build_ui.tscn").instantiate()
			ui.building_data = building_data
			ui.building_coords = tile_coords
			ui_opened_node.add_child(ui)
			return
		
	for b in placed_buildings.keys():
		var temporary_data = placed_buildings[b]
		for y in range(int(temporary_data.size[2])):
			for x in range(int(temporary_data.size[0])):
				if tile_coords == b + Vector2i(x, y):
					if temporary_data.type == "house":
						var ui = load("res://scenes/ui/house_info_ui.tscn").instantiate()
						ui.house_data = Managment.houses[b]["data"]
						ui_opened_node.add_child(ui)
						return
					elif temporary_data.type == "betting":
						var ui = load("res://scenes/ui/build_ui.tscn").instantiate()
						ui.building_data = temporary_data
						ui.building_coords = tile_coords
						ui_opened_node.add_child(ui)
						return
						

## Checks if the player can afford to build the current building
func _can_afford_building() -> bool:
	if current_building_data in Managment.free_places:
		return true
	
	for product in current_building_data.products_need_to_build.keys():
		var available_amount = Managment.products.get(product.name, 0)
		var required_amount = current_building_data.products_need_to_build[product]
		
		if required_amount > available_amount:
			return false
	
	return true

## Checks if a building can be placed at the given tile coordinates
func _can_place_building(tile_coords: Vector2i) -> bool:
	var can_place_tiles: Array[bool] = []
	
	for y in range(int(current_building_data.size[2])):
		for x in range(int(current_building_data.size[0])):
			var check_coords = tile_coords + Vector2i(x, y)
			var cell = tilemap_layer.get_cell_atlas_coords(check_coords)
			var is_building_tile = cell == Vector2i(current_building_data.game_texture_tileset_x, current_building_data.game_texture_tileset_y)
			var is_grass_tile = cell in GRASS_TILES
			
			# Can place if it's not already a building tile and is a grass tile
			can_place_tiles.append(not is_building_tile and is_grass_tile)
	
	# All tiles must be valid for placement
	for can_place in can_place_tiles:
		if not can_place:
			return false
	
	return true

## Places a building at the given tile coordinates
func _place_building(tile_coords: Vector2i) -> void:
	# Handle instant buildings (no construction time)
	if not current_building_data.need_building:
		if current_building_data.type == "betting":
			Managment.betting.set(tile_coords, {"data": current_building_data})
		elif current_building_data.type == "house":
			Managment.add_people(current_building_data.living_people)
			Managment.houses.set(tile_coords, {
				"people": current_building_data.living_people,
				"workers": current_building_data.living_people,
				"data": current_building_data
			})
	
	if current_building_data.millstone and !current_building_data.need_building:
		GameEventsManagment.millstones.set(current_building_data.millstone, true)	
	
	# Handle road placement with automatic connection logic
	if Vector2i(current_building_data.game_texture_tileset_x, current_building_data.game_texture_tileset_y) == Vector2i(1, 0):
		var road_data = _calculate_road_tile(tile_coords.x, tile_coords.y)
		tilemap_layer.set_cell(tile_coords, 0, road_data[0], road_data[1])
		_update_adjacent_roads(tile_coords)
	else:
		# Handle buildings that need construction
		if (current_building_data.building_texture_x or current_building_data.building_texture_y) and current_building_data.need_building:
			_set_building_on_tilemap(tile_coords.x, tile_coords.y, current_building_data.building_texture_x, current_building_data.building_texture_y, current_building_data.size)
			placed_buildings.set(tile_coords, current_building_data)
			Signals.start_building.emit(current_building_data)
		else:
			# Place finished building immediately
			_set_building_on_tilemap(tile_coords.x, tile_coords.y, current_building_data.game_texture_tileset_x, current_building_data.game_texture_tileset_y, current_building_data.size)
			placed_buildings.set(tile_coords, current_building_data)

	# Deduct resources or free places
	if current_building_data in Managment.free_places:
		Managment.free_places[current_building_data] -= 1
		if Managment.free_places[current_building_data] <= 0:
			Managment.free_places.erase(current_building_data)
	else:
		for product in current_building_data.products_need_to_build.keys():
			Managment.products[product.name] -= current_building_data.products_need_to_build[product]
	
	Signals.data_changed_ui.emit()

## Removes a building at the given tile coordinates
func _remove_building(tile_coords: Vector2i) -> void:
	var cell = tilemap_layer.get_cell_atlas_coords(tile_coords)
	
	# Remove betting buildings and return workers to houses
	for building_coords in Managment.betting.keys():
		var building_data = Managment.betting[building_coords]["data"]
		if building_data.game_texture_tileset_y == cell.y and building_data.game_texture_tileset_x == cell.x:
			# Return workers to their houses
			for house_coords in Managment.betting[building_coords].get("workers_from", []):
				Managment.houses[house_coords]["workers"] += Managment.betting[building_coords]["workers_from"][house_coords]
			Managment.betting.erase(building_coords)
			break
	
	# Remove houses and decrease population
	if tile_coords in Managment.houses:
		const PEOPLE_PER_HOUSE = 4
		Managment.add_people(-PEOPLE_PER_HOUSE)
	
	# Clear the tilemap
	if tile_coords in placed_buildings:
		_set_building_on_tilemap(tile_coords.x, tile_coords.y, 0, 0, placed_buildings[tile_coords].size)
		placed_buildings.erase(tile_coords)
	
	tilemap_layer.set_cell(tile_coords, 0, Vector2i(0, 0))
	
	# Update roads if removing a road
	if Vector2i(current_building_data.game_texture_tileset_x, current_building_data.game_texture_tileset_y) == Vector2i(1, 0):
		_update_adjacent_roads(tile_coords)

## Updates road tiles around the given coordinates to maintain proper connections
func _update_adjacent_roads(tile_coords: Vector2i) -> void:
	_calculate_road_tile(tile_coords.x, tile_coords.y + 1, true)
	_calculate_road_tile(tile_coords.x, tile_coords.y - 1, true)
	_calculate_road_tile(tile_coords.x + 1, tile_coords.y, true)
	_calculate_road_tile(tile_coords.x - 1, tile_coords.y, true)

## Sets building tiles on the tilemap
func _set_building_on_tilemap(x_map: int, y_map: int, x_tileset: int, y_tileset: int, size: String = "1x1"):
	const SOURCE_ID = 0
	for y in range(int(size[2])):
		for x in range(int(size[0])):
			tilemap_layer.set_cell(
				Vector2i(x_map, y_map) + Vector2i(x, y),
				SOURCE_ID,
				Vector2i(x_tileset + x, y_tileset + y)
			)

## Called when a building construction is finished
func _on_building_finished(build_data: BuildsBase):
	var building_coords: Vector2i
	for coords in placed_buildings.keys():
		if placed_buildings[coords] == build_data:
			building_coords = coords
			break
	
	if build_data.millstone:
		GameEventsManagment.millstones.set(build_data.millstone, true)	
	
	_set_building_on_tilemap(building_coords.x, building_coords.y, build_data.game_texture_tileset_x, build_data.game_texture_tileset_y, build_data.size)
	
	if build_data.type == "betting":
		Managment.betting.set(building_coords, {"data": build_data})
	elif build_data.type == "house":
		Managment.add_people(build_data.living_people)
		Managment.houses.set(building_coords, {
			"people": build_data.living_people,
			"workers": build_data.living_people,
			"data": build_data
		})
	
	Signals.add_information.emit("info", "Building finished", "Building %s is done" % build_data.name)
	
## Calculates the appropriate road tile and rotation based on adjacent roads
## Returns [tile_coords, transform] if second=false, otherwise updates the tilemap directly
func _calculate_road_tile(x: int, y: int, update_tilemap: bool = false):
	const SOURCE_ID = 0
	
	var flip_h = TileSetAtlasSource.TRANSFORM_FLIP_H
	var flip_v = TileSetAtlasSource.TRANSFORM_FLIP_V
	var transpose = TileSetAtlasSource.TRANSFORM_TRANSPOSE
	
	# Road tile coordinates
	var road_tiles = [Vector2i(1, 0), Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)]
	
	# Rotation transforms for different angles
	var rotation_transforms = {
		90: flip_h + transpose,
		180: flip_v + flip_h,
		270: flip_v + transpose
	}
	
	var pos = Vector2i(x, y)
	
	# Check adjacent tiles for roads (north, east, south, west)
	var adjacent_roads: Array[bool] = [
		tilemap_layer.get_cell_atlas_coords(pos + Vector2i(0, -1)) in road_tiles,  # North
		tilemap_layer.get_cell_atlas_coords(pos + Vector2i(1, 0)) in road_tiles,   # East
		tilemap_layer.get_cell_atlas_coords(pos + Vector2i(0, 1)) in road_tiles,   # South
		tilemap_layer.get_cell_atlas_coords(pos + Vector2i(-1, 0)) in road_tiles   # West
	]
	
	var tile_coords: Vector2i
	var transform: int = 0
	
	# Determine road tile based on connections
	if adjacent_roads[0] and adjacent_roads[1] and adjacent_roads[2] and adjacent_roads[3]:
		# Four-way intersection
		tile_coords = Vector2i(2, 3)
		transform = 0
	elif adjacent_roads[0] and adjacent_roads[1] and adjacent_roads[2]:
		# T-junction (north, east, south)
		tile_coords = Vector2i(1, 3)
		transform = rotation_transforms[90]
	elif adjacent_roads[1] and adjacent_roads[2] and adjacent_roads[3]:
		# T-junction (east, south, west)
		tile_coords = Vector2i(1, 3)
		transform = rotation_transforms[180]
	elif adjacent_roads[2] and adjacent_roads[3] and adjacent_roads[0]:
		# T-junction (south, west, north)
		tile_coords = Vector2i(1, 3)
		transform = rotation_transforms[270]
	elif adjacent_roads[3] and adjacent_roads[0] and adjacent_roads[1]:
		# T-junction (west, north, east)
		tile_coords = Vector2i(1, 3)
		transform = 0
	elif adjacent_roads[0] and adjacent_roads[1]:
		# Corner (north-east)
		tile_coords = Vector2i(0, 3)
		transform = 0
	elif adjacent_roads[1] and adjacent_roads[2]:
		# Corner (east-south)
		tile_coords = Vector2i(0, 3)
		transform = rotation_transforms[90]
	elif adjacent_roads[2] and adjacent_roads[3]:
		# Corner (south-west)
		tile_coords = Vector2i(0, 3)
		transform = rotation_transforms[180]
	elif adjacent_roads[3] and adjacent_roads[0]:
		# Corner (west-north)
		tile_coords = Vector2i(0, 3)
		transform = rotation_transforms[270]
	elif adjacent_roads[0] or adjacent_roads[2]:
		# Vertical road
		tile_coords = Vector2i(current_building_data.game_texture_tileset_x, current_building_data.game_texture_tileset_y)
		transform = rotation_transforms[90]
	else:
		# Horizontal road (default)
		tile_coords = Vector2i(current_building_data.game_texture_tileset_x, current_building_data.game_texture_tileset_y)
		transform = 0
	
	if not update_tilemap:
		return [tile_coords, transform]
	else:
		if tilemap_layer.get_cell_atlas_coords(pos) in road_tiles:
			tilemap_layer.set_cell(Vector2i(x, y), SOURCE_ID, tile_coords, transform)
