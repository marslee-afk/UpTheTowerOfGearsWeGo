extends Control

@onready var button = $Button
@onready var turn = $CheckButton
@onready var end = $CheckBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		if button.is_pressed():
			print("boop")
			if end.button_pressed and Dialogic.current_timeline == null:
				Dialogic.start('res://dialogic/timeline.dtl')
			skip()
			end.button_pressed = true
		else:
			end.button_pressed = false	

func skip():
	turn.button_pressed = !turn.button_pressed
