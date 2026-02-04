extends Control

@onready var bc : ColorRect = $bc
@onready var line : Line2D = $Line2D
@onready var title_label : Label = $title
@onready var text_label : Label = $text

# Notification colors: [background, line/accent]
const COLORS := {
	"info": [Color("#2e64c9"), Color("#1a3a75")],
	"warning": [Color("#c2c229"), Color("#75751a")],
	"error": [Color("#c22933"), Color("#821e25")],
	"toturial": [Color("#03fc0f"), Color("#0e3810")]
}

const FADE_DURATION := 0.3
const DISPLAY_DURATION := 5.0

var tween: Tween

var title_setted
var message_setted

func _ready() -> void:
	modulate.a = 0.0
	visible = false

func add_information(type := "info", title := "title", text := "text", duration := DISPLAY_DURATION, need_proceed := false) -> void: # types - info, warning, error, toturial
	# Validate type
	if not type in COLORS:
		push_error("Invalid notification type: %s" % type)
		type = "info"
	
	$Button.visible = need_proceed
	
	title_setted = title
	message_setted = text
	
	# Set colors
	bc.color = COLORS[type][0]
	line.modulate = COLORS[type][1]
	
	# Set text
	title_label.text = title
	text_label.text = text
	
	print(title)
	
	# Show with animation
	visible = true
	_animate_in()
	
	# Auto-hide after duration
	if duration > 0:
		await get_tree().create_timer(duration).timeout
		hide_notification()

func _animate_in() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)

func _animate_out() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	await tween.finished
	visible = false

func hide_notification() -> void:
	_animate_out()


func _on_button_pressed() -> void:
	queue_free()
	ToturialManagement.delete(title_setted, message_setted)
