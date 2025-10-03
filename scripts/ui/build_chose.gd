extends TextureRect

var data : BuildsBase
var edit_menu 

@onready var price_label : Label = $Label
@onready var button : TextureButton = $TextureButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = data.edit_texture
	price_label.text = "$ %s" % data.price
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_texture_button_pressed() -> void:
	edit_menu.set_block(data.game_texture_tileset_x, data.game_texture_tileset_y, 0 ,data.price, load("res://Builds/buildsList.tres").builds.find(data))


func _on_resized() -> void:
	if texture:
		var aspect = float(texture.get_width()) / texture.get_height()
		custom_minimum_size = Vector2(size.y * aspect, size.y)
		button.custom_minimum_size = custom_minimum_size
