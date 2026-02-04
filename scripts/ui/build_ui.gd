extends Control

## UI panel displaying building information and production status
var building_data: BettingBase
var building_coords: Vector2i

var current_workers: int = 0
const ITEMS_PER_DAY: int = 11

@onready var build_name_label: Label = $TextureRect/name
@onready var workers_label: Label = $TextureRect/workers
@onready var products_label: Label = $TextureRect/products
@onready var production_time_label: Label = $TextureRect/ProTime
@onready var items_per_day_label: Label = $TextureRect/IPD

func _ready() -> void:
	update_display()
	Signals.data_changed_build_info.connect(update_display)
	Signals.edit_menu_opened.connect(func(): visible = false)
	Signals.close_ui.connect(func(): queue_free())

## Updates all UI elements with current building data
func update_display():
	build_name_label.text = building_data.name
	current_workers = Managment.betting[building_coords].get("workers", 0)
	workers_label.text = tr("workers") + ": %s/%s" % [current_workers, building_data.need_workers]
	
	var products_text = tr("products") + ":\n"
	for product in building_data.input_products.keys():
		var product_name = tr(product.name)
		var available = Managment.products.get(product.name, 0)
		var required = building_data.input_products[product]
		products_text += " * %s %s/%s \n" % [product_name, available, required]
	
	products_label.text = products_text
	production_time_label.text = tr("production time") + ": %s" % [building_data.product_time]
	items_per_day_label.text = tr("items per day") + ": %s" % [ITEMS_PER_DAY]
