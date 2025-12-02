extends Resource

class_name BuildsBase

@export var name := "Name"
@export var decription := "Description"
@export var game_texture_tileset_x : int
@export var game_texture_tileset_y : int
@export_enum("1x1", "1x2", "2x1", "2x2") var size : String = "1x1"
@export var edit_texture : Texture2D
@export var products_need_to_build : Dictionary[ProductBase, int] = {}
@export var free_places : int = 0
@export_enum("transport", "house" ,"betting") var type := "Chose type"

func get_data() -> Array:

	var data := []

	data.append(type)
	var build_list = load("res://Builds/buildsList.tres")
	data.append(build_list.get(type).find(self))


	return data
	