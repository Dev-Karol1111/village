extends Node

var road_list : Array = [Vector2i(1,0), Vector2i(0,3),Vector2i(1,3), Vector2i(2,3)]

func check_workers():
	for workplace_coords in Managment.betting:
		var workplace_data = Managment.betting[workplace_coords]
		if workplace_data.get("gotta_update", false):
			# Process all workers first
			for house_coords in workplace_data.get("workers_from", []):
				Managment.houses[house_coords]["workers"] += workplace_data["workers_from"][house_coords]

			# Then clear everything
			workplace_data.set("workers_from", {})
			workplace_data.set("connected_houses", [])
			workplace_data["workers"] = 0
			workplace_data["gotta_update"] = false
		else:
			return
	
	determine_betting_house_connection()
	
	for workplace_coords in Managment.betting:
		allocate_workers(workplace_coords)
	
	
			
func allocate_workers(workplace_coords: Vector2i):
	var workplace_data = Managment.betting[workplace_coords]["data"]
	
	if not Managment.betting[workplace_coords].has("workers"):
		Managment.betting[workplace_coords].set("workers", 0)

	# Check if workplace is already fully staffed
	if Managment.betting[workplace_coords].get("workers", 0) == workplace_data.need_workers:
		return
	
	# Calculate how many more workers are needed
	var need_workers: int = workplace_data.need_workers - Managment.betting[workplace_coords].get("workers", 0)
	
	# Initialize workers_from if it doesn't exist
	if not Managment.betting[workplace_coords].has("workers_from"):
		Managment.betting[workplace_coords]["workers_from"] = {}

	# Allocate workers from connected houses
	for house_coords in Managment.betting[workplace_coords].get("connected_houses", []):
		if need_workers == 0:
			return

		var available_workers = Managment.houses[house_coords]["workers"]
		var workers_to_allocate = min(need_workers, available_workers)

		Managment.betting[workplace_coords]["workers"] += workers_to_allocate
		Managment.houses[house_coords]["workers"] -= workers_to_allocate
		need_workers -= workers_to_allocate

		# Track how many workers are from this house
		if workers_to_allocate > 0:
			if not Managment.betting[workplace_coords]["workers_from"].has(house_coords):
				Managment.betting[workplace_coords]["workers_from"][house_coords] = 0
			Managment.betting[workplace_coords]["workers_from"][house_coords] += workers_to_allocate

func determine_betting_house_connection():
	for workplace_coords in Managment.betting:
		var roads_surrounding_workplace: Array = []
		var connected_houses: Array = []

		# Get roads adjacent to workplace
		var directions = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0)]
		for dir in directions:
			if Managment.tilemap.get_cell_atlas_coords(workplace_coords + dir) in road_list:
				roads_surrounding_workplace.append(workplace_coords + dir)

		# Check each house for connection
		for house_coords in Managment.houses:
			var roads_surrounding_house: Array = []

			# Get roads adjacent to this house
			for dir in directions:
				if Managment.tilemap.get_cell_atlas_coords(house_coords + dir) in road_list:
					roads_surrounding_house.append(house_coords + dir)

			# Check if any roads connect
			for road_workplace in roads_surrounding_workplace:
				for road_house in roads_surrounding_house:
					if Managment.check_connection(road_workplace, road_house):
						connected_houses.append(house_coords)
						break  # Stop checking once connected
				if connected_houses.size() > 0 and connected_houses[-1] == house_coords:
					break  # Move to next house

		# Update workplace data
		var workplace_dict = Managment.betting[workplace_coords].duplicate()
		workplace_dict["connected_houses"] = connected_houses
		Managment.betting[workplace_coords] = workplace_dict
	
