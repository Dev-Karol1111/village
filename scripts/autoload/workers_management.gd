extends Node

var road_list : Array = [Vector2i(1,0), Vector2i(0,3),Vector2i(1,3), Vector2i(2,3)]

func check_workers(bett_vector: Vector2i):
	var bett = Managment.betting[bett_vector]["data"]

	# Initialize workplace if it doesn't exist
	if !Managment.working_places.has(bett_vector):
		Managment.working_places[bett_vector] = 0

	# Check if workplace is already fully staffed
	if Managment.working_places[bett_vector] == bett.need_workers:
		return
	
	determine_betting_house_connetion()		

	# Calculate how many more workers are needed
	var need_workers: int = bett.need_workers - Managment.working_places[bett_vector]

	# Initialize workers_from if it doesn't exist
	if !Managment.betting[bett_vector].has("workers_from"):
		Managment.betting[bett_vector]["workers_from"] = {}

	# Allocate workers from connected houses
	for house in Managment.betting[bett_vector].get("connected_houses", []):
		if need_workers == 0:
			return

		var available_workers = Managment.houses[house]
		var workers_to_allocate = min(need_workers, available_workers)

		Managment.working_places[bett_vector] += workers_to_allocate
		Managment.houses[house] -= workers_to_allocate
		need_workers -= workers_to_allocate

		# Track how many workers are from this house
		if !Managment.betting[bett_vector]["workers_from"].has(house):
			Managment.betting[bett_vector]["workers_from"][house] = 0
		Managment.betting[bett_vector]["workers_from"][house] += workers_to_allocate
		
func determine_betting_house_connetion():
	for bett in Managment.betting:
		var roads_surrounding_betting: Array = []
		var connected_houses: Array = []

		# Get roads adjacent to betting house
		var directions = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0)]
		for dir in directions:
			if Managment.tilemap.get_cell_atlas_coords(bett + dir) in road_list:
				roads_surrounding_betting.append(bett + dir)

		# Check each house for connection
		for house in Managment.houses:
			var roads_surrounding_house: Array = []

			# Get roads adjacent to this house
			for dir in directions:
				if Managment.tilemap.get_cell_atlas_coords(house + dir) in road_list:
					roads_surrounding_house.append(house + dir)

			# Check if any roads connect
			for road_bett in roads_surrounding_betting:
				for road_house in roads_surrounding_house:
					if Managment.check_connection(road_bett, road_house):
						connected_houses.append(house)
						break  # Stop checking once connected
				if connected_houses.size() > 0 and connected_houses[-1] == house:
					break  # Move to next house

		# Update betting house data
		var bett_data = Managment.betting[bett].duplicate()
		bett_data["connected_houses"] = connected_houses
	
		Managment.betting[bett] = bett_data
	print(Managment.betting)
