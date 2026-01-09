extends Control

@onready var label_name : Label = $TextureRect/name
@onready var people_label : Label = $TextureRect/Label

var house_data : HouseBase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.close_ui.connect(func(): queue_free())
	update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update():
	label_name.text = house_data.name
	var text = ""
	var count = 0
	for person in house_data.liveing_people:
		count += 1
		if count > house_data.max_people:
			break
		text += " * " + person.name + "\n"	
	
	var text2 = "People (%s/%s):\n" % [count, house_data.max_people]
	people_label.text = text2 + text

func _on_button_pressed() -> void:
	var people_assing = load("res://scenes/ui/people_assing.tscn").instantiate()
	var	items = []
	
	for person in Managment.people:
		items.append(person.name)
	
	people_assing.items = items
	people_assing.max_select = house_data.max_people
	people_assing.closed.connect(read_data)
	$CanvasLayer.add_child(people_assing)

func read_data(data: Array):
	house_data.liveing_people.clear()
	for person in Managment.people:
		for person1 in data:
			if person1 == person.name:
				house_data.liveing_people.append(person)
	update()