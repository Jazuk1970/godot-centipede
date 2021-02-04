extends StaticBody2D
const mobName = "scorpion"

#Preload scenes
var oMOB = preload("res://Items/PointDisplay/PointDisplay.tscn")

#signals
signal remove_mushroom(_grid_pos, _id)

onready var spr = $sprite
onready var _timer = $Timer
var points = [900,600,300]
var _size = Vector2(16,8)
var _offset = Vector2(4,4)
var grid_position:Vector2
var _last_grid_position:Vector2
var _miny:float
var _maxy:float
var _direction:Vector2
var _last_direction:Vector2
var _target_direction:Vector2	#target either left to right, or right to left
var _travel_time:float
var _travel_times = {
	Vector2(-1,-1):[0.9,1.8],Vector2(1,-1):[0.8,2.1],
	Vector2(-1,1):[0.9,1.1],Vector2(1,1):[1.2,1.9],
	Vector2(0,-1):[0.2,0.7],Vector2(0,1):[0.3,0.8],
	Vector2(0,0):[0.0,0.2]}
var _zone_adjustments:Array = [0,0]
var _speed:int = 40
var _speeds = [0,0]
var _max_mushrooms_to_add_in_one_pass:int = 0
var _mushrooms_added:int = 0
var _min_time:float = 0.5
var _max_time:float = 1.0
var animtime:float
var animrate:float = 0.1
var startframe:int
var curframe:int = 0
var totalframes:int = 8
var _frames:Array = [1,0,2,3,4,3,2,0]
var hit:bool = false
var _sound = "sfx_spider"
var _sound_delay:int

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	position = Globals.grid_to_world(grid_position) + _offset
	if Globals.Score > 60000:
		_zone_adjustments[0] = -4
		_zone_adjustments[1] = -1
	else:
		_zone_adjustments[0] = -8
		_zone_adjustments[1] = -3
	if Globals.Score > 5000:
		_speeds[0] = 50
		_speeds[1] = 90
	else:
		_speeds[0] = 30
		_speeds[1] = 60
	
	_miny = Globals.grid_to_world(Globals.player_zone.position + Vector2(0,_zone_adjustments[0])).y
	_maxy = Globals.grid_to_world(Globals.player_zone.end + Vector2(0,_zone_adjustments[1])).y

func _process(_delta):
	if _direction == Vector2.ZERO and _timer.is_stopped():
		_direction = _get_new_direction()
		var _min = _travel_times[_direction][0]
		var _max = _travel_times[_direction][1]
		_speed = Globals.getRand_Range(30,60,0)
		_travel_time = Globals.getRand_Range(_min,_max,1)
		_timer.start(_travel_time)
		_last_direction = _direction

	var _next_position = position + _direction * _speed * _delta
	if _next_position.y < _miny or _next_position.y > _maxy:
		_direction.y *= -1
		_next_position = position + _direction * _speed * _delta
	var _space_state = get_world_2d().direct_space_state
	var _result = _space_state.intersect_ray(position,_next_position,[self],collision_mask)
	if _result.size() == 0:
		position = _next_position
		grid_position = Globals.world_to_grid(position)
		if _last_grid_position != grid_position:
			_remove_mushroom()
			_last_grid_position = grid_position
		if _direction.x == Globals.dir.right.x and grid_position.x > Globals.grid_size.x + 1 \
		or _direction.x == Globals.dir.left.x and grid_position.x < - 1:
			queue_free()
	else:
		var _collider = _result.collider
		position = _collider.position
		_check_collider(_collider)
	if hit:
		_hit()
	_animate(_delta)
	_play_sound()




func _on_Timer_timeout():
	_direction = Vector2.ZERO
	_timer.stop()

func _remove_mushroom() -> void:
	if grid_position.x >= Globals.grid_size.x or grid_position.x < 0:
		return
	var _cell_value:int
	_cell_value = Globals.grid_get_cell(grid_position - Vector2(0,0), Globals.grid_types.MUSHROOM)
	if _cell_value != Globals.grid_types.EMPTY and _cell_value > 0:
		emit_signal("remove_mushroom",_cell_value)
	_cell_value = Globals.grid_get_cell(grid_position - Vector2(1,0), Globals.grid_types.MUSHROOM)
	if _cell_value != Globals.grid_types.EMPTY and _cell_value > 0:
		emit_signal("remove_mushroom",_cell_value)


func _hit():
	var _dist_from_player = int((Globals.player_controller.position.y - position.y) / Globals.grid_cell_size.y)
	var _point_index:int
	match _dist_from_player:
		0,1,2:
			_point_index = 0
		3,4,5:
			_point_index = 1
		_:
			_point_index = 2
	Globals.Score += points[_point_index]
	var _mob = oMOB.instance()
	_mob.position = position
	_mob.points = points[_point_index]
	Globals.spider_controller.add_child(_mob)
	queue_free()

func _check_collider(_collider):
	var _group = _collider.get_groups()
	if _group.has("player"):
			_collider.hit(self)
			queue_free()

func _animate(_delta):
	if _direction == Globals.dir.none:
		return
	spr.flip_h = false if _direction.x < 0 else true
	animtime += _delta
	if animtime > animrate:
		curframe = (curframe +1) % totalframes
		spr.frame = _frames[startframe + curframe]
		animtime = 0

func _play_sound():
	_sound_delay += 1
	if _sound_delay >= 16:
		Globals.SFX.play(_sound,-15.0)
		_sound_delay = 0


func _get_new_direction() -> Vector2:
	var _rnd = RandomNumberGenerator.new()
	_rnd.randomize()
	var _vertdir = _rnd.randi() % 3 -1
	_vertdir = _vertdir * -1 if _vertdir == _last_direction.y else _vertdir
	var _horizdir = _rnd.randi() % 2
	if _vertdir == 0:
		return Vector2.ZERO
	else:
		_horizdir = _target_direction.x * _horizdir
		_horizdir = 0 if _horizdir == -0 else _horizdir
		return Vector2(_horizdir,_vertdir)
