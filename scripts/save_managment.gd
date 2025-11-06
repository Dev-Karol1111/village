extends Node

var path_to_save = "user://save.json"

func load(tilemap: TileMapLayer):
	if not FileAccess.file_exists(path_to_save):
		push_warning("WARNING: File not fund")
		return

	var file = FileAccess.open(path_to_save, FileAccess.READ)

	var map_size = file.get_32()
	var map_bytes = file.get_buffer(map_size)
	tilemap.set_tile_map_data_from_array(map_bytes)
	
	var json_text = ""
	while not file.eof_reached():
		json_text += file.get_line()
	file.close()

	var info = JSON.parse_string(json_text)
	if info != null:
		Managment.moneys = info.get("money", 0)
		Managment.people = info.get("people", 0)
		if info.has("bettings_builds"):
			Managment.betting.clear()
			print(info["bettings_builds"])
			for build_data in info["bettings_builds"]:
				Managment.betting.set(Vector2i(build_data["x"], build_data["y"]), {"data" : load("res://Builds/buildsList.tres").betting[int(build_data["data"][1])]})
		if info.has("free_places"):
			Managment.free_places.clear()
			for free_place in info["free_places"]:
				Managment.free_places.set(load("res://Builds/buildsList.tres").get(free_place["data"][0])[int(free_place["data"][1])], int(free_place["value"]))
		
		if info.has("products"):
			Managment.products.clear()
			for product in info["products"]:
				Managment.products.set(product, int(info["products"][product]))
		
		if info.has("houses"):
			Managment.houses.clear()
			for house in info["houses"]:
				Managment.houses.set(Vector2i(house.x, house.y), {"people" : int(house.living_people), "workers" : int(house.living_people)})
			Managment.make_transport_map(tilemap)
			Managment.was_edit_menu_opened = true
	Signals.data_changed_ui.emit()				

func save(tilemap: TileMapLayer):
	var file = FileAccess.open(path_to_save, FileAccess.WRITE)

	var map_data: PackedByteArray = tilemap.get_tile_map_data_as_array()
	file.store_32(map_data.size())
	file.store_buffer(map_data)

	file.store_string("\n")

	var info := {
				   "money": Managment.moneys,
				   "people": Managment.people, 
				   "bettings_builds": [],
				   "free_places" : [],
				   "products" : Managment.products,
				   "houses" : [],
			   }

	for b in Managment.betting:
		info["bettings_builds"].append({"x" : b.x, "y" : b.y, "data" : Managment.betting[b]["data"].get_data()})	
	
	for f in Managment.free_places:
		info["free_places"].append({"data" : f.get_data(), "value" : Managment.free_places[f]})
	
	for h in Managment.houses:
		info["houses"].append({"x" : h.x, "y" : h.y, "living_people" : Managment.houses[h]["people"]})
	file.store_string(JSON.stringify(info))
	file.close()
