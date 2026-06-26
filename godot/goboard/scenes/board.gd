class_name Board extends GridMap

func getStone(x,y):
	return get_cell_item(Vector3i(x,0,y))
