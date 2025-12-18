extends CanvasLayer

@onready var mode_button : Button = $"Mode"
@onready var edit_menu : Node  = $"Edit"
@onready var info_painting : TextureRect = $"info/TextureRect"
@onready var info : VBoxContainer = $"info/VBoxContainer"
@onready var time_label : Label = $"time/Label"

@export var map : NodePath


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	edit_menu.change_visible.emit(false)
	edit_menu.map = get_node(map) 
	Signals.pause_game.connect(_on_pause_pressed)
	Signals.unpause_game.connect(_on_unpause_pressed)
	Signals.time_updated.connect(update_time)
	Signals.add_information.connect(add_info)

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
	var new_icon = AtlasTexture.new()
	new_icon.atlas = load("res://assets/ui/ui-tileset.png")
	new_icon.region = Rect2(48,16,16,16)
	$timeManagment/pause.icon = new_icon


func _on_unpause_pressed() -> void:
	if Managment.totally_pause:
		return
	if Managment.mode == "edit":
		return
	Managment.speed_time = 1
	var new_icon = AtlasTexture.new()
	new_icon.atlas = load("res://assets/ui/ui-tileset.png")
	new_icon.region = Rect2(16,16,16,16)
	$timeManagment/pause.icon = new_icon


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

func add_info(type, title, text):
	var information = load("res://scenes/ui/information.tscn").instantiate()
	$info_box.add_child(information)
	information.add_information(type, title,text)
