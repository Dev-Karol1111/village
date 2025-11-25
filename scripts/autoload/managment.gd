extends Node

var moneys := 500
var people_count := 0

var tilemap: TileMapLayer

var avaible_workers : int
#var working_places : Dictionary[Vector2i, int] =  {}

var mode := "normal"

var houses : Dictionary[Vector2i, Dictionary] = {}
var betting : Dictionary[Vector2i, Dictionary] = {} # data - BettingBase, connected_houses - Vector2i, workers_from - Vector21, gotta_update - bool, workers - int
var production_time : Dictionary[Vector2i, int] = {}

var products : Dictionary[String, int] = {"flour" : 100}

var speed_time := 1

var free_places : Dictionary[BuildsBase, int]

var transport_connection_astartgrid : AStarGrid2D

var was_edit_menu_opened := false

@onready var running := true

var totally_pause := false

const water := Vector2i(0,2)

var people : Array[People]

var avaible_works : Array = ["TEST1", "TEST2", "TEST3"]

func _ready() -> void:
	init()
	production_loop()

func production_loop() -> void:
	while running:
		if speed_time > 0 and !totally_pause:
			for _betting in betting:
				if was_edit_menu_opened:
					betting[_betting]["gotta_update"] = true
				WorkersManagement.check_workers()
			for _betting in betting:
				if was_edit_menu_opened:
					betting[_betting]["gotta_update"] = true 		
				var bett = betting[_betting]["data"]
				
				#WorkersManagement.check_workers(_betting)

				if Managment.betting[_betting].get("workers", 0) != bett.need_workers:
					continue
					
				production_time.set(_betting, production_time.get(_betting, 0) + 1)
				if production_time[_betting] >= bett.product_time:
					production_time.set(_betting, 0)

					for input_product in bett.input_products.keys():
						products[input_product.name] -= bett.input_products[input_product]

					for output_product in bett.output_products.keys():
						products[output_product.name] = products.get(output_product.name, 0) + bett.output_products[output_product]
						print(products)
			Signals.data_changed_build_info.emit()	
			if was_edit_menu_opened:
				was_edit_menu_opened = false	
			await get_tree().create_timer(speed_time).timeout
		else:
			await get_tree().process_frame
			
func init():
	Managment.totally_pause = false
	avaible_workers = people_count
	var build_list = load("res://Builds/buildsList.tres")
	for bett in build_list.betting:
		if bett.free_places > 0:
			free_places.set(bett, bett.free_places)
	for house in build_list.house:
		if house.free_places > 0:
			free_places.set(house, house.free_places)
	
	for i in range(10):
		var data : People = load("res://scripts/bases/people.gd").new()
		data.generate_data("adult")
		people.append(data)
	for i in range(6):
		var data : People = load("res://scripts/bases/people.gd").new()
		data.generate_data("child")
		people.append(data)	
	for i in range(2):
		var data : People = load("res://scripts/bases/people.gd").new()
		data.generate_data("greybeard")
		people.append(data)
			
func add_people(value: int):
	people_count += value
	avaible_workers += value
	Signals.data_changed_ui.emit()
	
func check_connection(form_tile: Vector2i, to_tile: Vector2i) -> bool:
	if transport_connection_astartgrid:
		var path = transport_connection_astartgrid.get_id_path(form_tile, to_tile)
		if len(path) > 0:
			return true
		else:
			return false
	return false
		
func make_transport_map(tile_map_layer: TileMapLayer):	
	var AStar_grid = AStarGrid2D.new()
	AStar_grid.region = Rect2i(0,0,55,32)
	AStar_grid.cell_size = Vector2i(32,32)
	AStar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	AStar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	AStar_grid.update()
	for cell in tile_map_layer.get_used_cells():
		AStar_grid.set_point_solid(cell, !tile_map_layer.get_cell_tile_data(cell).get_custom_data("transport"))
	transport_connection_astartgrid = AStar_grid
