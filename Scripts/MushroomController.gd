extends Node2D
#Enums & Constants
enum states{INITIALISE,REGENERATION,IN_PLAY}
#signals
signal regenerate()

#Preload scenes
var oMushroom = preload("res://Scenes/Mushroom.tscn")

#Variables
var state:int
var regenerating:bool = false
var regen_done:bool = false
var regen_delay = 0.03

var totalMushrooms = 50		#this should come from the level data
#var mushroomGridSize:int = 8 	#The mushroom grid spacing in pixels
var mushroom_ids:Array = []
#var mushrooms_vectors:Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.no_of_mushrooms = 0
	state = states.INITIALISE
	set_process(true)
	var _result = self.connect("regenerate",self,"_regenerate")


func _process(delta):
	match state:
		states.INITIALISE:
			_initialise()
			#TODO: recode random generation now that the grid array can be used. Also use grid co-ords
			#	and then back convert to world co-ords after.
		states.REGENERATION:
			_regeneration()
		states.IN_PLAY:
			_in_play()
	return delta

func _initialise():
#	var horizontal_limits = Vector2(Globals.grid_cell_size.x,Globals.Screen_Size.x - Globals.grid_cell_size.x)
#	var vertical_limits = Vector2(Globals.grid_cell_size.y*2,Globals.Screen_Size.y - ( Globals.grid_cell_size.y * 10))
	var horizontal_limits = Vector2(1,Globals.grid_size.x - 2)
	var vertical_limits = Vector2(2,Globals.grid_size.y -10)
# warning-ignore:unused_variable
	var player_zone = Vector2(Globals.grid_size.y -10,Globals.grid_size.y - 1)
	for _mr in range(totalMushrooms):
#		var _pos = getUnusedPos(horizontal_limits,vertical_limits)
#		print(_pos)
		createMushroom(Globals.mushroomtypes.normal,getUnusedPos(horizontal_limits,vertical_limits))
	state = states.IN_PLAY

func _regeneration():
	if not regenerating:
		regenerating = true
		regen_done = false
		emit_signal("regenerate")
	else:
		if regen_done:
			regenerating = false
			regen_done = false
			print("state changed to in play")
			state = states.IN_PLAY

func _regenerate():
	var _mushrooms = get_tree().get_nodes_in_group("mushroom")
	var _score_update_required:bool
	for _mr in _mushrooms:
		_score_update_required = false
		while _mr.curFrame !=0:
			_score_update_required = true
			_mr.curFrame -= 1
			_mr.setFrame(_mr.curFrame)
			yield(get_tree().create_timer(regen_delay),"timeout")
		if _score_update_required:
			Globals.Score += _mr.points[4]
	regen_done = true


func _in_play():
	pass


#Create a mushroom of the given type, at the given position and ID
func createMushroom(type = Globals.mushroomtypes.normal,_grid_pos = Vector2.ZERO):
	var _pos = Globals.grid_to_world(_grid_pos)
	var _mushroom = oMushroom.instance()
	_mushroom.position = _pos
	_mushroom.mushroomtype = type
	_mushroom.ID = get_new_id()
	_mushroom.name = "mushroom_" + str(_mushroom.ID)
	_mushroom.add_to_group("mushroom")
	_mushroom.grid_pos = _grid_pos
	self.add_child(_mushroom)
#	mushrooms_vectors.append(_mushroom.grid_pos)
	Globals.grid_set_cell(_grid_pos,Globals.grid_types.MUSHROOM,_mushroom.ID)
	Globals.no_of_mushrooms += 1

##Convert a pixel location to a grid fixed pixel location
#func pixeltoGrid(val) -> int:
#	return (int(val / mushroomGridSize))*mushroomGridSize

func checkShroom(pos):
	var retVal = true
	for mr in get_tree().get_nodes_in_group("mushrooms"):
		if mr.position == pos:
			retVal = false
			break
	return retVal

#Get an unused grid location from the screen (only used during set-up)
func getUnusedPos(_horiz_limit:Vector2, _vert_limit:Vector2) -> Vector2:
	var _grid_pos = get_rand_pos(_horiz_limit,_vert_limit)
	while not Globals.grid_get_cell(_grid_pos,Globals.grid_types.MUSHROOM) == Globals.grid_types.EMPTY:
		_grid_pos = get_rand_pos(_horiz_limit,_vert_limit)
	return _grid_pos

func get_rand_pos(v1,v2) -> Vector2:
	return Vector2(Globals.getRand_Range(v1.x,v1.y,0),Globals.getRand_Range(v2.x,v2.y,0))

#Get a unique ID for the centipede and used for all its children
func get_new_id() -> int:
	var _new_id = Globals.get_new_id(mushroom_ids)
	mushroom_ids.append(_new_id)
	return _new_id
