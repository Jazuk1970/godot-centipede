extends Node2D
var mr_grid:Array
var cp_grid:Array

func _ready():
	mr_grid = Globals.mushroom_grid
	cp_grid = Globals.centipod_grid

func _process(delta):
	update()
	return delta

func _draw():
	var LINE_COLOR = Color8(88, 88, 88,128)
	var LINE_WIDTH = 1
#	var window_size = OS.get_window_size()

	for x in range(0,Globals.grid_size.x):
		var col_pos = x * Globals.grid_cell_size.x
		var limit = Globals.grid_size.y * Globals.grid_cell_size.y
		draw_line(Vector2(col_pos, 0), Vector2(col_pos, limit), LINE_COLOR, LINE_WIDTH)
	for y in range(0,Globals.grid_size.y):
		var row_pos = y * Globals.grid_cell_size.y
		var limit = Globals.grid_size.x* Globals.grid_cell_size.x
		draw_line(Vector2(0, row_pos), Vector2(limit, row_pos), LINE_COLOR, LINE_WIDTH)
		draw_string(get_parent().font,Vector2(10,8),"Mushrooms:" + str(Globals.no_of_mushrooms),Color(1.0,1.0,1.0,1.0))
		draw_string(get_parent().font,Vector2(10,16),"Centipods:" + str(Globals.no_of_centipods),Color(1.0,1.0,1.0,1.0))
	for x in range(0,Globals.grid_size.x):
		for y in range(0,Globals.grid_size.y):
			if mr_grid[x][y] != Globals.grid_types.EMPTY:
				draw_rect(Rect2(x * Globals.grid_cell_size.x,y * Globals.grid_cell_size.y,Globals.grid_cell_size.x, Globals.grid_cell_size.y),Color(1.0,0.5,0.0,0.5),true)
			if cp_grid[x][y] != Globals.grid_types.EMPTY:
				draw_rect(Rect2(x * Globals.grid_cell_size.x,y * Globals.grid_cell_size.y,Globals.grid_cell_size.x, Globals.grid_cell_size.y),Color(0.0,0.5,1.0,0.5),true)
