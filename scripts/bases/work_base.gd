extends Resource

class_name WorkBase

@export var name_var := "Name"
@export_enum("collecting", "looking after", "building") var type : String
@export var minimal_people := 0
@export var time : TimeData


@export_subgroup("Collecting")
@export var count := 0
@export var output : ProductBase

@export_subgroup("Looking After")
@export var target_group := "target group"
@export var taking_damage := 0 

@export_subgroup("building")
@export var build_data : BuildsBase