extends Node2D
export (PackedScene) var objCenti

var centipods:Array = []
var centipod_ids:Array = []


#Level data
var max_centipede_length:int = 12
var cur_centipedes_on_level:int
var cur_centipede_length:int

var normal_speed:int = 1
var fast_speed:int = 2

var spawndir:Vector2 = Globals.dir.down
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
	centipod_ids.clear()


func _process(delta):
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
		_createcentipede(_length,spawndir,tgtdir,_speed,_update_rate)
		cur_centipedes_on_level -= 1
		tgtdir.x *= -1
		$Timer.start(_spawn_delay)

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


func _createcentipede(_len,_spawn_dir,_tgt_dir,_speed,_update_rate):
	var _pos = Vector2(128,-32)	#spawn position?? possibly change for variable so single centis can be spawned later in the game
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
		_centipod.speed = _speed
		_centipod.add_to_group("centipod")
		_result = _centipod.connect("create_mushroom",Globals.mushroom_controller,"createMushroom")
		if _neighbour != null:
			_result = _neighbour.connect("update_neighbour_pos",_centipod,"_on_signal_update_neighbour_pos")
			_neighbour.next_neighbour = _centipod
			_centipod.prev_neighbour = _neighbour
		_neighbour = _centipod
		centipods.append(_centipod)
		self.add_child(_centipod)

		#DEBUG CODE ONLY####################
		if spawndir == Globals.dir.left:
			_centipod.modulate = Color8(155,155,255)
		####################################

func reset_level():
	centipod_ids.clear()
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
	var _new_id = 1
	while centipod_ids.has(_new_id):
		_new_id += 1
	centipod_ids.append(_new_id)
	return _new_id

