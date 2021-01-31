extends Node2D
enum states{INITIALISE,STATE_READY,WAITING,SPAWN_FLEA,IN_PLAY}

#Preload scenes
var oFlea = preload("res://Scenes/Flea.tscn")

#variables
onready var _timer = $Timer
var _timer_active:bool = false
var _min_active_level:int = 2
var _min_mushrooms_for_active:int = 400
var _min_time_for_flea_appear:float = 2.0
var _max_time_for_flea_appear:float = 6.0
var _chance_for_flead_to_appear:int = 2 # 1 in 5 change for example
var state:int

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	
func _process(_delta):
	match state:
		states.INITIALISE:
			_initialise()
		states.STATE_READY:
			_state_ready()
		states.WAITING:
			_waiting()
		states.SPAWN_FLEA:
			_spawn_flea()
		states.IN_PLAY:
			_in_play()

func _initialise() -> void:
	_clean_up()
	_timer.stop()
	_timer_active = false
	_timer.one_shot = true
	state = states.STATE_READY

func _state_ready() -> void:
	if Globals.game_controller.state == Globals.game_controller.states.IN_PLAY:
		state = states.WAITING

func _waiting() -> void:
	if Globals.Level >= _min_active_level:
		if Globals.no_of_mushrooms <  _min_mushrooms_for_active:
			if not _timer_active:
				_timer.start(Globals.getRand_Range(_min_time_for_flea_appear,_max_time_for_flea_appear,1))
				_timer_active = true

func _in_play() -> void:
	var _fleas = get_tree().get_nodes_in_group("flea").size()
	if _fleas == 0:
		state = states.WAITING

func _spawn_flea() -> void:
	var _new_flea = oFlea.instance()
	var _spawn_x_coord = Globals.getRand_Range(0,Globals.grid_size.x -1,0)
	var _spawn_pos = Vector2(_spawn_x_coord, -2)
	_new_flea.grid_position = _spawn_pos
	_new_flea.name = "flea"
	_new_flea.add_to_group("flea")
	_new_flea.add_to_group("enemy")

	_new_flea.connect("create_mushroom",Globals.mushroom_controller,"createMushroom")
	self.add_child(_new_flea)
	state = states.IN_PLAY

func _on_Timer_timeout():
	var _create_new_flea = randi() % _chance_for_flead_to_appear == 0
	if _create_new_flea:
		state = states.SPAWN_FLEA
	_timer_active = false

func _clean_up() -> void:
	var _fleas = get_tree().get_nodes_in_group("flea")
	if _fleas != null and _fleas.size() != 0:
		for _flea in _fleas:
			_flea.queue_free()

