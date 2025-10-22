extends Resource

class_name BuildsBase

@export var name := "Name"
@export var decription := "Description"
@export var game_texture_tileset_x : int
@export var game_texture_tileset_y : int
@export var edit_texture : Texture2D
@export var products_need_to_build : Dictionary[ProductBase, int] = {}
@export var free_places : int = 0
@export_enum("transport", "build" ,"betting") var type := "Chose type"