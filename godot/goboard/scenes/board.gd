class_name Board extends GridMap

class StoneGroup :
	var stones : Array[Vector2i]
	var liberties : Array[Vector2i]

# Colors contains the groups of each color
var Colors : Array[Array] = [
	[],
	[]
]

var directions : Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

var size = 9

func findGroupWith(pos : Vector2i, color : int) -> StoneGroup:
	for group in Colors[color]:
		if group.stones.has(pos):
			return group as StoneGroup
	return null

func getIfNeighborsAre(starting_pos : Vector2i, color : int, check : Callable) -> Array:
	var neighbors = []
	for i in 4:
		var pos_to_check = starting_pos + directions[i]
		var color_to_check = getStone(pos_to_check.x, pos_to_check.y)
		var args = [starting_pos, pos_to_check, color, color_to_check]
		neighbors.append(check.callv(args))
	return neighbors

func setStone(color : int, pos : Vector3i):
	set_cell_item(pos, color)
	if color != 0 and color != 1:
		# Exit if not player stone (empty & cursor)
		return
		
	var posV2i : Vector2i = Vector2i(pos.x, pos.y)
	
	# Capturing
	var areNeiOppoGroup = getIfNeighborsAre(posV2i, color, isInAGroupOfOppoColor)
	for i in 4:
		if areNeiOppoGroup[i] == false :
			#Skip
			continue
		# Alegbra trick to toggle colors, unreadable but yea
		var neiOppoGroup = findGroupWith(posV2i + directions[i], -color+1)
		neiOppoGroup.liberties.remove(pos)
		if neiOppoGroup.liberties.is_empty():
			for stone in neiOppoGroup.stones:
				setStone(-1, stone)
	
	# Merging into group
	var areNeiSameGroup = getIfNeighborsAre(posV2i, color, isInAGroupOfSameColor)
	
	
	var availableGroupsToMerge = []
	for i in 4:
		if areNeiSameGroup[i] == false :
			#Skip
			continue
		availableGroupsToMerge.append(findGroupWith(posV2i + directions[i], color))
	# Actual merging
	var groupToJoin = null
	if availableGroupsToMerge.is_empty():
		print("Alone TvT")
		groupToJoin = StoneGroup.new()
		Colors[color].append(groupToJoin)
	elif availableGroupsToMerge.size() == 1:
		groupToJoin = availableGroupsToMerge[0]
	else:
		pass
	groupToJoin.stones.append(posV2i)
	var areEmptyNeiNotBorder = getIfNeighborsAre(posV2i, color, isEmptyNotBorder)
	if groupToJoin.liberties.has(posV2i):
		groupToJoin.liberties.remove(posV2i)
	for i in 4:
		if areEmptyNeiNotBorder[i] == false :
			# Skip
			continue
		
		groupToJoin.liberties.append(posV2i + directions[i])

func tile_on_board_vec2(tile_pos : Vector2i):
	var half_size = int(round(size/2.0))
	return tile_pos.x < half_size and tile_pos.y < half_size

func getStone(x,y) -> int:
	return get_cell_item(Vector3i(x,0,y))

func isSameColor(_starting_pos, _pos_to_check, color, color_to_check) -> bool:
	if color == color_to_check:
		return true
	return false

func isEmptyNotBorder(_starting_pos, pos_to_check, _color, color_to_check) -> bool:
	if color_to_check != -1 and color_to_check != 3:
		return false
	if tile_on_board_vec2(pos_to_check):
		return true
	return false

func isInAGroupOfSameColor(_starting_pos, pos_to_check, color, color_to_check) -> bool:
	if color != color_to_check:
		return false
	if findGroupWith(pos_to_check, color) : return true
	return false

func isInAGroupOfOppoColor(_starting_pos, pos_to_check, color, color_to_check) -> bool:
	if color != color_to_check:
		return false
	if findGroupWith(pos_to_check, color_to_check) : return true
	return false
