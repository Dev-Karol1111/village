extends Node

## Main game management singleton handling resources, buildings, and game state

var money: int = 500
var people_count: int = 0

var tilemap: TileMapLayer

var available_workers: int

var mode: String = "normal"

## Dictionary mapping house coordinates to house data
## Structure: {coords: {"people": int, "workers": int, "data": HouseBase}}
var houses: Dictionary[Vector2i, Dictionary] = {}

## Dictionary mapping workplace coordinates to workplace data
## Structure: {coords: {"data": BettingBase, "connected_houses": Array, "workers_from": Dictionary, "gotta_update": bool, "workers": int}}
var betting: Dictionary[Vector2i, Dictionary] = {}

## Dictionary tracking production progress for each workplace
var production_time: Dictionary[Vector2i, int] = {}

## Dictionary of available products and their quantities
var products: Dictionary[String, int] = {"flour": 100, "fruit": 0}

## Game speed multiplier (1 = normal speed)
var speed_time: int = 1

## Dictionary of buildings available for free placement
var free_places: Dictionary[BuildsBase, int]

## A* grid for pathfinding between buildings
var transport_connection_astar_grid: AStarGrid2D

var was_edit_menu_opened: bool = false

@onready var running: bool = true

var totally_pause: bool = false

const WATER_TILE: Vector2i = Vector2i(0, 2)

var people: Array[People]

var multiple_speed: int = 1

var available_experiments: Dictionary[ExperimentBase, Array]

var canvas_layer: CanvasLayer

func _ready() -> void:
	canvas_layer = CanvasLayer.new()
	canvas_layer.name = "GlobalUI"
	canvas_layer.layer = 100
	get_tree().root.add_child.call_deferred(canvas_layer)

## Main production loop that processes workplace production every game tick
func production_loop() -> void:
	while running:
		if speed_time > 0 and not totally_pause:
			PeopleManagment.working()
			
			# Mark workplaces for worker update if edit menu was opened
			for workplace_coords in betting:
				if was_edit_menu_opened:
					betting[workplace_coords]["gotta_update"] = true
				WorkersManagement.check_workers()
			
			# Process production for each workplace
			for workplace_coords in betting:
				if was_edit_menu_opened:
					betting[workplace_coords]["gotta_update"] = true
				
				var workplace_data = betting[workplace_coords]["data"]
				
				# Skip if not fully staffed
				if betting[workplace_coords].get("workers", 0) != workplace_data.need_workers:
					continue
				
				# Increment production timer
				production_time.set(workplace_coords, production_time.get(workplace_coords, 0) + 1)
				
				# Check if production cycle is complete
				if production_time[workplace_coords] >= workplace_data.product_time:
					production_time.set(workplace_coords, 0)
					
					# Consume input products
					for input_product in workplace_data.input_products.keys():
						products[input_product.name] -= workplace_data.input_products[input_product]
					
					# Produce output products
					for output_product in workplace_data.output_products.keys():
						products[output_product.name] = products.get(output_product.name, 0) + workplace_data.output_products[output_product]
			
			Signals.data_changed_build_info.emit()
			if was_edit_menu_opened:
				was_edit_menu_opened = false
			
			await get_tree().create_timer(float(speed_time) / multiple_speed).timeout
		else:
			await get_tree().process_frame
			
## Initializes the game state
func init():
	totally_pause = false
	available_workers = people_count
	
	# Load free building places
	var build_list = load("res://Builds/buildsList.tres")
	for building in build_list.betting:
		if building.free_places > 0:
			free_places.set(building, building.free_places)
	for house in build_list.house:
		if house.free_places > 0:
			free_places.set(house, house.free_places)
	
	# Initialize starting population
	for i in range(10):
		var person: People = load("res://scripts/bases/people.gd").new()
		person.generate_data("adult")
		people.append(person)
	for i in range(6):
		var person: People = load("res://scripts/bases/people.gd").new()
		person.generate_data("child")
		people.append(person)
	for i in range(2):
		var person: People = load("res://scripts/bases/people.gd").new()
		person.generate_data("greybeard")
		people.append(person)
	
	# Initialize available experiments
	var experiment_list = load("res://resources/experiment_list.tres")
	for experiment in experiment_list.experiments:
		available_experiments.set(experiment, [])
	
	# Start game loops
	production_loop()
	TimeManagment.time_loop()
	ToturialManagement.check_data()
				
## Adds or removes people from the population
func add_people(value: int):
	people_count += value
	available_workers += value
	Signals.data_changed_ui.emit()

## Checks if there's a valid path between two tiles
func check_connection(from_tile: Vector2i, to_tile: Vector2i) -> bool:
	if transport_connection_astar_grid:
		var path = transport_connection_astar_grid.get_id_path(from_tile, to_tile)
		return len(path) > 0
	return false

## Creates the A* pathfinding grid for transport connections
func make_transport_map(tile_map_layer: TileMapLayer):
	var astar_grid = AStarGrid2D.new()
	astar_grid.region = Rect2i(0, 0, 55, 32)
	astar_grid.cell_size = Vector2i(32, 32)
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	for cell in tile_map_layer.get_used_cells():
		var is_transportable = tile_map_layer.get_cell_tile_data(cell).get_custom_data("transport")
		astar_grid.set_point_solid(cell, not is_transportable)
	
	transport_connection_astar_grid = astar_grid

## Spawns a UI scene on the global canvas layer
func spawn_ui(scene_path: String) -> void:
	var ui = load(scene_path).instantiate()
	canvas_layer.add_child(ui)
	

