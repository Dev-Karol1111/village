extends Node

signal change_visible(visible: bool)

@onready var Builds_choos = $"HBoxContainer"

@export var Build_list_resource : BuildsList

var map : Node

func set_block(x : int, y: int, source := 0, price := 0, build_index := 0):
	map.block = [Vector2i(x ,y), source, price, build_index]


func _ready() -> void:
	change_visible.connect(change_visible_func)
	
	render_build_select()	

func render_build_select():
	for build in Build_list_resource.builds:
		if build:
			var tex_rect = load("res://scenes/ui/build_chose.tscn").instantiate()
			tex_rect.texture = build.edit_texture
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			tex_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
			tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			tex_rect.data = build
			tex_rect.edit_menu = self
			Builds_choos.add_child(tex_rect)
func change_visible_func(visible):
	for child in self.get_children():
		child.visible = visible


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
