extends Resource

class_name WorkList

@export var works_list : Array[WorkBase]

func add_work(work):
	works_list.append(work)