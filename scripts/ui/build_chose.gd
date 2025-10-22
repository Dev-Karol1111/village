extends TextureRect

var data : BuildsBase
var edit_menu 

@onready var button : TextureButton = $TextureButton

@onready var info_box : TextureRect = $info
@onready var products_label : Label = $"info/products"
@onready var free_places_label : Label = $"info/free_places"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = data.edit_texture
	info_box.visible = false
	update_data()
	Signals.data_changed_build_info.connect(update_data)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func update_data():
	var products_text := "Products: \n"
	for need_product in data.products_need_to_build.keys():
		var value
		if Managment.products.has(need_product.name):
			value = Managment.products[need_product.name]
		else:
			value = 0
		products_text += " * %s %s/%s \n" % [need_product.name, value, data.products_need_to_build[need_product]]
		
	products_label.text = products_text
	if Managment.free_places.has(data):
		free_places_label.text = "Free places: %s" % Managment.free_places[data]
	else:
		free_places_label.text = "Free places: 0"

func _on_texture_button_pressed() -> void:
	edit_menu.set_block(data)


func _on_resized() -> void:
	if texture:
		var aspect = float(texture.get_width()) / texture.get_height()
		custom_minimum_size = Vector2(size.y * aspect, size.y)
		button.custom_minimum_size = custom_minimum_size
		
	
func _on_texture_button_mouse_entered() -> void:
	info_box.visible = true


func _on_texture_button_mouse_exited() -> void:
	info_box.visible = false
	
