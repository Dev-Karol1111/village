extends Node

var working_time : Dictionary[People, TimeData]

func _ready() -> void:
	Signals.hour_passed.connect(checking_works)

func working():
	for people in Managment.people:
		if people.work:
			if people in working_time:
				working_time[people].add(0,1,0)
			else:
				working_time[people] = TimeData.new()
				working_time[people].add(0,1,0)
			
			var works = load("res://resources/work_list.tres")
			
			for work in works.works_list:
				if people.work == work.name_var and !work.type == "looking after":
					if working_time[people].to_one_data() >= work.time.to_one_data():	
						working_time[people].hours = 0
						working_time[people].days = 0
						print(work.count)
						Managment.products.set(work.output.name, Managment.products.get(work.output.name, 0) + work.count)
						print(Managment.products)
					else:
						break			
						
						
func checking_works():
	var work_to_check : Array
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
	Signals.data_changed_ui.emit()
