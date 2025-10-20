extends Node

var moneys := 500
var people := 200

var mode := "normal"

var betting : Array[BettingBase] = []
var production_time : Array[int] = []

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
			while len(betting) >= len(production_time):
				production_time.append(0)
			for bett in betting:
				var i := betting.find(bett)
				production_time[i] += 1

				if production_time[i] >= bett.product_time:
					production_time[i] = 0

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
	var build_list = load("res://Builds/buildsList.tres")
	for bett in build_list.betting:
		if bett.free_places > 0:
			free_places.set(bett, bett.free_places)