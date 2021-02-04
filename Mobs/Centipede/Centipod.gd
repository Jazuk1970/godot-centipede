extends Node2D
onready var spr = $Area2D/sprite
onready var body = $Area2D/body
#export (Font) var font
signal update_neighbour_pos(_pos,_dir)
signal create_mushroom(_type,_pos)
signal create_new_centipod()
enum pod_types{NORMAL,POISON}
enum states{SPAWNING,ALIVE,DEAD}


export (Color) var colour_normal = Color8(0,255,0,255)
export (Color) var colour_poison = Color8(150,0,150,255)


var points = [10,100]
var centipede_ID:int
var new_centipede_ID:int
var centi_pod_ID:int
var type:int
var parent:Node
var next_neighbour:Node = null
var prev_neighbour:Node = null
var neighbour_position:Array = []
var neighbour_dir:Array = []
var neighbour_type:Array = []

var startframe:int
var curframe:int = 0
var totalframes:int = 4
var time_in_frame:int = 1
var cur_frame_time:int
var updatetime:float
var updaterate:float = 0.00
var animtime:float
var animrate:float = 0.3
var _frames:Array = [0,1,2,3,4,5,6,7]

var size = Vector2(8,8)
var offset = Vector2(4,4)

var grid_position:Vector2

var curdir:Vector2
var nextdir:Vector2

var tgtdir:Vector2
var tgtpos:Vector2 = Vector2.INF
var spawn_dir:Vector2


var head:bool
var convert_to_head:bool
var hit:bool
var pod_type:int = pod_types.NORMAL
var next_pod_type:int
var speed:int = 1
var normal_speed:int = 1
var poison_speed:int = 2
var state:int
var max_pods:int = 50


#Initialisation
func _ready():
	set_physics_process(true)
	spr.frame = startframe + curframe
	state = states.SPAWNING
	curdir = spawn_dir
	neighbour_dir = []
	neighbour_position = []
	cur_frame_time = 0
	grid_position = Globals.world_to_grid(position - offset)
	type = Globals.grid_types.CENTIPOD


# warning-ignore:narrowing_conversion
	poison_speed = clamp(int(normal_speed) * 2,1,4)


func _physics_process(delta):
	updatetime += delta
	if updatetime >= updaterate:
		if cur_frame_time == 0:
			speed = normal_speed if pod_type == pod_types.NORMAL or curdir.y == 0 else poison_speed
			time_in_frame = size.x / speed
			if convert_to_head:
				_convert_to_head()
			elif hit:
				_hit()
				return
		if head:
			_movehead(delta)
		else:
			_move(delta)
		updatetime = 0

	if curdir != Globals.dir.none:
		_animate(delta)

func _movehead(_delta):
	var _vertical_move_done:bool
	var _last_grid_position:Vector2
	match state:
		states.SPAWNING:
			curdir = spawn_dir
			position += curdir * speed
			grid_position = Globals.world_to_grid(position - offset)
			if _check_grid_cell_free(grid_position,type,centipede_ID) and grid_position.y > 0:
				state = states.ALIVE
				cur_frame_time = 0
				Globals.grid_set_cell(grid_position,type,centipede_ID)
		states.ALIVE:
			if cur_frame_time == 0:		#decision point for direction checking
				var _cell_value:int
				_cell_value = Globals.grid_get_cell(grid_position, Globals.grid_types.MUSHROOM)
				if _cell_value != Globals.grid_types.EMPTY and _cell_value > 0:
					if _check_mushroom_type(_cell_value) == Globals.mushroom_types.POISON:
						pod_type = pod_types.POISON

				if pod_type == pod_types.POISON:
					if grid_position.y >= Globals.grid_size.y -2:
						pod_type = pod_types.NORMAL
					else:
						tgtdir.y = 1
				_last_grid_position = grid_position
				grid_position = Globals.world_to_grid(position - offset)
				if !_check_grid_cell_free(grid_position + curdir,type,centipede_ID) or (pod_type == pod_types.POISON and curdir.x != 0):
					curdir = _change_direction(grid_position,curdir)
					_update_neighbour_pos()

				elif curdir.y != 0: #check if the current vertical movement is complete
					curdir = _change_direction(grid_position,curdir)
					_update_neighbour_pos()

#				#Update the grid
#				if 	Globals.grid_get_cell(_last_grid_position,type) == centipede_ID:
#					Globals.grid_set_cell(_last_grid_position,type,Globals.grid_types.EMPTY)	#Clear the old grid position for this pod
				position += curdir * speed	#update the position
				grid_position = Globals.world_to_grid(position - offset)
#				if 	Globals.grid_get_cell(grid_position,type) == Globals.grid_types.EMPTY:
#					Globals.grid_set_cell(grid_position,type,centipede_ID)
				_update_grid(grid_position,_last_grid_position,type,centipede_ID)


			else:
				position += curdir * speed
			cur_frame_time = (cur_frame_time + 1) % time_in_frame
