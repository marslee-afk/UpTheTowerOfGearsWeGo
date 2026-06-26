class_name CombatMain extends Node3D

@onready var grid_map = $GridMap
@onready var camera = $Camera3D
@onready var label = $Control/Label
@onready var turn = $Control/CheckButton
@onready var place = $AudioPlace
@onready var song = $AudioBGM

var size = 9

var black = 0
var white = 1
var hover_cursor = 3
var empty = -1

# Called when the node enters the scene tree for the first time.
# Used to start sound
func _ready() -> void:
	print("Ready!") 
	song.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Use to handle the cursor hover over a tile
func _process(_delta: float) -> void:
	var ray_tile_pos = shoot_ray()
	if ray_tile_pos or ray_tile_pos == Vector3i(0,0,0):
		var tile2D = Vector2i(ray_tile_pos.x, ray_tile_pos.z)
		var string = alpha_enum(size,tile2D.x) + go_renumer(size,tile2D.y)
		label.text = string
		# Find the hover_cursor tile and empty it, range does not go through the last one (5)
		for i in range(-4,5):
			for j in range(-4,5):
				if grid_map.get_cell_item(Vector3i(i,0,j)) == hover_cursor:
					grid_map.set_cell_item(Vector3i(i,0,j), empty)

		# Only set the tile at mouse at hover_cursor if it's empty
		var tile_at_cursor_is_empty = grid_map.get_cell_item(ray_tile_pos) == empty
		if tile_at_cursor_is_empty and tile_on_board_vec3(ray_tile_pos.abs()):
			grid_map.set_cell_item(ray_tile_pos,hover_cursor)

func tile_on_board_vec3(tile_pos : Vector3i):
	var half_size = int(round(size/2.0))
	return tile_pos.x < half_size and tile_pos.z < half_size

func tile_on_board_vec2(tile_pos : Vector2i):
	var half_size = int(round(size/2.0))
	return tile_pos.x < half_size and tile_pos.y < half_size

func go_renumer(board_size : int, cellpos, invert : bool = true):
	@warning_ignore("integer_division")
	var offset = board_size/2
	if !invert:
		return str(1+cellpos+offset)
	else:
		return(str(size-(cellpos+offset)))

func alpha_enum(board_size : int, cellpos):
	var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	@warning_ignore("integer_division")
	var offset = board_size/2
	var index = cellpos+offset
	return alphabet[index]

func _input(_event):
	if Input.is_action_just_pressed("click"):
		print("click")
		# callibration, done when ??
		if false:
			print("Set positions:") # Below: test examples
			# x = left/right ; y = foward/back ; z = up/down
			#         Vector3i( x, y, z)
			var ex1 = Vector3i( 0, 0, 0) #origin
			var ex2 = Vector3i(-17, 0, 17)
			var ex3 = Vector3i( 17, 0, 17)
			var ex4 = Vector3i(-17, 0,-17)
			var ex5 = Vector3i( 17, 0,-17)
			var mtl = Callable(grid_map, "map_to_local")
			print(ex1, mtl.call(ex1))
			print(ex2, mtl.call(ex2))
			print(ex3, mtl.call(ex3))
			print(ex4, mtl.call(ex4))
			print(ex5, mtl.call(ex5))
			#var sci = Callable(grid_map, "set_cell_item")
			#sci.call(mtl.call(ex2), white) # lower left
			#sci.call(mtl.call(ex3), white) # lower right
			#sci.call(mtl.call(ex4), white) # upper left
			#sci.call(mtl.call(ex5), white) # upper right
		
		var ray_tile_pos = shoot_ray(true)
		if ((ray_tile_pos or ray_tile_pos == Vector3i(0,0,0)) 
		and tile_on_board_vec3(ray_tile_pos)):
			var ray_tile_pos_type : int = grid_map.get_cell_item(ray_tile_pos)
			if ray_tile_pos_type == empty or ray_tile_pos_type == hover_cursor:
				var pending = []
				var place_pos = Vector2i(ray_tile_pos.x,ray_tile_pos.z)
				#if button is not pressed
				if !turn.button_pressed:
					placeGo(black, ray_tile_pos)
					capAdjaStones(grid_map, place_pos, black, pending)
				#if button pressed
				else:
					placeGo(white, ray_tile_pos)
					capAdjaStones(grid_map, place_pos, white, pending)
				turn.button_pressed = !turn.button_pressed
			else:
				placeGo(empty, ray_tile_pos)

