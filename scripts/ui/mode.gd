extends CanvasLayer

@onready var mode_button : Button = $"Mode"
@onready var edit_menu : Node  = $"Edit"
@onready var info_painting : TextureRect = $"info/TextureRect"
@onready var info : VBoxContainer = $"info/VBoxContainer"
@onready var time_label : Label = $"time/Label"

@export var map : NodePath


var selected := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	edit_menu.change_visible.emit(false)
	edit_menu.map = get_node(map) 
	Signals.pause_game.connect(_on_pause_pressed)
	Signals.unpause_game.connect(_on_unpause_pressed)
	Signals.time_updated.connect(update_time)
	Signals.add_information.connect(add_info)
	Signals.remove_information.connect(remove_info)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		info_painting.visible = !info_painting.visible
		info.visible = !info.visible
		Managment.totally_pause = !Managment.totally_pause
		$info/AnimationPlayer.play("open")

func _on_mode_pressed() -> void:
	if Managment.totally_pause:
		return
	#var map_node = get_node(map)
	Managment.mode = ("normal" if Managment.mode == "edit" else "edit")
	if Managment.mode == "edit":
		mode_button.icon = load("res://assets/ui/exit_edit.png")
		edit_menu.change_visible.emit(true)
		Signals.edit_menu_opened.emit()
		Signals.pause_game.emit()
	else:
		Managment.make_transport_map(get_node(map).get_child(0))
		WorkersManagement.determine_betting_house_connetion()
		Managment.was_edit_menu_opened = true
		mode_button.icon = load("res://assets/ui/edit.png")
		edit_menu.change_visible.emit(false)
		Signals.unpause_game.emit()
		
	

func _on_save_pressed() -> void:
	load("res://scripts/save_managment.gd").new().save(get_node(map).get_child(0))
	


func _on_pause_pressed() -> void:
	if Managment.totally_pause:
		return
	Managment.speed_time = 0
	set_button_image("pause", true)
	set_button_image(selected, false)
	selected = "pause"


func _on_unpause_pressed() -> void:
	if Managment.totally_pause:
		return
	if Managment.mode == "edit":
		return
	Managment.speed_time = 1
	Managment.multiple_speed = 1
	set_button_image(selected, false)
	selected = ""


func _on_resume_pressed() -> void:
	info_painting.visible = !info_painting.visible
	info.visible = !info.visible
	Managment.totally_pause = !Managment.totally_pause


func _on_exit_pressed() -> void:
	load("res://scripts/save_managment.gd").new().save(get_node(map).get_child(0))
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")


func _on_people_managment_pressed() -> void:
	self.add_child(load("res://scenes/ui/people_managment.tscn").instantiate())

func update_time():
	time_label.text = "%s:%s" % [TimeManagment.time.hours, TimeManagment.time.minutes]

func add_info(type, title, text, time := 5, need_proceed:=false):
	var information = load("res://scenes/ui/information.tscn").instantiate()

	$info_box.add_child(information)	
	information.add_information(type, title, text, time, need_proceed)
	

func remove_info(title, message):
	for mess in $info_box.get_children():
		if mess.title_setted == title and mess.message_setted == message:
			mess.queue_free()


func set_button_image(button := "", button_selected := false):
	var avaible := ["pause", "speedx5", "speedx15"]
	var button_data : Button
	var new_icon : AtlasTexture
	if button in avaible:
		new_icon = AtlasTexture.new()
		new_icon.atlas = load("res://assets/ui/ui-tileset.png")
		if button == "pause":
			button_data = $timeManagment/pause
			if button_selected:
				new_icon.region = Rect2(48,16,16,16)
			else:
				new_icon.region = Rect2(16,16,16,16)
		elif button == "speedx5":
			button_data = $timeManagment/speedx5
			if button_selected:
				new_icon.region = Rect2(80,0,16,16)
			else:
				new_icon.region = Rect2(64,32,16,16)
		elif button == "speedx15":
			button_data = $timeManagment/speedx15
			if button_selected:
				new_icon.region = Rect2(80,16,16,16)
			else:
				new_icon.region = Rect2(64,48,16,16)
			
	if button_data:
		button_data.icon = new_icon

func _on_speedx_15_pressed() -> void:
	Managment.speed_time = 1
	Managment.multiple_speed = 15
	set_button_image(selected, false)
	set_button_image("speedx15", true)
	selected = "speedx15"

func _on_speedx_5_pressed() -> void:
	Managment.speed_time = 1
	Managment.multiple_speed = 5
	set_button_image(selected, false)
	set_button_image("speedx5", true)
	selected = "speedx5"
