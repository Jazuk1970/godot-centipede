extends Node2D
enum states{INITIALISE,STATE_READY,WAITING,SPAWN,IN_PLAY}
const mobName = "scorpion"

#Preload scenes
var oMOB = preload("res://Mobs/Scorpion/Scorpion.tscn")

#variables
onready var _timer = $Timer
var grid_position:Vector2
var _timer_active:bool = false
var _min_level:int = 3
var _max_centi_length:int = 11
var _min_time:float = 1.0
var _max_time:float = 4.0
var _chance:int = 2 # 1 in 5 change for example
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
		states.SPAWN:
			_spawn()
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
	if Globals.Level >= _min_level:
		if Globals.centipede_controller.cur_centipede_length <  _max_centi_length:
			if not _timer_active:
				_timer.start(Globals.getRand_Range(_min_time,_max_time,1))
				_timer_active = true

func _in_play() -> void:
	var _mobs = get_tree().get_nodes_in_group(mobName).size()
	if _mobs == 0:
		state = states.WAITING

func _spawn() -> void:
	randomize()
	var _new_mob = oMOB.instance()
	var _spawn_dir = Globals.dir.right if randi() % 2 == 1 else Globals.dir.left
	var _spawn_y_pos = Globals.getRand_Range(3,Globals.player_zone.position.y - 2,0)
	var _spawn_x_pos = -2 if _spawn_dir == Globals.dir.right else Globals.grid_size.x + 2
	var _spawn_pos = Vector2(_spawn_x_pos,_spawn_y_pos)
	_new_mob.grid_position = _spawn_pos
	_new_mob.name = mobName
	_new_mob._direction = _spawn_dir
	_new_mob.add_to_group(mobName)
	_new_mob.add_to_group("enemy")
	_new_mob.connect("convert_mushroom",Globals.mushroom_controller,"convertMushroom")
	self.add_child(_new_mob)
	state = states.IN_PLAY


func _on_Timer_timeout():
	var _create_new_mob = randi() % _chance == 0
	if _create_new_mob:
		state = states.SPAWN
	_timer_active = false

func _clean_up() -> void:
	var _mobs = get_tree().get_nodes_in_group(mobName)
	if _mobs != null and _mobs.size() != 0:
		for _mob in _mobs:
			_mob.queue_free()

