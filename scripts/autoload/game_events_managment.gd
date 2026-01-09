extends Node

func _ready() -> void:
	Signals.time_updated.connect(check_events)

func check_events():
	var avaible_events = load("res://resources/unlocking_timeline.tres")
	
	
	for event in avaible_events.unlock:
		if event.time.to_one_data() < TimeManagment.time.to_one_data():
			continue
		if event.time.to_one_data() > TimeManagment.time.to_one_data():
			continue
		if event.time.to_one_data() == TimeManagment.time.to_one_data():
			special_events(event.name)
			var text
			text = event.message_text
			if event.unlocked_builds:
				load("res://Builds/buildsList.tres").betting.append_array(event.unlocked_builds)
				text += "\nSome building was unlocked"
			if event.unlocked_works:
				for work in event.unlocked_works:
					load("res://scripts/bases/work_list.gd").works_list.append_array(event.unlocked_works)
				text += "\nSome works was unlocked"

			if event.unlocked_experiments:
				for experiment in event.unlocked_experiments: 
					Managment.avaible_experiments.set(experiment, [])
				text += "\nSome experiments was unlocked"

			Signals.add_information.emit("info", event.message_title, text)
			
			# TODO: Add addig works, experiments, buildings 

func special_events(event_name : String):
	if event_name == "wolf attack":	
		Signals.add_information.emit("error", "DEAD", "Wolf has attacked your\n village and one people died")
		
