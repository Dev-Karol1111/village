extends Node

var data : Array
var active : Array

var emitted : Array

func _ready() -> void:
	data = preload("res://resources/toturial_timeline.tres").toturial_data
	Signals.experiment_finished.connect(experiment_check)
	Signals.experiment_unlocked.connect(experiment_check)

func check_data():
	while true:
		if Managment.totally_pause:
			await get_tree().create_timer(2).timeout
		for tot in data:
			var first = (not tot.time_from and data[0] == tot and not tot.cannot_be_first)
			if first or (tot.time_from and tot.time_from.to_one_data() <= TimeManagment.time.to_one_data()):
				if tot in emitted:
					continue
				if tot.special_type:
					if tot.special_type == "pause":
						Signals.add_information.emit("toturial",tot.title, tot.message, 0)
						active.append(tot)
					elif tot.special_type == "unpause":
						Signals.add_information.emit("toturial",tot.title, tot.message, 0)
						active.append(tot)
					emitted.append(tot)
				else:
					if !first:
						Signals.add_information.emit("toturial",tot.title, tot.message, tot.time_from.to_one_data() - tot.time_to.time_to_one_data())
					else:
						Signals.add_information.emit("toturial",tot.title, tot.message, 0, true)
					data.erase(tot)
		
		for ac in active:
			if ac.special_type == "pause":
				if Managment.speed_time == 0:
					Signals.remove_information.emit(ac.title, ac.message)
					data.erase(ac)
			if ac.special_type == "unpause":
				if Managment.speed_time != 0:
					Signals.remove_information.emit(ac.title, ac.message)
					data.erase(ac)
		
		await get_tree().create_timer(2).timeout

func delete(title, messaeg):
	for tot_te in data:
		if tot_te.title == title and tot_te.message == messaeg:
			data.erase(tot_te)
			return

func experiment_check(experiment_name : String):
	for tot in data:
		if tot.after_unlocked_experiment == experiment_name:
			if tot in emitted:
				continue
			var first = (not tot.time_from and data[0] == tot and not tot.cannot_be_first)
			if tot.special_type:
				if tot.special_type == "pause":
					Signals.add_information.emit("toturial",tot.title, tot.message, 0)
					active.append(tot)
				elif tot.special_type == "unpause":
					Signals.add_information.emit("toturial",tot.title, tot.message, 0)
					active.append(tot)
					emitted.append(tot)
			else:
				Signals.add_information.emit("toturial",tot.title, tot.message, 0, true)
				data.erase(tot)
				
