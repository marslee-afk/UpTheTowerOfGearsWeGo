extends Control


# Main buttons
@onready var start_button = $Main/menu_container/Start
@onready var options_button = $Main/menu_container/Options
@onready var credits_button = $Main/menu_container/Credits
@onready var quit_button = $Main/menu_container/Credits

# Options buttons
@onready var music_slider = $Options/menu_container/music_Container/music_volume
@onready var music_toggle = $Options/menu_container/music_Container/music_toggle
@onready var back_options_button = $Options/menu_container/Back_options

# Credits buttons
@onready var back_credits_button = $Credits/menu_container/Back_credits


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Back to main menu
	#back_options_button.pressed.connect(back_main_menu())
	#back_credits_button.pressed.connect(back_main_menu())
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Main menu logic
	if (start_button.is_pressed()) :
		#fadeout
		get_tree().change_scene_to_file("res://scenes/introScene.tscn")
	if (options_button.is_pressed()) :
		options_menu()
	if (credits_button.is_pressed()) :
		credits_menu()
	if (quit_button.is_pressed()) :
		print ("Quit pressed")
		get_tree().quit()

	# Options menu logic
	if (back_options_button.is_pressed()) :
		back_main_menu()
	
	# Credits menu logic
	if (back_credits_button.is_pressed()) :
		back_main_menu()


# Hides all the other menus and shows main
func back_main_menu():
	print ("back_main_menu runs")
	$Options.hide()
	$Credits.hide()
	$Main.show()


# Hides all the other menus and shows options
func options_menu():
	$Credits.hide()
	$Main.hide()
	$Options.show()


# Hides all the other menus and shows credits
func credits_menu():
	$Main.hide()
	$Options.hide()
	$Credits.show()
