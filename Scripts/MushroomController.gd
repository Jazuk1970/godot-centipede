extends Node2D
#Enums & Constants
enum states{INITIALISE,STATE_READY,IN_PLAY,REGENERATION}
#signals
signal regenerate()

#Preload scenes
var oMushroom = preload("res://Scenes/Mushroom.tscn")

#Variables
# warning-ignore:unused_variable
var player_zone = Vector2(Globals.grid_size.y -10,Globals.grid_size.y - 1)
var state:int
var regenerating:bool = false
var regen_done:bool = false
var regen_delay = 0.05

var totalMushrooms = 50		#this should come from the level data
#var mushroomGridSize:int = 8 	#The mushroom grid spacing in pixels
#var mushroom_ids:Array = []
var mushrooms:Dictionary = {}
#var mushrooms_vectors:Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	Globals.no_of_mushrooms = 0
	var _result = self.connect("regenerate",self,"_regenerate")


func _process(_delta):
#	if not Globals.READY:
#		return
	match state:
		states.INITIALISE:
			_initialise()
		states.STATE_READY:
			_state_ready()
		states.REGENERATION:
			_regeneration()
		states.IN_PLAY:
			_in_play()


func _initialise():
	var horizontal_limits = Vector2(1,Globals.grid_size.x - 2)
	var vertical_limits = Vector2(2,Globals.grid_size.y -10)
	var _poisoned:bool
	_clean_up()
	for _mr in range(totalMushrooms):
		_poisoned = (randi() % 3 == 2)
		if _poisoned:
			createMushroom(Globals.mushroom_types.POISON,getUnusedPos(horizontal_limits,vertical_limits))
		else:		
			createMushroom(Globals.mushroom_types.NORMAL,getUnusedPos(horizontal_limits,vertical_limits))
	state = states.STATE_READY

func _state_ready() -> void:
	if Globals.game_controller.state == Globals.game_controller.states.IN_PLAY:
		state = states.IN_PLAY
		
func _regeneration() -> void:
	if not regenerating:
		regenerating = true
		regen_done = false
		emit_signal("regenerate")
	else:
		if regen_done:
			regenerating = false
			regen_done = false
			state = states.STATE_READY

func _regenerate() -> void:
#	get_tree().paused = true
	var _mushrooms = get_tree().get_nodes_in_group("mushroom")
	var _score_update_required:bool
	for _mr in _mushrooms:
		if _mr != null:
			if _mr.mushroom_type == Globals.mushroom_types.POISON:
				_mr.mushroom_type = Globals.mushroom_types.NORMAL
				_mr.setFrame(_mr.curFrame)
			_score_update_required = false
			while _mr.curFrame !=0:
				_score_update_required = true
				_mr.curFrame -= 1
				_mr.setFrame(_mr.curFrame)
				yield(get_tree().create_timer(regen_delay),"timeout")
			if _score_update_required:
				Globals.Score += _mr.points[4]
	regen_done = true
#	get_tree().paused = false


func _in_play() -> void:
	pass


#Create a mushroom of the given type, at the given position and ID
func createMushroom(type = Globals.mushroom_types.NORMAL,_grid_pos = Vector2.ZERO):
	var _pos = Globals.grid_to_world(_grid_pos)
	var _mushroom = oMushroom.instance()
	_mushroom.position = _pos
	_mushroom.mushroom_type = type
	_mushroom.ID = get_new_id()
	_mushroom.name = "mushroom_" + str(_mushroom.ID)
	_mushroom.add_to_group("mushroom")
	_mushroom.grid_pos = _grid_pos
	self.add_child(_mushroom)
	mushrooms[_mushroom.ID] = _mushroom
	Globals.grid_set_cell(_grid_pos,Globals.grid_types.MUSHROOM,_mushroom.ID)
	Globals.no_of_mushrooms += 1


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
	var _new_id = Globals.get_new_id(mushrooms)
	mushrooms[_new_id] = null
	return _new_id

func _clean_up() -> void:
	var _mushrooms = get_tree().get_nodes_in_group("mushroom")
	if _mushrooms != null and _mushrooms.size() != 0:
		for _mushroom in _mushrooms:
			_mushroom.queue_free()
	Globals._initialise_grid(Globals.grid_types.MUSHROOM)
