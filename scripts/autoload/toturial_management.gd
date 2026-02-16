extends Node

var data : Array # toturial data

var active_ids : Array[String] = []
var emitted_ids : Array[String] = []

var tutorial_titles := {
	"TIME": "tutorial.time",
	"WORKS": "tutorial.works",
	"UNPAUSE": "tutorial.unpause",
	"WAIT": "tutorial.wait",
	"CAMPFIRE": "tutorial.campfire",
	"UNLOCKED": "tutorial.unlocked",
	"BUILDING": "tutorial.building",
	"HUT": "tutorial.hut.build",
	"GREYBEARD": "tutorial.greybeard"
}

var tutorial_messages := {
	"First stop time": "tutorial.time.message",
	"assing to works": "tutorial.works.message",
	"Unpause the game": "tutorial.unpause.message",
	"Wait until experiment finish": "tutorial.wait.message",
	"Experimenting with campfire finished.\nBuild your first campfire.": "tutorial.campfire.message",
	"Hut was unlocked.\nAssingone people to this experiment.": "tutorial.unlocked.message",
	"Experiments with hut has ended. \nNow you can place it.": "tutorial.building.message",
	"Build your first hut.\nAssingone  1 person into this work": "tutorial.hut.build.message",
	"Check it when hut is finished": "tutorial.hut.check.message",
	"Assing greybeard into hut unless you want\nto lose them ...": "tutorial.greybeard.message",
	"People are suffering from water shortage\nstart the experiment" : "tutorial.water.experiment",
	"drought people drink 2x water": "tutorial.water.drought",
	"build minimum 2 rain catchers" : "tutorial.water.build"
}

func _get_translated_title(title: String) -> String:
	if title in tutorial_titles:
		return tr(tutorial_titles[title])
	return title

func _get_translated_message(message: String) -> String:
	for key in tutorial_messages:
		if key.to_lower() in message.to_lower():
			return tr(tutorial_messages[key])
	return message

func _ready() -> void:
	data = preload("res://resources/toturial_timeline.tres").toturial_data
	Signals.experiment_finished.connect(experiment_check)
	Signals.experiment_unlocked.connect(experiment_check)
	check_data()

func get_tutorial_by_id(id : String):
	for t in data:
		if t.id == id:
			return t
	return null

func check_data():
	while true:
		if Managment.totally_pause:
			await get_tree().create_timer(2).timeout
			continue
		for tot in data:
			if tot.id in emitted_ids:
				continue

			var first = (not tot.time_from and data[0] == tot and not tot.cannot_be_first)
			
				
			if first or (tot.time_from and tot.time_from.to_one_data() <= TimeManagment.time.to_one_data()):
				if tot.special_type:
					Signals.add_information.emit(
						"toturial",
						_get_translated_title(tot.title),
						_get_translated_message(tot.message),
						0
					)
					active_ids.append(tot.id)
					emitted_ids.append(tot.id)
				else:
					var time := 0
					if not first:
						time = tot.time_to.to_one_data() - tot.time_from.to_one_data()

					Signals.add_information.emit(
						"toturial",
						_get_translated_title(tot.title),
						_get_translated_message(tot.message),
						time,
						first
					)
					emitted_ids.append(tot.id)

		for id in active_ids.duplicate():
			var ac = get_tutorial_by_id(id)
			if ac == null:
				active_ids.erase(id)
				continue

			if ac.special_type == "pause" and Managment.speed_time == 0:
				Signals.remove_information.emit(
					_get_translated_title(ac.title),
					_get_translated_message(ac.message)
				)
				delete(ac.title, ac.message)
				

			elif ac.special_type == "unpause" and Managment.speed_time != 0:
				Signals.remove_information.emit(
					_get_translated_title(ac.title),
					_get_translated_message(ac.message)
				)
				delete(ac.title, ac.message)
		
		await get_tree().create_timer(2).timeout

func is_first_available_tutorial(tutorial) -> bool:
	for t in data:
		if t.id in emitted_ids or t.cannot_be_first:
			continue
		return t == tutorial
	return false

func delete(title, message):
	for tot in data:
		if tot.title == title or _get_translated_title(tot.title) == title:
			if tot.message == message or _get_translated_message(tot.message) == message:
				if tot.id in active_ids:
					Signals.remove_information.emit(
						_get_translated_title(tot.title),
						_get_translated_message(tot.message)
					)
					active_ids.erase(tot.id)
				data.erase(tot)  # Safe - not using index
				return

func experiment_check(experiment_name : String):
	for tot in data:
		if tot.id in emitted_ids:
			continue
		if tot.after_unlocked_experiment == experiment_name:
			if tot.special_type:
				if tot.special_type == "pause" or tot.special_type == "unpause":
					Signals.add_information.emit(
						"toturial",
						_get_translated_title(tot.title),
						_get_translated_message(tot.message),
						0
					)
					active_ids.append(tot.id)
					emitted_ids.append(tot.id)
				elif tot.special_type == "first hut":
					GameEventsManagment.millstones.set("Hut unlocked", true)
					emitted_ids.append(tot.id)
			else:
				Signals.add_information.emit(
					"toturial",
					_get_translated_title(tot.title),
					_get_translated_message(tot.message),
					0,
					true
				)
				emitted_ids.append(tot.id)
