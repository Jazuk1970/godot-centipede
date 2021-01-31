extends Node2D
export (PackedScene) var objCenti
enum states{INITIALISE,STATE_READY,RESET_CENTIPEDE,SPAWN,IN_PLAY,LEVEL_UP}
onready var spawn_delay = $spawn_delay
onready var side_spawn_delay = $side_spawn_delay
var centipods:Array = []
var centipede_ids:Array = []


#Level data
var max_centipede_length:int = 12
var centipedes_to_spawn:int
var cur_centipedes_on_level:int
var cur_centipede_length:int

var normal_speed:int = 1
var fast_speed:int = 2

var top_spawn_dir:Vector2 = Globals.dir.down
var top_spawn_pos:Vector2
var side_spawn_pos:Vector2
var side_spawn_dir:Vector2 = Globals.dir.right
var side_spawn_delay_time:float = 10.0
var side_spawn_delay_active:bool = false
var spawn_delay_active:bool = false
var tgtdir:Vector2 = Globals.dir.downright
var state:int

#possibly remove these
var updateTime:float =0.50  #not needed...
var curTime:float #not needed...
var _centipedespawning:bool = false #prob not needed.


#Initialisation
func _ready():
	set_process(true)
	top_spawn_pos = Vector2(Globals.grid_size.x / 2,-4)
	side_spawn_pos =Vector2(-1,Globals.ymidline)

func _process(_delta):
#	if not Globals.READY:
#		return
	match state:
		states.INITIALISE:
			_initialise()
		states.RESET_CENTIPEDE:
			_reset_centipede()			
		states.STATE_READY:
			_state_ready()
		states.SPAWN:
			_spawn()
		states.IN_PLAY:
			_in_play()
		states.LEVEL_UP:
			_level_up()

func _initialise() -> void:
	cur_centipedes_on_level = 1
	cur_centipede_length = max_centipede_length
	state = states.RESET_CENTIPEDE

func _level_up() -> void:
	if cur_centipede_length == 1:
		cur_centipede_length = max_centipede_length
		cur_centipedes_on_level = 1
	else:
		cur_centipede_length -= 1
		cur_centipedes_on_level += 1
	state =	states.RESET_CENTIPEDE

func _reset_centipede() -> void:
	_clean_up()
	spawn_delay.stop()
	spawn_delay_active = false
	side_spawn_delay.stop()
	side_spawn_delay_active = false
	centipede_ids.clear()
	centipods.clear()
	Globals.no_of_centipedes = 0
	centipedes_to_spawn = cur_centipedes_on_level
	state =	states.STATE_READY
	
func _state_ready() -> void:
	if Globals.game_controller.state == Globals.game_controller.states.IN_PLAY:
		state = states.SPAWN
		
func _spawn() -> void:
	if centipedes_to_spawn > 0:
		if not spawn_delay_active:
			var _speed:int
			var _length:int
			var _spawn_delay:float
			var _update_rate:float
			if Globals.no_of_centipedes == 0:
				_speed = normal_speed
				_length = cur_centipede_length
				_spawn_delay = 0.5
			else:
				_speed = fast_speed
				_length = 1
				_spawn_delay = 0.1
			Globals.no_of_centipedes += 1
			createcentipede(top_spawn_pos,_length,top_spawn_dir,tgtdir,_speed)
			centipedes_to_spawn -= 1
			tgtdir.x *= -1
			spawn_delay_active = true
			spawn_delay.start(_spawn_delay)
	else:
		state = states.IN_PLAY

func _in_play() -> void:
	pass


func createcentipede(_grid_pos,_len,_spawn_dir,_tgt_dir,_speed,_update_rate:float = 0.0):
	var _pos = Globals.grid_to_world(_grid_pos)
	var _neighbour:Node = null
	var _result:int
	var _ID:int = get_new_id()
	for _centipod_ID in range (_len):
		var _centipod = objCenti.instance()
		if _centipod_ID == 0:
			_centipod.head = true
			_centipod.startframe = 4
		else:
			_centipod.head = false
			_centipod.startframe = 0
		_centipod.tgtdir = _tgt_dir
		_centipod.updaterate = _update_rate
		_centipod.spawn_dir = _spawn_dir
		_centipod.curframe = _centipod_ID  % _centipod.totalframes
		_centipod.position.y = _pos.y - (_centipod_ID * _centipod.size.y) + _centipod.offset.y
		_centipod.position.x = _pos.x + _centipod.offset.y
		_centipod.name = "centi_"+str(_ID)+"_"+str(_centipod_ID)
		_centipod.parent = self
		_centipod.centi_pod_ID = _centipod_ID
		_centipod.centipede_ID = _ID
		_centipod.normal_speed = _speed
		_centipod.add_to_group("centipod")
		_centipod.add_to_group("enemy")
		_result = _centipod.connect("create_mushroom",Globals.mushroom_controller,"createMushroom")
		_result = _centipod.connect("create_new_centipod",self,"create_new_centipod")
		if _neighbour != null:
			_result = _neighbour.connect("update_neighbour_pos",_centipod,"_on_signal_update_neighbour_pos")
			_neighbour.next_neighbour = _centipod
			_centipod.prev_neighbour = _neighbour
		_neighbour = _centipod
		centipods.append(_centipod)
		self.add_child(_centipod)

#func reset_level():
#	centipede_ids.clear()
#	centipods.clear()
#	if cur_centipede_length == 1:
#		cur_centipede_length = max_centipede_length
#		cur_centipedes_on_level = 1
#		Globals.no_of_centipedes = 0
#	else:
#		cur_centipede_length -= 1
#		cur_centipedes_on_level = Globals.no_of_centipedes + 1
#		Globals.no_of_centipedes = 0
#	Globals.Level += 1

#Get a unique ID for the centipede and used for all its children
func get_new_id() -> int:
	var _new_id = Globals.get_new_id(centipede_ids)
	centipede_ids.append(_new_id)
	return _new_id

func create_new_centipod()-> void:
	createcentipede(side_spawn_pos,1,side_spawn_dir,Globals.dir.downright,normal_speed)
	side_spawn_delay.start(clamp(1 * Globals.no_of_centipods,1,side_spawn_delay_time))
	side_spawn_delay_active = true


func _on_Timer_timeout():
	spawn_delay_active = false


func _on_side_spawn_delay_timeout():
	side_spawn_delay_active = false

func _clean_up() -> void:
	var _centipods = get_tree().get_nodes_in_group("centipod")
	if _centipods.size() != 0 and _centipods != null:
		for _centipod in _centipods:
			_centipod.queue_free()
	Globals._initialise_grid(Globals.grid_types.CENTIPOD)
