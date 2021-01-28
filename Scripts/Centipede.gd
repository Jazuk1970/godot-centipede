extends Node2D


var centipede:Array = []
var ID:int
#var length:int
var speed:int
var state:int
enum states{UNKNOWN,SPAWNING,ALIVE,DEAD}

var curdir:Vector2


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#Spawn a new centipede off screen and set up the positions of each centipod
func spawn(_pos:Vector2,_len:int,_init_dir,_spawn_dir):
	var _neighbour:Node = null
	var _result:int
	for _centipod_ID in range (_len):
		var _centipod = objCenti.instance()
		if _centipod_ID == 0:
			_centipod.head = true
			_centipod.startframe = 4
		else:
			_centipod.head = false
			_centipod.startframe = 0
		_centipod.tgtdir = _init_dir
		_centipod.spawn_dir = _spawn_dir
		_centipod.curdir = _spawn_dir
		_centipod.curframe = _centipod_ID  % _centipod.totalframes
		_centipod.position.y = _pos.y - (_centipod_ID * _centipod.size.y) + _centipod.offset.y
		_centipod.position.x = _pos.x + _centipod.offset.y
		_centipod.name = "centi_"+str(ID)+"_"+str(_centipod_ID)
		_centipod.parent = self
		_centipod.centi_pod_ID = _centipod_ID
		_centipod.centipede_ID = ID
		_centipod.speed = speed
		_centipod.add_to_group("centipod")
		_result = _centipod.connect("create_mushroom",Globals.mushroom_controller,"createMushroom")
		if _neighbour != null:
			_result = _neighbour.connect("update_neighbour_pos",_centipod,"_on_signal_update_neighbour_pos")
#			_neighbour.connect("update_neighbour_dir",_centipod,"_on_signal_update_neighbour_dir")
			_neighbour.next_neighbour = _centipod
			_centipod.prev_neighbour = _neighbour
		_neighbour = _centipod
		centipede.append(_centipod)
		self.add_child(_centipod)	 # this adds to the scence.. can this be done as a group?

		#DEBUG CODE ONLY####################
		if curdir == Globals.dir.left:
			_centipod.modulate = Color8(155,155,255)
		####################################
#	state = states.SPAWNING
	

