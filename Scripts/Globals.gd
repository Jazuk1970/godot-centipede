extends Node
enum mushroomtypes{normal,poison}		#Mushroom types
enum grid_types{EMPTY,MUSHROOM,CENTIPOD,PLAYER,BLOCKED,OUT_OF_BOUNDS}

#Constants
const gameStates = {							#The game states possible
	"Title": 1,
	"Init_Game": 10,
	"Init_Level": 100,
	"In_Play":200,
	"Life_Lost":300,
	"Game_Over":900,
	"Unknown":-1}
const playerStates = {							#The player states possible
	"Spawning":1,
	"Alive":10,
	"Dying":20,
	"Dead":30}
const dir = {
	"none":Vector2.ZERO,
	"up":Vector2(0,-1),
	"down":Vector2(0,1),
	"left":Vector2(-1,0),
	"right":Vector2(1,0),
	"upleft":Vector2(-1,-1),
	"upright":Vector2(1,-1),
	"downleft":Vector2(-1,1),
	"downright":Vector2(1,1)
	}

#Variables
var Score:int = 0 setget updateScore			#Player Score
var HiScore:int = 0 setget updateHiScore 		#Hi-Score (not retentive from reboot)
#var Lives:int  = 0 setget updateLives			#Player lives left
#var Level:int = 0 setget updateLevel			#Level of play (just determines starting row of aliens)
var Screen_Size:Vector2 = Vector2()				#Screen size holder
var OSScreen_Size:Vector2 = Vector2()			#OS screen size holder
var HUD:Node									#A pointer to the HUD
#var gameState = gameStates.Unknown				#The game state (current)
#var playerState = playerStates.Dead				#The player state (current)
#var mushroomRNG
#var mushroomSeed =  -580368265253271177
var grid:Array = []
var mushroom_grid:Array = []
var centipod_grid:Array = []

var grid_size:Vector2
var grid_cell_size = Vector2(8,8)

var no_of_bullets:int
# warning-ignore:unused_class_variable
var mushroom_controller:Node
var no_of_mushrooms:int
# warning-ignore:unused_class_variable
var centipede_controller:Node
var no_of_centipods:int
var no_of_centipedes:int
# warning-ignore:unused_class_variable
var game_controller:Node

func _ready():
	Screen_Size.x = ProjectSettings.get_setting("display/window/size/width")
	Screen_Size.y = ProjectSettings.get_setting("display/window/size/height")
	grid_size = (Screen_Size / grid_cell_size)
	_initialise_grid()


	#setBKG(Color8(255,4,4))

#Update the level function
#func updateLevel(val):							#Update the level value in the HUD
#	pass

#Update the score function
func updateScore(val):							#Update the score value in the HUD
	if HUD == null:									#get a reference to the hud if we've not already
		 HUD = get_node("/root/Game/HUD")		#keep the reference
	Score = val									#update the score
	HUD.updateScore(1,Score)					#call the HUD with the update
	if Score > HiScore:							#check if we have a new hi-score
		updateHiScore(Score)					#update the hi-score value

#Update the lives function
#func updateLives(val):							#Update the player lives in the hud
#	pass

#Update the hi-score function
func updateHiScore(val):						#Update the hi-score in the hud
	if HUD == null:									#get a reference to the hud if we've not already
		 HUD = get_node("/root/Game/HUD")		#keep the reference
	HiScore = val								#update the hi-score
	HUD.updateScore(0,HiScore)					#call the HUD with the update

#Choose a random number between low and high values (type: 0 = integer, 1 = float)
func getRand_Range(low,high, type, gen = null):
	var rng
	if !gen:	#if a generator has not been passed create a temporary new one
		rng = RandomNumberGenerator.new()		#Initialise a random number generator
		rng.randomize()								#randomize the result
	else:
		rng = gen
	if type == 0:								#Check if an integer is requested
		return rng.randi_range( low, high)		#return a random integer between the two specified values
	else:
		return rng.randf_range( low, high)		#return a random float between the two specified values

func mapScreenSize():
	Screen_Size = Vector2(get_viewport().size.x,get_viewport().size.y) 	#Get the screen size
	OSScreen_Size = OS.get_screen_size()								#Get the OS screen size
	OS.set_window_position(OSScreen_Size*0.5 - Screen_Size*0.5)	#Set the window position

#This function will check if an action has previously been pressed, if not return true. This prevents continuous firing
func is_action_just_pressed(_action,_pressed):
	if Input.is_action_pressed(_action):							#Check if the specific key is pressed
		if not _pressed.has(_action) or not _pressed[_action]:		#If the key has not been previously pressed
			_pressed[_action] = true								#Register the keypress in an array for future checking
			return true											#Return true, this is the first time the key is pressed
		else:
			return false												#Return false, the key has not been pressed
	_pressed[_action] = false									#The key is no longer pressed, remove the keypress from the array

#Set the background colour
func setBKG(_col:Color):
	VisualServer.set_default_clear_color(_col)

#func alignposition(_pos:Vector2) -> Array:
#	var _ar:Array = []
#	var _v = Vector2(int(_pos.x)/8,int(_pos.y)/8)
#	_ar.append(_v)
#	_v = Vector2(_v.x*8,_v.y*8)
#	_ar.append(_v)
#	return _ar

func compareArray(_ary1:Array,_ary2:Array) -> bool:
	if _ary1.size() != _ary2.size():
		return false
	else:
		for _i in _ary1.size():
			if _ary1[_i] != _ary2[_i]:
				return false
		return true

#Set the contents of the grid to a given value
func grid_set_cell(_pos:Vector2,_type:int = grid_types.EMPTY,_val = null ):
	if _pos.x < 0 or _pos.x > grid_size.x -1 or _pos.y < 0 or _pos.y > grid_size.y -1:
		return
	var _grid = _get_grid(_type)
	if _val == null:
		_val = _type
	_grid[_pos.x][_pos.y] = _val

#Get the contents of the grid at a given location
func grid_get_cell(_pos:Vector2,_type:int) -> int:
	if _pos.x < 0 or _pos.x > grid_size.x -1 or _pos.y < 0 or _pos.y > grid_size.y -1:
		return grid_types.OUT_OF_BOUNDS
	else:
		var _grid = _get_grid(_type)
		return _grid[_pos.x][_pos.y]

#Initialise the grid to an empty array
func _initialise_grid() -> void:
	for _x in range(grid_size.x):
		var _column = []
		for _y in range (grid_size.y):
			_column.append(grid_types.EMPTY)
		grid.append(_column)
	mushroom_grid = grid.duplicate(true)
	centipod_grid = grid.duplicate(true)


func _get_grid(_type) -> Array:
	match _type:
		Globals.grid_types.MUSHROOM:
			return mushroom_grid
		Globals.grid_types.CENTIPOD:
			return centipod_grid
		_:
			return grid


#Return a world position from the grid position
func grid_to_world(_grid_pos:Vector2) -> Vector2:
	return _grid_pos * grid_cell_size

#Return a grid position from a world position
func world_to_grid(_world_pos:Vector2) -> Vector2:
	var _x
	var _y
	if int(_world_pos.x / grid_cell_size.x) == 0 and _world_pos.x < 0:
		_x = int(_world_pos.x / grid_cell_size.x) -1
	else:
		_x = int(_world_pos.x / grid_cell_size.x)

	if int(_world_pos.y / grid_cell_size.y) == 0 and _world_pos.y < 0:
		_y = int(_world_pos.y / grid_cell_size.y) -1
	else:
		_y = int(_world_pos.y / grid_cell_size.y)

	return Vector2(_x,_y)
