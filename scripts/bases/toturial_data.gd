extends Resource

class_name ToturialData

@export var title := "TITLE"
@export_multiline var message := "MESSAGE"
@export var id := "ID"
@export var time_from : TimeData
@export var time_to : TimeData
@export var special_type : String
@export var need_proceed : bool = false
@export var after_unlocked_experiment : String # Experiment name
@export var after_finished_experiment : String # Experiment name
@export var cannot_be_first : bool = false