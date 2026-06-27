extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.start('res://dialogic/Dialogue/Intro.dtl')
	# Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Dialogic.current_timeline != null:
		return
	get_tree().change_scene_to_file("res://goboard/scenes/node_3d.tscn")

func _input(_event):
	pass
