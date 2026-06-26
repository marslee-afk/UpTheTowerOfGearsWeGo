extends Node3D

@onready var grid_map = $GridMap
@onready var camera = $Camera3D
@onready var label = $Control/Label
@onready var turn = $Control/CheckButton
@onready var place = $AudioPlace
@onready var song = $AudioBGM
var size = 9
var black = 0
var white = 1
var empty = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Replace with function body.
	print("Ready!") 
	song.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var ray = shoot_ray()
	if ray or ray == Vector3i(0,0,0):
		var tile = Vector2i(ray.x, ray.z)
		var string = alpha_enum(size,tile.x)+go_renumer(size,tile.y)
		label.text = string
		for i in range(-4,5):
			for j in range(-4,5):
				if grid_map.get_cell_item(Vector3i(i,0,j)) == 3:
					grid_map.set_cell_item(Vector3i(i,0,j),-1)
		if ((grid_map.get_cell_item(ray) == -1 or grid_map.get_cell_item(ray) == 3) 
		and (ray.abs().x < 5 and ray.abs().z < 5)):
			grid_map.set_cell_item(ray,3)

func go_renumer(board_size:int, cellpos, invert=true):
	@warning_ignore("integer_division")
	var offset = board_size/2
	if !invert:
		return str(1+cellpos+offset)
	else:
		return(str(size-(cellpos+offset)))
func alpha_enum(board_size:int, cellpos):
	var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	@warning_ignore("integer_division")
	var offset = board_size/2
	var index = cellpos+offset
	return alphabet[index]

func _input(_event):
	if Input.is_action_just_pressed("click"):
		print("click")
		# callibration
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
		
		var tile_ray_pos = shoot_ray(true)
		if ((tile_ray_pos or tile_ray_pos == Vector3i(0,0,0)) 
		and (tile_ray_pos.abs().x < 5 and tile_ray_pos.abs().z < 5)):
			if grid_map.get_cell_item(tile_ray_pos) == empty or grid_map.get_cell_item(tile_ray_pos) == 3:
				var pending = []
				var x = tile_ray_pos.x
				var y = tile_ray_pos.z
				if !turn.button_pressed:
					placeGo(black, tile_ray_pos)
					capAdjaStones(grid_map, x, y, black, pending)
				else:
					placeGo(white, tile_ray_pos)
					capAdjaStones(grid_map, x, y, white, pending)
				turn.button_pressed = !turn.button_pressed
			else:
				placeGo(empty, tile_ray_pos)
				#turn.button_pressed = !turn.button_pressed
			

func placeGo(piece, location): #separated it in case i have to place pieces for territory reasons...
	grid_map.set_cell_item(location, piece)
	place.pitch_scale = randf_range(0.7,4.0)
	place.play()

func shoot_ray(prt=false):
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = camera.project_ray_origin(mouse_pos)
	var to = camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_results = space.intersect_ray(ray_query)
	if raycast_results:
		var ray_pos = raycast_results.position
		var tile_ray_pos = Vector3i(grid_map.map_to_local(Vector3i(ray_pos.x*15,ray_pos.y,ray_pos.z*15)))
		if prt:
			print("Ray Info:")
			print(ray_pos)
			print(tile_ray_pos)
		return tile_ray_pos
	else:
		return

func capAdjaStones(board, x, y, color, captures):
	captureStones(board, x+1, y, color, captures)
	captureStones(board, x, y+1, color, captures)
	captureStones(board, x-1, y, color, captures)
	captureStones(board, x, y-1, color, captures)
# Check for and perform capture of opposite color chain at (x, y)
func captureStones(board, x, y, color, captures):
	var pending = []
	if ( !recursiveCapture(board, x, y, color, pending) ) and len(pending) == 0: #Captured chain found
		print("capturing: ", len(pending))
		for i in len(pending): #Remove captured stones
			print(pending[i])
			placeGo(Vector3i(pending[i].x,0,pending[i].y), empty);
			captures.append(pending[i]);

# Recursively builds a chain of pending captures starting from (x, y)
# Stops and returns true if chain has liberties
func recursiveCapture(board: GridMap, x: int, y: int, color: int, pending: Array):
	var colorlist = {black:white, white:black}
	var ocolor = colorlist[color]
	pending.append({'x':0,'y':0})
	print("capstone bounds:", 1-size/2,', ', size-size/2); @warning_ignore("integer_division")
	if (x < 1-size/2 || y < 1-size/2 || x > size-size/2 || y > size-size/2):
		print("position:",x,',',y); return false; # Stop if out of bounds
	if board.getStone(x,y) != -1: print('OppoColor check:',board.getStone(x,y),"!=", color)
	if (board.getStone(x, y) != color ) and (board.getStone(x,y) == empty or board.getStone(x,y) == 3):
		return false; # Stop if other color found
	print('EmptyTile check:',board.getStone(x,y),"==",-1)
	if (board.getStone(x, y) == -1):
		return true; # Stop and signal that liberty was found
	print("duplicheck")
	for i in len(pending):
		if (pending[i].x == x && pending[i].y == y) and len(pending) > 0:
			return false; # Stop if already in pending captures
	
	pending.append({'x': x, 'y': y}); # Add new stone into chain of pending captures
	
	# Recursively check for liberties and expand chain
	if (recursiveCapture(board, x - 1, y, color, pending) || recursiveCapture(board, x + 1, y, color, pending) ||
		recursiveCapture(board, x, y - 1, color, pending) || recursiveCapture(board, x, y + 1, color, pending)):
			return true; # Stop and signal liberty found in subchain
	return false; # Otherwise, no liberties found
