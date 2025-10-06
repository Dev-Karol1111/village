extends Control

var data : BettingBase

var actual_workers = 0
var IPD = 11

@onready var build_name : Label = $TextureRect/name
@onready var workers : Label = $TextureRect/workers
@onready var products : Label = $TextureRect/products
@onready var production_time : Label = $TextureRect/ProTime
@onready var items_per_day : Label = $TextureRect/IPD

func _ready() -> void:
	update_data()

func update_data():
	build_name.text = data.name
	workers.text = "workers: %s/%s" % [data.need_workers, actual_workers]
	var text = "products:\n"
	for product in data.input_products.keys():
		text += " * %s %s/%s \n" % [product.name, Managment.products[product.name], data.input_products[product]]
	products.text = text
	production_time.text = "production time: %s" % [data.product_time]
	items_per_day.text = "items per day: %s" % [IPD]
