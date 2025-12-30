extends Node

var working_time : Dictionary[People, TimeData]

func _ready() -> void:
	Signals.hour_passed.connect(checking_works)

func working():
	for person in Managment.people:
		if not person.work:
			continue
		
		# Initialize or update working time
		if person not in working_time:
			print("aaaaa")
			working_time[person] = TimeData.new()
			print(working_time[person].to_one_data())
		else:
			print("aaa")
		
		
		working_time[person].add(0, 1, 0)
		
		# Process work completion
		var works = load("res://resources/work_list.tres")
		for work in works.works_list:
			if person.work != work.name_var or work.type == "looking after":
				continue
			
			if working_time[person].to_one_data() >= work.time.to_one_data():
				# Reset working time
				working_time[person].hours = 0
				working_time[person].days = 0
				
				# Update products
				print(work.count)
				var product_name = work.output.name
				Managment.products[product_name] = Managment.products.get(product_name, 0) + work.count
				print(Managment.products)
			# Note: Removed break - consider if you want to process multiple works or just first one			
						
						
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
	Signals.data_changed_ui.emit()