#			update()
#
#
#		states.dead:
#			#TODO // create a mushroom at this grid position
#			#ToDO // split the centipede??
#			queue_free()
#	_updategridposition()


func _move(_delta):
	var _last_grid_position:Vector2
	if tgtpos == Vector2.INF:
		if !neighbour_position.empty():
			tgtpos = neighbour_position.pop_front()
			nextdir = neighbour_dir.pop_front()
			next_pod_type = neighbour_type.pop_front()

	if cur_frame_time == 0:
		_last_grid_position = grid_position
		grid_position = Globals.world_to_grid(position - offset)
		if pod_type == pod_types.POISON:
			if grid_position.y >= Globals.grid_size.y -2:
				pod_type = pod_types.NORMAL

		if tgtpos == grid_position:
			curdir = nextdir
			pod_type = next_pod_type
			if !neighbour_position.empty():
				tgtpos = neighbour_position.pop_front()
				nextdir = neighbour_dir.pop_front()
				next_pod_type = neighbour_type.pop_front()

			else:
				tgtpos = Vector2.INF
			_update_neighbour_pos()
		position += curdir * speed
		grid_position = Globals.world_to_grid(position - offset)
		_update_grid(grid_position,_last_grid_position,type,centipede_ID)
	else:
		position += curdir * speed
	cur_frame_time = (cur_frame_time + 1) % time_in_frame
	if prev_neighbour != null:
		pod_type  =prev_neighbour.pod_type

func _animate(_delta):
	if pod_type == pod_types.POISON:
		body.modulate = colour_poison
	else:
		body.modulate = colour_normal
	spr.flip_h = true if curdir.x < 0 else false
	spr.rotation_degrees = 90 * curdir.y
	animtime += _delta
	if animtime > animrate:
		curframe = (curframe +1) % totalframes
		spr.frame = _frames[startframe + curframe]
		animtime = 0


func _change_direction(_pos,_dir) -> Vector2:
	var _next_dir:Vector2
	if _pos.x < 0:
		_next_dir = Vector2.RIGHT
		tgtdir.x = 1
	elif _pos.x > Globals.grid_size.x:
		_next_dir = Vector2.LEFT
		tgtdir.x = -1
	elif _pos.y < 0 and states == states.ALIVE:
		_next_dir = Vector2.DOWN
		tgtdir.y = 1
	elif _pos.y > Globals.grid_size.y:
		_next_dir = Vector2.UP
		tgtdir.y = -1
	if _next_dir:
		return _next_dir
	match _dir:
		#we are currently travelling down
		Vector2.DOWN:
			#we were going down and now choose the next desired left/right direction
			_next_dir = tgtdir * Vector2.RIGHT
			#check if the grid position in the next direction is free
#			if Globals.grid_get(_pos + _next_dir) != Globals.grid_types.EMPTY:
			if !_check_grid_cell_free(_pos + _next_dir,type,centipede_ID):
				#the grid position for the next movement isn't free, try the opposite direction
				if !_check_grid_cell_free(_pos - _next_dir,type,centipede_ID):
					#the grid direction of both left and right on this row is blocked, vertical move again
					if _pos.y <= Globals.ymaxline:
						_next_dir = Vector2.DOWN
						tgtdir = (tgtdir * Vector2.RIGHT) + Vector2.DOWN
					else:
						#centipod at bottom limit
						_next_dir = Vector2.UP
						tgtdir = (tgtdir * Vector2.LEFT) + Vector2.UP
						_introduce_new_pod()
				else:
					_next_dir *= Vector2.LEFT
			else:
				#reverse the horizontal direction
				tgtdir = (tgtdir * Vector2.LEFT) + (tgtdir * Vector2.DOWN)
		#we are currently travelling up
		Vector2.UP:
			#we were going up and now choose the next desired left/right direction
			_next_dir = tgtdir * Vector2.RIGHT
			#check if the grid position in the next direction is free
			if !_check_grid_cell_free(_pos + _next_dir,type,centipede_ID):
				#the grid position for the next movement isn't free, try the opposite direction
				if !_check_grid_cell_free(_pos - _next_dir,type,centipede_ID):
					#the grid direction of both left and right on this row is blocked, vertical move again
					if _pos.y > Globals.ymidline:
						_next_dir = Vector2.UP
						tgtdir = (tgtdir * Vector2.RIGHT) + Vector2.UP
					else:
						_next_dir = Vector2.DOWN
						tgtdir = (tgtdir * Vector2.RIGHT) + Vector2.DOWN
				else:
					_next_dir = Vector2.LEFT
			else:
				#reverse the horizontal direction
				tgtdir = (tgtdir * Vector2.LEFT) + (tgtdir * Vector2.DOWN)
		Vector2.LEFT, Vector2.RIGHT:
			#we were going left and now choose the next desired up/down direction
			_next_dir = tgtdir * Vector2.DOWN
			#the grid position for the next movement isn't free, try the opposite direction
			if pod_type == pod_types.POISON:
				_next_dir = Vector2.DOWN
			if _next_dir == Vector2.DOWN:
				if _pos.y >= Globals.ymaxline:
					_next_dir = Vector2.UP
					tgtdir = (tgtdir * Vector2.RIGHT) + Vector2.UP
					_introduce_new_pod()
			elif _next_dir == Vector2.UP:
				if _pos.y < Globals.ymidline:
					_next_dir = Vector2.DOWN
					tgtdir = (tgtdir * Vector2.RIGHT) + Vector2.DOWN
	return _next_dir


