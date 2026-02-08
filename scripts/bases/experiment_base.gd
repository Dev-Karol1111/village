extends Resource

class_name ExperimentBase

@export var name_var := "Name"
@export var max_people := 0
@export var min_people := 0
@export var time : TimeData
@export var result : BuildsBase
@export var milstone : String = ""

func get_data_in_dictionary() -> Dictionary:
	return {"name":name_var, "max_people":max_people, "min_people":min_people, "time":time.to_one_data(), "result":result.get_data(), "millstone":milstone}

func set_data_from_dictionary(data : Dictionary):
	name_var = data["name"]
	max_people = data["max_people"]
	min_people = data["min_people"]
	time = TimeData.new()
	time.add(data["time"])
	result = load("res://resources/buildings_index.tres").indexes[data["result"]]
	milstone = data["millstone"]