extends Resource

class_name WorkBase

@export var name_var := "Name"
@export_enum("collecting", "looking after") var type : String

@export_subgroup("Collecting")
@export var time : TimeData
@export var count := 0
@export var output : ProductBase

@export_subgroup("Looking After")
@export var target_group := "target group"
@export var minimal_people := 0
@export var taking_damage := 0 
