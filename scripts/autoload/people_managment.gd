extends Node

var working_time : Dictionary[People, int]

func _ready() -> void:
	Signals.hour_passed.connect(checking_works)

func working():
	for people in Managment.people:
		if people.work:
			if people in working_time:
				working_time[people] += 1
			else:
				working_time[people] = 1
			
			for work in Managment.avaible_works:
				if people.work == work["name"] and !work.get("minimal people"):
					if working_time[people] >= work["time"]:	
						working_time[people] = 0
						Managment.products.set(work.get("output", ""), Managment.products.get(work.get("output", ""), 0) + work["count"])
						print(Managment.products)
					else:
						break			
						
						
func checking_works():
	var work_to_check : Array
	for work in Managment.avaible_works:
		if work.get("minimal people", 0):
			work_to_check.append(work)
			var workers_count := 0
			for person in Managment.people:
				if person.work == work["name"]:
					workers_count += 1
			if workers_count < work["minimal people"]:
				for person in Managment.people:
					if person.type == work["looking after"]:
						person.healt -= work["taking damage"]
	Signals.data_changed_ui.emit()