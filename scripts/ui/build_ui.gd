extends Control

var data : BettingBase
var cords: Vector2i

var actual_workers = 0
var IPD = 11

@onready var build_name : Label = $TextureRect/name
@onready var workers : Label = $TextureRect/workers
@onready var products : Label = $TextureRect/products
@onready var production_time : Label = $TextureRect/ProTime
@onready var items_per_day : Label = $TextureRect/IPD

func _ready() -> void:
	update_data()
	Signals.data_changed_build_info.connect(update_data)
	Signals.edit_menu_opened.connect(func():
		visible = false
	)

func update_data():
	build_name.text = data.name
	actual_workers = Managment.betting[cords].get("workers", 0)
	workers.text = "workers: %s/%s" % [actual_workers, data.need_workers]
	var text = "products:\n"
	for product in data.input_products.keys():
		text += " * %s %s/%s \n" % [product.name, Managment.products[product.name], data.input_products[product]]
	products.text = text
	production_time.text = "production time: %s" % [data.product_time]
	items_per_day.text = "items per day: %s" % [IPD]