# Separated it in case i have to place pieces for territory reasons...
func placeGo(piece : int, location : Vector3i, debugging : bool = false):
	if debugging:
		print(piece)
	grid_map.set_cell_item(location, piece)
	place.pitch_scale = randf_range(0.7,4.0)
	place.play()

# Detect if / where the cursor is on the board
func shoot_ray(debugging : bool = false):
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_results = space.intersect_ray(ray_query)
	#If collided -> if there is something facing the cursor
	if raycast_results:
		var ray_pos = raycast_results.position
		var ray_tile_pos = Vector3i(grid_map.map_to_local(Vector3i(ray_pos.x*15,ray_pos.y,ray_pos.z*15)))
		if debugging:
			print("Ray Info: %s || %s \n" % [ray_pos,ray_tile_pos])
			#Formatting made complex but beautifull / powerfull
		return ray_tile_pos
	else:
		return

# For Every adajacent tile, repeat the logic
func capAdjaStones(board, pos, color, captures):
	captureStones(board, pos + Vector2i.RIGHT, color, captures)
	captureStones(board, pos + Vector2i.DOWN, color, captures)
	captureStones(board, pos + Vector2i.LEFT, color, captures)
	captureStones(board, pos + Vector2i.UP, color, captures)

# Board is the grid_map, xy the coordinates and color the turn color
# Check for and perform capture of opposite color chain at (x, y)
func captureStones(board, pos, color, captures):
	var pending = []
	if ( !recursiveCapture(board, pos, color, pending) ) and len(pending) == 0: #Captured chain found
		print("capturing: ", len(pending))
		for i in len(pending): #Remove captured stones
			print(pending[i])
			placeGo(empty, Vector3i(pending[i].x,0,pending[i].y), true);
			captures.append(pending[i]);

# Recursively builds a chain of pending captures starting from (x, y)
# Stops and returns true if chain has liberties -> false if chain found
func recursiveCapture(board: GridMap, pos : Vector2i, color: int, pending: Array):
	#Useless for ?? reason
	#var colorlist = {black:white, white:black}
	#var _ocolor = colorlist[color]
	
	#So pending is an array of dictionnaries ? TODO change it to another type of more usable data
	pending.append(Vector2i.ZERO)
	print("capstone bounds:", -size/2,', ', size-size/2); @warning_ignore("integer_division")
	if !tile_on_board_vec2(pos):
		print("position: %s", pos)
		return false
		# Stop if out of bounds 
		#? But out of bounds is a liberty right?
	var stone_at_pos = board.getStone(pos.x,pos.y)
	if stone_at_pos != empty:
		print("OppoColor check: %s != %s" % [stone_at_pos, color])
	if (stone_at_pos == empty or stone_at_pos == hover_cursor):
		return false # Stop if no stone found
	print('EmptyTile check:',stone_at_pos,"==",-1)
	if (stone_at_pos == -1):
		return true # Stop and signal that liberty was found
	print("duplicheck")
	for i in len(pending):
		if (pending[i].x == pos.x && pending[i].y == pos.y) and len(pending) > 0:
			return false # Stop if already in pending captures
	
	pending.append(pos) # Add new stone into chain of pending captures
	
	# Recursively check for liberties and expand chain
	if (recursiveCapture(board, pos + Vector2i.LEFT, color, pending) || recursiveCapture(board, pos + Vector2i.RIGHT, color, pending) ||
		recursiveCapture(board, pos + Vector2i.UP, color, pending) || recursiveCapture(board, pos + Vector2i.DOWN, color, pending)):
			return true; # Stop and signal liberty found in subchain
	return false; # Otherwise, no liberties found
