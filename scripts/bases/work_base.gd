extends Resource

class_name WorkBase

@export var name_var := "Name"
@export_enum("collecting", "looking after", "building", "special") var type : String
@export var minimal_people := 0
@export var time : TimeData = TimeData.new()


@export_subgroup("Collecting")
@export var count := 0
@export var output : ProductBase

@export_subgroup("Looking After")
@export var target_group := "target group"
@export var taking_damage := 0 

@export_subgroup("building")
@export var build_data : BuildsBase

func get_data_in_dictionary() -> Dictionary:
	var data := {
		"name": name_var,
		"type": type,
		"minimal_people": minimal_people,
	}
	
	if time:
		data["time"] = time.to_one_data()
	
	# === COLLECTING ===
	if type == "collecting":
		data["count"] = count
		if output.name:
			data["output"] = output.name
		else:
			data["output"] = null

	# === LOOKING AFTER ===
	elif type == "looking after":
		data["target_group"] = target_group
		data["taking_damage"] = taking_damage

	# === BUILDING ===
	elif type == "building":
		if build_data:
			data["build_type"] = build_data.type
			data["build_id"] = build_data.id
		else:
			data["build_type"] = null
			data["build_id"] = null

	return data


func set_data_from_dictionary(dict: Dictionary):
	name_var = dict.get("name", name_var)
	type = dict.get("type", type)
	minimal_people = dict.get("minimal_people", minimal_people)
	

	if dict.has("time") and time:
		if time.has_method("from_one_data"):
			time.add(dict["time"])
	match type:
		"collecting":
			count = dict.get("count", count)
			var new_output = ProductBase.new()
			if dict["output"]:
				new_output.name = dict["output"]
			output = new_output

		"looking after":
			target_group = dict.get("target_group", target_group)
			taking_damage = dict.get("taking_damage", taking_damage)

		"building":
			if build_data:
				build_data = load("res://scripts/bases/Building_index.gd").indexes[dict.get("build_id", build_data.id)]