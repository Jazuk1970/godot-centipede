extends Node
enum mushroom_types{NORMAL,POISON}		#Mushroom types
enum grid_types{EMPTY,MUSHROOM,CENTIPOD,PLAYER,BLOCKED,OUT_OF_BOUNDS}
enum return_code{OK,STATE_DOES_NOT_EXISTS}
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
var Lives:int  = 0 setget updateLives			#Player lives left
var Level:int = 0 setget updateLevel			#Level of play (just determines starting row of aliens)
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
var player_zone:Rect2
var ymaxline:int
var ymidline:int

var no_of_bullets:int
var no_of_mushrooms:int
var no_of_mushrooms_in_player_zone:int
var no_of_centipods:int
var no_of_centipedes:int
var showing_message:bool = false
var message_done:bool = false

#controller nodes
var main_controller:Object
var game_controller:Object
var player_controller:Object
var mushroom_controller:Object
var centipede_controller:Object
var flea_controller:Object
var scorpion_controller:Object
var spider_controller:Object
var SFX:Object

func _ready():
	Screen_Size.x = ProjectSettings.get_setting("display/window/size/width")
	Screen_Size.y = ProjectSettings.get_setting("display/window/size/height")
	grid_size = (Screen_Size / grid_cell_size)
	ymaxline = int(grid_size.y) - 2
	ymidline = int(grid_size.y) - 10
	_initialise_grid(grid_types.MUSHROOM)
	_initialise_grid(grid_types.CENTIPOD)
	self.HiScore = 10000


	#setBKG(Color8(255,4,4))

#Update the level function
func updateLevel(_val):							#Update the level value in the HUD
	HUD = get_tree().get_nodes_in_group("HUD").front()		#keep the reference
	if HUD != null:									#get a reference to the hud if we've not already
		Level = _val
		HUD.updateLevel(1,Level)					#call the HUD with the update

#Update the score function
func updateScore(_val):							#Update the score value in the HUD
	HUD = get_tree().get_nodes_in_group("HUD").front()		#keep the reference
	if HUD != null:									#get a reference to the hud if we've not already
		Score = _val									#update the score
		HUD.updateScore(1,Score)					#call the HUD with the update
#	if Score > HiScore:							#check if we have a new hi-score
#		updateHiScore(Score)					#update the hi-score value

#Update the lives function
func updateLives(_val):							#Update the player lives in the hud
	HUD = get_tree().get_nodes_in_group("HUD").front()		#keep the reference
	if HUD != null:									#get a reference to the hud if we've not already
		Lives = _val
		HUD.updateLives(1,Lives)					#call the HUD with the update

#Update the hi-score function
func updateHiScore(_val):						#Update the hi-score in the hud
	HUD = get_tree().get_nodes_in_group("HUD").front()		#keep the reference
	if HUD != null:									#get a reference to the hud if we've not already
		HiScore = _val								#update the hi-score
		HUD.updateScore(0,HiScore)					#call the HUD with the update

#Choose a random number between low and high values (type: 0 = integer, 1 = float)
func getRand_Range(_low,_high,_type,_gen = null):
	var _rng
	if !_gen:	#if a generator has not been passed create a temporary new one
		_rng = RandomNumberGenerator.new()		#Initialise a random number generator
		_rng.randomize()								#randomize the result
	else:
		_rng = _gen
	if _type == 0:								#Check if an integer is requested
		return _rng.randi_range( _low, _high)		#return a random integer between the two specified values
	else:
		return _rng.randf_range( _low, _high)		#return a random float between the two specified values

func mapScreenSize():
	Screen_Size = Vector2(get_viewport().size.x,get_viewport().size.y) 	#Get the screen size
	OSScreen_Size = OS.get_screen_size()								#Get the OS screen size
	OS.set_window_position(OSScreen_Size*0.5 - Screen_Size*0.5)	#Set the window position

##This function will check if an action has previously been pressed, if not return true. This prevents continuous firing
#func is_action_just_pressed(_action,_pressed):
#	if Input.is_action_pressed(_action):							#Check if the specific key is pressed
#		if not _pressed.has(_action) or not _pressed[_action]:		#If the key has not been previously pressed
#			_pressed[_action] = true								#Register the keypress in an array for future checking
#			return true											#Return true, this is the first time the key is pressed
#		else:
#			return false												#Return false, the key has not been pressed
#	_pressed[_action] = false									#The key is no longer pressed, remove the keypress from the array

#func compareArray(_ary1:Array,_ary2:Array) -> bool:
#	if _ary1.size() != _ary2.size():
#		return false
#	else:
#		for _i in _ary1.size():
#			if _ary1[_i] != _ary2[_i]:
#				return false
#		return true

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
		return -1
	else:
		var _grid = _get_grid(_type)
		return _grid[_pos.x][_pos.y]

#Initialise the grid to an empty array
func _initialise_grid(_type) -> void:
	var _grid = _get_grid(_type)
	_grid.clear()
	for _x in range(grid_size.x):
		var _column = []
		for _y in range (grid_size.y):
			_column.append(grid_types.EMPTY)
		_grid.append(_column)


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

	return Vector2(int(_x),int(_y))

#Return a new ID from a given array
func get_new_id(_store) -> int:
	var _new_id = 1
	while _store.has(_new_id):
		_new_id += 1
	return _new_id

#Remove an ID from an array
func remove_id(_array:Array,_id:int) -> void:
	var _index = _array.find(_id)
	_array.remove(_index)

#func wait(_secs:float):
#	yield(get_tree().create_timer(_secs),"timeout")
