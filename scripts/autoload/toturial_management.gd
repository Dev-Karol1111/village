extends Node

var data : Array
var active : Array

var emitted : Array

# Dictionary to map tutorial titles to translation keys
var tutorial_titles = {
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

var tutorial_messages = {
	"First stop time": "tutorial.time.message",
	"Assing: 1 person to care for elderly\n 2 for care children\n 5 for fruit picking & 1 wood picking\n1 to the experimet (campfire)": "tutorial.works.message",
	"Unpause the game": "tutorial.unpause.message",
	"Wait until experiment finish": "tutorial.wait.message",
	"Experimenting with campfire finished.\nBuild your first campfire.": "tutorial.campfire.message",
	"Hut was unlocked.\nAssingone people to this experiment.": "tutorial.unlocked.message",
	"Experiments with hut has ended. \nNow you can place it.": "tutorial.building.message",
	"Build your first hut.\nAssingone  1 person into this work": "tutorial.hut.build.message",
	"Check it when hut is finished": "tutorial.hut.check.message",
	"Assing greybeard into hut unless you want\nto lose them ...": "tutorial.greybeard.message"
}

func _get_translated_title(title: String) -> String:
	if title in tutorial_titles:
		return tr(tutorial_titles[title])
	return title

func _get_translated_message(message: String) -> String:
	# Try to find and translate the message
	for key in tutorial_messages:
		if key.to_lower() in message.to_lower():
			return tr(tutorial_messages[key])
	return message

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
						Signals.add_information.emit("toturial", _get_translated_title(tot.title), _get_translated_message(tot.message), 0)
						active.append(tot)
					elif tot.special_type == "unpause":
						Signals.add_information.emit("toturial", _get_translated_title(tot.title), _get_translated_message(tot.message), 0)
						active.append(tot)
					emitted.append(tot)
				else:
					if !first:
						Signals.add_information.emit("toturial", _get_translated_title(tot.title), _get_translated_message(tot.message), tot.time_from.to_one_data() - tot.time_to.time_to_one_data())
					else:
						Signals.add_information.emit("toturial", _get_translated_title(tot.title), _get_translated_message(tot.message), 0, true)
					data.erase(tot)
		
		for ac in active:
			if ac.special_type == "pause":
				if Managment.speed_time == 0:
					Signals.remove_information.emit(_get_translated_title(ac.title), _get_translated_message(ac.message))
					data.erase(ac)
			if ac.special_type == "unpause":
				if Managment.speed_time != 0:
					Signals.remove_information.emit(_get_translated_title(ac.title), _get_translated_message(ac.message))
					data.erase(ac)
		
		await get_tree().create_timer(2).timeout

func delete(title, message):
	for tot_te in data:
		if tot_te.title == title or _get_translated_title(tot_te.title) == title:
			if tot_te.message == message or _get_translated_message(tot_te.message) == message:
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
					Signals.add_information.emit("toturial", _get_translated_title(tot.title), _get_translated_message(tot.message), 0)
					active.append(tot)
				elif tot.special_type == "unpause":
					Signals.add_information.emit("toturial", _get_translated_title(tot.title), _get_translated_message(tot.message), 0)
					active.append(tot)
					emitted.append(tot)
				elif tot.special_type == "first hut":
					GameEventsManagment.millstones.set('Hut unlocked', true)
			else:
				Signals.add_information.emit("toturial", _get_translated_title(tot.title), _get_translated_message(tot.message), 0, true)
				data.erase(tot)
				
