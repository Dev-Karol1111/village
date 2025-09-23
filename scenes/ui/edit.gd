extends Node

signal change_visible(visible: bool)

@onready var Builds_choos = $"HBoxContainer"

@export var Build_list_resource : BuildsList

var map

func set_block(x : int, y: int):
	var world_node = get_node(map)
	world_node.block = Vector2i(x ,y)


func _ready() -> void:
	#$VBoxContainer/GrassButton.pressed.connect(set_block.bind(1))
	#$VBoxContainer/StoneButton.pressed.connect(set_block.bind(2))
	
	change_visible.connect(change_visible_func)
	
	for build in Build_list_resource.builds:
		if build:
			var tex_rect := TextureRect.new()
			tex_rect.texture = build.edit_texture
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			tex_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
			tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			Builds_choos.add_child(tex_rect)

			tex_rect.resized.connect(func():
				if tex_rect.texture:
					var aspect = float(tex_rect.texture.get_width()) / tex_rect.texture.get_height()
					tex_rect.custom_minimum_size = Vector2(tex_rect.size.y * aspect, tex_rect.size.y)
			)



func change_visible_func(visible):
	for child in self.get_children():
		child.visible = visible


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
