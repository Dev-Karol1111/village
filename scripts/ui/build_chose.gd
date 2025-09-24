extends TextureRect

var data : BuildsBase
var edit_menu 

@onready var button : TextureButton = $TextureButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = data.edit_texture
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_texture_button_pressed() -> void:
	edit_menu.set_block(data.game_texture_tileset_x, data.game_texture_tileset_y)


func _on_resized() -> void:
	if texture:
		var aspect = float(texture.get_width()) / texture.get_height()
		custom_minimum_size = Vector2(size.y * aspect, size.y)
		button.custom_minimum_size = custom_minimum_size
