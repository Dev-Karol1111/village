extends Node

var millstones : Dictionary[String, bool] = {}

func _ready() -> void:
	Signals.time_updated.connect(check_events)

func check_events():
	var available_events = load("res://resources/unlocking_timeline.tres")
	
	for event in available_events.unlock:
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
				text += "\n" + tr("building unlocked")
			if event.unlocked_works:
				for work in event.unlocked_works:
					PeopleManagment.available_works.append_array(event.unlocked_works)
				text += "\n" + tr("works unlocked")

			if event.unlocked_experiments:
				var experiment_name
				for experiment in event.unlocked_experiments:
					Managment.available_experiments.set(experiment, [])
					experiment_name = experiment["name_var"]
				text += "\n" + tr("experiments unlocked")
				Signals.experiment_unlocked.emit(experiment_name)
				
			
			if event.millstone:
				millstones.set(event.millstone, true)

			Signals.add_information.emit("info", event.message_title, text)
			
func special_events(event_name : String):
	if event_name == "wolf attack":	
		Signals.add_information.emit("error", tr("wolf attack"), tr("wolf attack message"))
		PeopleManagment.kill_person(random_person("adult").name)
	elif event_name == "sickness":
		Signals.add_information.emit("error", tr("sickness"), tr("one adult is sick"))
		random_person("adult").is_sick = true
	elif event_name == "young chosen":
		var max_age : People
		for p in Managment.people:
			if p.type == "child":
				if !max_age:
					max_age = p
				else:
					if p.age > max_age.age:
						max_age = p
		
		Managment.chosen_child = max_age
		
func random_person(person_type := "") -> People:
	var randoming = true
	for p in Managment.people:
		var person = Managment.people.pick_random()
		if person.type == person_type:
			return person
	
	return
