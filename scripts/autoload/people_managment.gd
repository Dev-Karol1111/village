extends Node

var working_time : Dictionary[People, TimeData]

var can_work := true

func _ready() -> void:
	Signals.hour_passed.connect(checking_works)

func working():
	if !can_work:
		return
	for person in Managment.people:
		if not person.work:
			continue
		
		if person not in working_time:
			working_time[person] = TimeData.new()
			print(working_time[person].to_one_data())

		
		working_time[person].add(1, 0, 0)
		
		var works = load("res://resources/work_list.tres")
		for work in works.works_list:
			if person.work != work.name_var or work.type == "looking after":
				continue
			
			if working_time[person].to_one_data() >= work.time.to_one_data():
				working_time[person].hours = 0
				working_time[person].days = 0
				
				print(work.count)
				var product_name = work.output.name
				Managment.products[product_name] = Managment.products.get(product_name, 0) + work.count
				print(Managment.products)
						
						
func checking_works():
	var work_to_check : Array
	var taked_damage := false
	for work in load("res://resources/work_list.tres").works_list:
		if work.type == "looking after":
			work_to_check.append(work)
			var workers_count := 0
			for person in Managment.people:
				if person.work == work.name_var:
					workers_count += 1
			if workers_count < work.minimal_people:
				for person in Managment.people:
					if person.type == work.target_group:
						person.healt -= work.taking_damage
						taked_damage = true
	
	if taked_damage:
		Signals.add_information.emit("warning", "Careing", "Not enough people care\nabout other.")
	
	# SECTION - Hut
	if GameEventsManagment.millstones.get("hut", false):
		var are_all_greybeard_in_hut := true
		
		for person in Managment.people:
			if person.type == "greybeard":
				if !Managment.houses.values():
					are_all_greybeard_in_hut = false
					break
				for house in Managment.houses.values():
					if !person in house["data"].liveing_people:
						are_all_greybeard_in_hut = false
		if !are_all_greybeard_in_hut:
			Signals.add_information.emit("warning", "HUT", "Greybeard should be\nassing to hut")
	Signals.data_changed_ui.emit()

func kill_person(person_name : String = ""):
	if person_name:
		for person in Managment.people:
			if person.name == person_name:
				Managment.people.erase(person)