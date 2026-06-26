extends Control

@onready var start: Button = $Main/menu_container/Start
@onready var options: Button = $Main/menu_container/Options
@onready var quit: Button = $Main/menu_container/Quit

@onready var music_volume: VSlider = $Options/menu_container/music_Container/music_volume
@onready var music_toggle: CheckButton = $Options/menu_container/music_Container/music_toggle

@onready var back: Button = $Options/menu_container/Back
@onready var back_2: Button = $Credits/Back2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
