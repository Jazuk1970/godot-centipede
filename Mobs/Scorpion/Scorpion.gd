extends StaticBody2D
const mobName = "spider"

#signals
signal convert_mushroom(_grid_pos, _id)

onready var spr = $sprite
onready var _timer = $Timer
var points = [1000]
var _size = Vector2(16,8)
var _offset = Vector2(4,4)
var grid_position:Vector2
var _last_grid_position:Vector2
var _direction:Vector2
var _speed:int = 60
var _max_mushrooms_to_add_in_one_pass:int = 0
var _mushrooms_added:int = 0
var _min_time:float = 0.04
var _max_time:float = 0.8
var animtime:float
var animrate:float = 0.3
var startframe:int
var curframe:int = 0
var totalframes:int = 4
var _frames:Array = [0,1,2,3]
var hit:bool = false
var _sound = "sfx_scorpion"
var _sound_delay:int

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	position = Globals.grid_to_world(grid_position) + _offset
	var _speed_adjustment = clamp(abs(Globals.Score  / 5000),0,50)
	_speed += _speed_adjustment
	
func _process(_delta):
	var _next_position = position + _direction * _speed * _delta
	var _space_state = get_world_2d().direct_space_state
	var _result = _space_state.intersect_ray(position,_next_position,[self],collision_mask)
	if _result.size() == 0:
		position = _next_position
		grid_position = Globals.world_to_grid(position)
		if _last_grid_position != grid_position:
			_convert_mushroom()
			_last_grid_position = grid_position
		if _direction == Globals.dir.right and grid_position.x > Globals.grid_size.x + 1 \
		or _direction == Globals.dir.left and grid_position.x < - 1:
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

func _convert_mushroom() -> void:
	if grid_position.x >= Globals.grid_size.x or grid_position.x < 0:
		return
	var _cell_value:int
	_cell_value = Globals.grid_get_cell(grid_position - Vector2(0,0), Globals.grid_types.MUSHROOM)
	if _cell_value != Globals.grid_types.EMPTY and _cell_value > 0:
		emit_signal("convert_mushroom",_cell_value)


func _hit():
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
	spr.flip_h = false if _direction.x < 0 else true
	animtime += _delta
	if animtime > animrate:
		curframe = (curframe +1) % totalframes
		spr.frame = _frames[startframe + curframe]
		animtime = 0

func _play_sound():
	_sound_delay += 1
	if _sound_delay >= 64:
		Globals.SFX.play(_sound,-10.0)
		_sound_delay = 0
