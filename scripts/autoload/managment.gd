extends Node

var moneys := 500
var people := 50

var avaible_workers : int
var working_places : Dictionary[Vector2i, int] =  {}

var mode := "normal"

var betting : Dictionary[Vector2i, BettingBase] = {}
var production_time : Dictionary[Vector2i, int] = {}

var products : Dictionary[String, int] = {"flour" : 100}

var speed_time := 1

var free_places : Dictionary[BuildsBase, int]

@onready var running := true

func _ready() -> void:
	init()
	production_loop()

func production_loop() -> void:
	while running:
		if speed_time > 0:
			for _betting in betting:
				var bett = betting[_betting]
				if working_places.has(_betting):
					if working_places[_betting] == bett.need_workers:
						pass
					else:
						if working_places[_betting] > 0:
							avaible_workers += working_places[_betting]
							if (working_places[_betting] - bett.need_workers) > 0:
								working_places.set(bett, bett.need_workers)
								avaible_workers -= bett.need_workers
							else:
								working_places.set(bett, avaible_workers)
								avaible_workers = 0		
				else:
					if (avaible_workers - bett.need_workers) > 0:
						working_places.set(_betting, bett.need_workers)
						avaible_workers -= bett.need_workers
					else:
						working_places.set(_betting, avaible_workers)
						avaible_workers = 0
				
				if working_places[_betting] != bett.need_workers:
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
			await get_tree().create_timer(speed_time).timeout
		else:
			await get_tree().process_frame
			
func init():
	avaible_workers = people
	var build_list = load("res://Builds/buildsList.tres")
	for bett in build_list.betting:
		if bett.free_places > 0:
			free_places.set(bett, bett.free_places)