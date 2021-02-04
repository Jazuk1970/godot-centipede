extends StaticBody2D
const mobName = "flea"
signal create_mushroom(_type,_pos)
onready var spr = $sprite
onready var _timer = $Timer
var points = [200]
var _size = Vector2(16,8)
var _offset = Vector2(4,4)
var grid_position:Vector2
var _last_grid_position:Vector2
var _direction:Vector2
var _speed:int
var _speeds:Array = [200,100]
var _speed_adjustment:int = 0
var _max_mushrooms_to_add_in_one_pass:int = 8
var _mushrooms_added:int = 0
var _min_time:float = 0.06
var _max_time:float = 1.4
var _min_y_grid_pos:int = 7
var hit:bool = false
var _health:int = 2
var animtime:float
var animrate:float = 0.3
var startframe:int
var curframe:int = 0
var totalframes:int = 2
var _frames:Array = [0,1]
var _sound = "sfx_flea"
var _sound_delay:int

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	_direction = Globals.dir.down
	position = Globals.grid_to_world(grid_position) + _offset
	_speed_adjustment = 50 if Globals.Score > 60000 else 0
	

func _process(_delta):
	if _health > 0:
		_speed = _speeds[_health -1] + _speed_adjustment
	else:
		_speed = _speeds[0] + _speed_adjustment
	var _next_position = position + _direction * _speed * _delta
	var _space_state = get_world_2d().direct_space_state
	var _result = _space_state.intersect_ray(position,_next_position,[self],collision_mask)
	if _result.size() == 0:
		position = _next_position
		_last_grid_position = grid_position
		grid_position = Globals.world_to_grid(position + _offset)
		if grid_position.y < Globals.ymaxline and grid_position.y > _min_y_grid_pos:
			if _mushrooms_added < _max_mushrooms_to_add_in_one_pass and _timer.is_stopped():
				var _time_adjust = Globals.getRand_Range(0.2,0.6,1)
				_timer.start(Globals.getRand_Range(_min_time * _time_adjust,_max_time * _time_adjust,1))
		if grid_position.y > Globals.ymaxline + 1:
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
	_timer.stop()
	_create_new_mushroom()

func _create_new_mushroom() -> void:
	if grid_position.y >= Globals.ymaxline or grid_position.y < 1:
		return
	var _cell_value:int
	_cell_value = Globals.grid_get_cell(grid_position - Vector2(1,0), Globals.grid_types.MUSHROOM)
	if _cell_value == Globals.grid_types.EMPTY:
		emit_signal("create_mushroom",Globals.mushroom_types.NORMAL,grid_position - Vector2(1,0))
		_mushrooms_added += 1

func _hit():
	hit = false
	_health -= 1
	if _health <= 0:
		Globals.Score += points[0]
		queue_free()

func _check_collider(_collider):
	var _group = _collider.get_groups()
	if _group.has("player"):
			_collider.hit(self)
			queue_free()

func _animate(_delta):
	if _direction == Globals.dir.none:
		return
	animtime += _delta
	if animtime > animrate:
		curframe = (curframe +1) % totalframes
		spr.frame = _frames[startframe + curframe]
		animtime = 0

func _play_sound():
	_sound_delay += 1
	if _sound_delay == 16:
		Globals.SFX.play(_sound,-10.0)
