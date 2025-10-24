extends Node

signal change_visible(visible: bool)

@onready var Builds_choos = $"HBoxContainer"

@export var Build_list_resource : BuildsList

var map : Node

func set_block(block_data: BuildsBase):
	map.block = [block_data.type, load("res://Builds/buildsList.tres").get(block_data.type).find(block_data)]


func _ready() -> void:
	change_visible.connect(change_visible_func)
	
	render_build_select()	

func render_build_select():
	var data = [Build_list_resource.transport, Build_list_resource.house, Build_list_resource.betting]
	var build_index := 100
	for current_array in data:
		for build in current_array:
			if build:
				var tex_rect = load("res://scenes/ui/build_chose.tscn").instantiate()
				tex_rect.texture = build.edit_texture
				tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
				tex_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
				tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
				tex_rect.data = build
				tex_rect.edit_menu = self
				tex_rect.z_index = build_index
				Builds_choos.add_child(tex_rect)
				build_index -= 1
func change_visible_func(visible):
	for child in self.get_children():
		child.visible = visible


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
