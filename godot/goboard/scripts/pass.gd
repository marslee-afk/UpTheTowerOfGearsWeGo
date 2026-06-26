extends Control

@onready var button = $Button
@onready var turn = $CheckButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click") and button.is_pressed():
		print("boop")
		skip()
func skip():
	turn.button_pressed = !turn.button_pressed