func _update_neighbour_pos():
	emit_signal("update_neighbour_pos",grid_position,curdir,pod_type)


func _on_signal_update_neighbour_pos(_position,_dir,_pod_type):
#	print("update received: pos:",_position," , DIR:",_dir)
	var store_new_pos:bool = false
	if tgtpos == _position:
		nextdir = _dir
		pod_type = _pod_type
		return
	if !neighbour_position.empty() and neighbour_position.back() == _position and neighbour_dir.back() != _dir:
		#update the direction only
		neighbour_dir.pop_back()
		neighbour_dir.push_back(_dir)
		neighbour_type.pop_back()
		neighbour_type.push_back(_pod_type)
		return
	if neighbour_position.empty() and tgtpos != _position:
		store_new_pos = true
	if !neighbour_position.empty() and neighbour_position.back() != _position:
		store_new_pos = true
	if store_new_pos:
		neighbour_position.push_back(_position)
		neighbour_dir.push_back(_dir)
		neighbour_type.push_back((_pod_type))

func _check_grid_cell_free(_pos,_type,_my_id) -> bool:
	var _cell_value:int
#	if Globals.grid_get_cell(_pos, Globals.grid_types.MUSHROOM) != Globals.grid_types.EMPTY:
	_cell_value = Globals.grid_get_cell(_pos, Globals.grid_types.MUSHROOM)
	if _cell_value == Globals.grid_types.BLOCKED or _cell_value == Globals.grid_types.OUT_OF_BOUNDS:
		return false
	if _cell_value != Globals.grid_types.EMPTY and _cell_value > 0:
		if _check_mushroom_type(_cell_value) == Globals.mushroom_types.POISON:
			pod_type = pod_types.POISON
		return false
	_cell_value = Globals.grid_get_cell(_pos, Globals.grid_types.CENTIPOD)
	if _cell_value != Globals.grid_types.EMPTY and _cell_value != _my_id:
		return false
	else:
		return true

func _check_mushroom_type(_mushroom_id) -> int:
	if _mushroom_id <= 0:
		return 0
	return Globals.mushroom_controller.mushrooms[_mushroom_id].mushroom_type

func _update_grid(_position,_last_grid_position,_type,_ID):
	#Update the grid
	if 	Globals.grid_get_cell(_last_grid_position,_type) == _ID:
		Globals.grid_set_cell(_last_grid_position,_type,Globals.grid_types.EMPTY)	#Clear the old grid position for this pod
	if 	Globals.grid_get_cell(_position,_type) == Globals.grid_types.EMPTY:
		Globals.grid_set_cell(_position,_type,_ID)

func _convert_to_head():
	convert_to_head = false
	head = true
	new_centipede_ID = Globals.centipede_controller.get_new_id()
	id_update()
	startframe = 4
	state = states.ALIVE
	neighbour_position.clear()
	neighbour_dir.clear()


func _hit():
	Globals.Score += points[1] if head else points [0]
#	emit_signal("create_mushroom",0,position - offset,centipede_ID + centi_pod_ID)
	emit_signal("create_mushroom",Globals.mushroom_types.NORMAL,grid_position)
	if next_neighbour != null:
		next_neighbour.convert_to_head = true
		next_neighbour.prev_neighbour = null
		next_neighbour.pod_type = pod_types.NORMAL
	if prev_neighbour != null:
		prev_neighbour.next_neighbour = null
	Globals.grid_set_cell(grid_position,Globals.grid_types.CENTIPOD,Globals.grid_types.EMPTY)
#	Globals.centipede_controller.centipods.erase(centi_pod_ID)
	queue_free()

func id_update():
	if 	Globals.grid_get_cell(grid_position,type) == centipede_ID:
		Globals.grid_set_cell(grid_position,type,new_centipede_ID)
	centipede_ID = new_centipede_ID
	self.name = "centi_"+str(centipede_ID)+"_"+str(centi_pod_ID)
	if next_neighbour != null:
		next_neighbour.new_centipede_ID = new_centipede_ID
		next_neighbour.id_update()

func _introduce_new_pod() -> void:
	#check if there are less than max pods on screen
	if Globals.no_of_centipods < max_pods:
# warning-ignore:integer_division
		var _pod_chance = ((Globals.no_of_centipods/5)*2)+2
		var _chance = randi() % _pod_chance == 1	#get a random value between 0 - 10 and check if it is 5
		if _chance and not Globals.centipede_controller.side_spawn_delay_active:
			emit_signal("create_new_centipod")

func _on_Area2D_body_entered(body):
	body.hit(self)

