extends Node2D
export (PackedScene) var objCenti

var centipods:Array = []
var centipede_ids:Array = []


#Level data
var max_centipede_length:int = 12
var cur_centipedes_on_level:int
var cur_centipede_length:int

var normal_speed:int = 2
var fast_speed:int = 4

var top_spawn_dir:Vector2 = Globals.dir.down
var top_spawn_pos:Vector2
var side_spawn_pos:Vector2
var side_spawn_dir:Vector2 = Globals.dir.right
var side_spawn_delay_time:float = 10.0
var side_spawn_delay_active:bool = false
var tgtdir:Vector2 = Globals.dir.downright


#possibly remove these
var updateTime:float =0.50  #not needed...
var curTime:float #not needed...
var _centipedespawning:bool = false #prob not needed.


#Initialisation
func _ready():
	cur_centipedes_on_level = 1
	Globals.no_of_centipedes = 0
	cur_centipede_length = max_centipede_length
#	centipede_ids.clear()
	centipods.clear()
	top_spawn_pos = Vector2(Globals.grid_size.x / 2,-4)
	side_spawn_pos =Vector2(-1,Globals.ymidline)


func _process(delta):
	if not Globals.READY:
		return
	if cur_centipedes_on_level > 0 and $Timer.is_stopped() and Globals.mushroom_controller:
		var _speed:int
		var _length:int
		var _spawn_delay:float
		var _update_rate:float
		if Globals.no_of_centipedes == 0:
			_speed = normal_speed
			_length = cur_centipede_length
#			_spawn_delay = randi() % 2 + (1 + randf())
			_spawn_delay = 0.5
		else:
			_speed = fast_speed
			_length = 1
			_spawn_delay = 0.1
		Globals.no_of_centipedes += 1
		createcentipede(top_spawn_pos,_length,top_spawn_dir,tgtdir,_speed)
		cur_centipedes_on_level -= 1
		tgtdir.x *= -1
		$Timer.start(_spawn_delay)
	return delta
	#TODO: add some code here to scan all centis and check for valid ID's etc removing old ones from the list as required.
	#TODO: add code to check if centi has fully spawned
#
#	curTime += delta
#	if curTime >= updateTime:
#		curTime -= updateTime
#		_centipedespawning = false
#		for _centipede in centipedes:
#			if _centipede.state == _centipede.states.SPAWNING:
#				_centipedespawning = true

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
		_result = _centipod.connect("create_mushroom",Globals.mushroom_controller,"createMushroom")
		_result = _centipod.connect("create_new_centipod",self,"create_new_centipod")
		if _neighbour != null:
			_result = _neighbour.connect("update_neighbour_pos",_centipod,"_on_signal_update_neighbour_pos")
			_neighbour.next_neighbour = _centipod
			_centipod.prev_neighbour = _neighbour
		_neighbour = _centipod
		centipods.append(_centipod)
		self.add_child(_centipod)

func reset_level():
	centipede_ids.clear()
	centipods.clear()
	if cur_centipede_length == 1:
		cur_centipede_length = max_centipede_length
		cur_centipedes_on_level = 1
		Globals.no_of_centipedes = 0
	else:
		cur_centipede_length -= 1
		cur_centipedes_on_level = Globals.no_of_centipedes + 1
		Globals.no_of_centipedes = 0

#Get a unique ID for the centipede and used for all its children
func get_new_id() -> int:
	var _new_id = Globals.get_new_id(centipede_ids)
	centipede_ids.append(_new_id)
	return _new_id

func create_new_centipod()-> void:
	createcentipede(side_spawn_pos,1,side_spawn_dir,Globals.dir.downright,fast_speed)
	$side_spawn_delay.start(clamp(1 * Globals.no_of_centipods,1,side_spawn_delay_time))
	side_spawn_delay_active = true
	

func _on_side_spawn_delay_timeout():
	side_spawn_delay_active = false
