extends Node

var path_to_save = "user://save.json"

func load(tilemap: TileMapLayer):
	if not FileAccess.file_exists(path_to_save):
		#push_warning("WARNING: File not fund")
		save(tilemap)

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
		Managment.money = info.get("money", 0)
		Managment.people_count = info.get("people_count", 0)
		if info.has("bettings_builds"):
			Managment.betting.clear()
			for build_data in info["bettings_builds"]:
				Managment.betting.set(Vector2i(build_data["x"], build_data["y"]), {"data" : load("res://resources/buildings_index.tres").idexes[int(build_data["data"][1])]})
		if info.has("free_places"):
			Managment.free_places.clear()
			for free_place in info["free_places"]:
				Managment.free_places.set(load("res://resources/buildings_index.tres").indexes[free_place["data"]], int(free_place["value"]))
		
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
		
		if info.has("people"):
			Managment.people.clear()
			for p in info["people"]:
				var new_pepople := People.new()
				new_pepople.generate_data(p["type"], p["name"], p["age"], p["gender"])
				new_pepople.healt = p["health"]
				Managment.people.append(new_pepople)
		
		if info.has("experiments"):
			Managment.available_experiments.clear()
			print(Managment.available_experiments)
			for e in info["experiments"].keys():
				var ep_data = ExperimentBase.new()
				var plist = []
				var e_dict = JSON.parse_string(e)
				ep_data.set_data_from_dictionary(e_dict)
				for p in info["experiments"][e]:
					var pdata = People.new()
					pdata.generate_data(p["type"], p["name"],p["age"], p["gender"])
					plist.append(pdata)
				Managment.available_experiments.set(ep_data, plist)
			print(Managment.available_experiments)
		if info.has("experiment_progress"):
			ExperimentsManagment.experiment_progress.clear()
			for ep in info["experiment_progress"].keys():
				var ep_dist = JSON.parse_string(ep)
				var ep_data = ExperimentBase.new()
				ep_data.set_data_from_dictionary(ep_dist)
				print(ep_data.name_var, int(info["experiment_progress"][ep]))
				var time_data = TimeData.new()
				time_data.add(int(info["experiment_progress"][ep]))
				ExperimentsManagment.experiment_progress.set(ep_data, time_data)
				print(ExperimentsManagment.experiment_progress)
		
		if info.has("avaible_works"):
			PeopleManagment.available_works.clear()
			for aw in info["avaible_works"]:
				var new_work = WorkBase.new()
				new_work.set_data_from_dictionary(aw)
				PeopleManagment.available_works.append(new_work)
		
		if info.has("working_time"):
			PeopleManagment.working_time.clear()
			for wt in info["working_time"].keys():
				var np = People.new()
				var wt_dict = JSON.parse_string(wt)
				np.generate_data(wt_dict["type"], wt_dict["name"], wt_dict["age"], wt_dict["gender"])
				np.healt = wt_dict["health"]
				var tmd = TimeData.new()
				tmd.add(int(info["working_time"][wt]))
				PeopleManagment.working_time.set(np, tmd)
		
		if info.has("avaible_building"):
			var BuildList = load("res://Builds/buildsList.tres")
			var BuildIndex = load("res://resources/buildings_index.tres").indexes
			BuildList.betting.clear()
			BuildList.house.clear()
			BuildList.transport.clear()
			for ab in info["avaible_building"].keys():
				if "betting" in ab:
					BuildList.betting.append(BuildIndex[info["avaible_building"][ab]])
				elif "house" in ab:
					BuildList.house.append(BuildIndex[info["avaible_building"][ab]])
				elif "transport" in ab:
					BuildList.transport.append(BuildIndex[info["avaible_building"][ab]])
	Signals.data_changed_ui.emit()				

func save(tilemap: TileMapLayer):
	var file = FileAccess.open(path_to_save, FileAccess.WRITE)

	var map_data: PackedByteArray = tilemap.get_tile_map_data_as_array()
	file.store_32(map_data.size())
	file.store_buffer(map_data)

	file.store_string("\n")

	var info := {
		"money": Managment.money,
		"people_count": Managment.people_count, 
		"bettings_builds": [],
		"free_places" : [],
		"products" : Managment.products,
		"houses" : [],
		"people" : [],
		"experiments" : {},
		"experiment_progress" : {},
		"millstones" : GameEventsManagment.millstones,
		"can_work" : PeopleManagment.can_work,
		"avaible_works" : [],
		"working_time" : {},
		"time" : TimeManagment.time.to_one_data(),
		"toturial_active" : ToturialManagement.active_ids,
		"toturial_emmited" : ToturialManagement.emitted_ids,
		"avaible_building" : {}
	}

	for b in Managment.betting:
		info["bettings_builds"].append({"x" : b.x, "y" : b.y, "data" : Managment.betting[b]["data"].get_data()})	
	
	for f in Managment.free_places:
		info["free_places"].append({"data" : f.get_data(), "value" : Managment.free_places[f]})
	
	for h in Managment.houses:
		info["houses"].append({"x" : h.x, "y" : h.y, "living_people" : Managment.houses[h]["people"]})
	
	for p in Managment.people:
		info["people"].append(p.get_data_in_dictionary())
	
	for e in Managment.available_experiments.keys():
		var plist = []
		for p in Managment.available_experiments[e]:
			plist.append(p.get_data_in_dictionary())
		
		info["experiments"].set(e.get_data_in_dictionary(), plist)
	
	for ep in ExperimentsManagment.experiment_progress.keys():
		info["experiment_progress"].set(ep.get_data_in_dictionary(), ExperimentsManagment.experiment_progress[ep].to_one_data())
	
	for w in PeopleManagment.available_works:
		info["avaible_works"].append(w.get_data_in_dictionary())
		
	for wt in PeopleManagment.working_time.keys():
		info["working_time"].set(wt.get_data_in_dictionary(), PeopleManagment.working_time[wt].to_one_data())
		
		
	var ab_ti = {}
	for ab in load("res://Builds/buildsList.tres").betting:
		ab_ti.set("betting %s" % ab.get_data(), ab.get_data())
	for ab in load("res://Builds/buildsList.tres").house:
		ab_ti.set("house %s" % ab.get_data(), ab.get_data())
	for ab in load("res://Builds/buildsList.tres").transport:
		ab_ti.set("transport %s" % ab.get_data(), ab.get_data())
	
	info["avaible_building"] = ab_ti
	
	file.store_string(JSON.stringify(info))
	file.close()


func clear():
	if FileAccess.file_exists(path_to_save):
		DirAccess.remove_absolute(path_to_save)
