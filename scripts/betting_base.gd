extends BuildsBase

class_name BettingBase

@export var input_products : Dictionary[ProductBase, int] = {}
@export var output_products : Dictionary[ProductBase, int] = {}
@export var product_time: int
@export var need_workers : int

func get_data() -> Array:
	
	var data := []
	
	data.append(type)
	var build_list = load("res://Builds/buildsList.tres")
	data.append(build_list.get(type).find(self))
	

	return data
	