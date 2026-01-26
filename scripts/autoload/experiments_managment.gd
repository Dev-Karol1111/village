extends Node

var experiment_progress : Dictionary[ExperimentBase, TimeData]

func _ready() -> void:
	Signals.time_updated.connect(proceed)

func proceed():
	for experiment in Managment.avaible_experiments.keys():
		if Managment.avaible_experiments[experiment].size() < experiment["min_people"]:
			continue
		if ! experiment in experiment_progress:
			experiment_progress.set(experiment, TimeData.new())
		experiment_progress[experiment].add(1)
		if experiment_progress[experiment].to_one_data() >= experiment["time"].to_one_data():
			var build_list = load("res://Builds/buildsList.tres")
			if experiment["result"].type == "betting":
				build_list.betting.append(experiment["result"])
			elif experiment["result"].type == "house":
				build_list.house.append(experiment["result"])
			if experiment["result"].type == "transport":
				build_list.transport.append(experiment["result"])
			if experiment["milstone"]:
				GameEventsManagment.millstones.set(experiment["milstone"], true)
			experiment_progress.erase(experiment)
			Managment.avaible_experiments.erase(experiment)
			var text = "Experiment %s\n has ended" % experiment["name_var"]
			Signals.experiment_finished.emit(experiment["name_var"])
			Signals.add_information.emit("info", "Experiment succeed", text)
