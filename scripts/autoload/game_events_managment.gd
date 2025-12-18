extends Node

func _ready() -> void:
	Signals.time_updated.connect(check_events)

func check_events():
	var avaible_events = load("res://resources/unlocking_timeline.tres")
	
	
	for event in avaible_events.unlock:
		if event.time.to_one_data() < TimeManagment.time.to_one_data():
			continue
		if event.time.to_one_data() > TimeManagment.time.to_one_data():
			break
		if event.time.to_one_data() == TimeManagment.time.to_one_data():
			special_events(event.name)
			# TODO: Add addig works, experiments, buildings 

func special_events(event_name : String):
	if event_name == "wolf attack":	
		Signals.add_information.emit("error", "DEAD", "Wolf has attacked your\n village and one people died")
		