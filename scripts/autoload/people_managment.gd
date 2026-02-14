extends Node

var working_time : Dictionary[People, TimeData]

var can_work := true

var available_works: Array[WorkBase]

func _ready() -> void:
	available_works.append_array(load("res://resources/work_list.tres").works_list)
	Signals.hour_passed.connect(checking_works)
	Signals.start_building.connect(start_building)

func working():
	if !can_work:
		return
	for person in Managment.people:
		
		if person.is_sick:
			continue
		
		if person not in working_time:
			working_time[person] = TimeData.new()

		var works = map_works_by_assigned_people()
		var works_sorted_by_name = map_works_by_name()
		
		if not person.work in works_sorted_by_name:
			continue
		
		if works[works_sorted_by_name[person.work]] >= works_sorted_by_name[person.work].minimal_people:
			working_time[person].add(1, 0, 0)
		
		for work in available_works:
			if person.work != work.name_var or work.type == "looking after":
				continue
			
			if working_time[person].to_one_data() >= work.time.to_one_data():
				working_time[person].hours = 0
				working_time[person].days = 0
				
				if work.type == "collecting":
					var product_name = work.output.name
					Managment.products[product_name] = Managment.products.get(product_name, 0) + work.count
					print(Managment.products)
				elif work.type == "building":
					Signals.building_ended.emit(work.build_data)
					for p in Managment.people:
						if p.work == work.name_var:
							p.work = ""
					available_works.erase(work)
				elif work.type == "special":
					check_special_work(work)

func check_special_work(work : WorkBase):
	if work.name_var == "treatment":
		for p in Managment.people:
			p.is_sick = false

func map_works_by_assigned_people() -> Dictionary:
	var works : Dictionary[String, int]= {}
	var end_works : Dictionary[WorkBase, int] = {}
	for person in Managment.people:
		if person.work:
			works.set(person.work, works.get(person.work, 0) + 1)
	
	for work in available_works:
		for assigned_work in works.keys():
			if work.name_var == assigned_work:
				end_works.set(work, works[assigned_work])
	
	return end_works

func map_works_by_name() -> Dictionary:
	var works: Dictionary[String, WorkBase]
	
	for work in available_works:
		works.set(work.name_var, work)
	
	return works

func checking_works():
	var work_to_check: Array
	var took_damage := false
	for work in available_works:
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
						took_damage = true
	
	if took_damage:
		Signals.add_information.emit("warning", tr("caring"), tr("not enough care"))
	
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
			Signals.add_information.emit("warning", tr("hut"), tr("greybeard hut warning"))
	Signals.data_changed_ui.emit()

func kill_person(person_name : String = ""):
	if person_name:
		for person in Managment.people:
			if person.name == person_name:
				print(person.name)
				Managment.people.erase(person)

func start_building(building_data: BuildsBase):
	var work_data = load("res://scripts/bases/work_base.gd").new()
	work_data.name_var = "build %s" % building_data.name
	work_data.time = building_data.building_time
	work_data.type = "building"
	work_data.build_data = building_data
	work_data.minimal_people = building_data.min_workers_to_build
	available_works.append(work_data)
