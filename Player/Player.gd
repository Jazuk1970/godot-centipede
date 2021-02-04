extends KinematicBody2D
enum states{INITIALISE,STATE_READY,IN_PLAY,LIFE_LOST}
#Preload scenes
var oBullet = preload("res://Player/Bullet.tscn")

onready var sprite = $Sprite
var start_position = Vector2(120,245)
var player_area_height:int = 6
var speed:int = 50
var movement = Vector2.ZERO
var velocity
var half_grid_cell_size:Vector2
var offset = Vector2(0,-4)
var starting_lives:int = 3
var state:int
var _last_extra_life_awarded:int
var _extra_life_points:int = 12000
var _sound = "sfx_shot"


func _ready():
	set_process(true)
	self.add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	half_grid_cell_size = Globals.grid_cell_size / 2
	Globals.player_zone.position = Vector2(0,Globals.grid_size.y - player_area_height)
	Globals.player_zone.size = Vector2(Globals.grid_size.x, player_area_height)

func _process(_delta) -> void:
	if Globals.Score > _last_extra_life_awarded + _extra_life_points:
		_last_extra_life_awarded = (int(Globals.Score / _extra_life_points)) * _extra_life_points
		Globals.Lives += 1
	match state:
		states.INITIALISE:
			_initialise()
		states.STATE_READY:
			_state_ready()
		states.IN_PLAY:
			_in_play(_delta)
		states.LIFE_LOST:
			_life_lost()

func _initialise() -> void:
	sprite.hide()
	position = start_position
	_clean_up()
	state = states.STATE_READY

func _state_ready() -> void:
	if Globals.game_controller.state == Globals.game_controller.states.IN_PLAY:
		sprite.show()
		state = states.IN_PLAY

func _in_play(_delta) -> void:
	Globals.no_of_bullets = get_tree().get_nodes_in_group("bullet").size()
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and Globals.no_of_bullets == 0:
			_fire_bullet()

	velocity = speed * movement * _delta
	movement = Vector2.ZERO
#	_last_position = position
	var _result = move_and_collide(velocity)
	if _result != null:
		var _collider = _result.collider
		_check_collider(_collider)

	position.x = clamp(position.x, half_grid_cell_size.x, Globals.Screen_Size.x - half_grid_cell_size.x)
	position.y = clamp(position.y, Globals.Screen_Size.y - (Globals.grid_cell_size.y * player_area_height) - half_grid_cell_size.y, Globals.Screen_Size.y - (Globals.grid_cell_size.y / 2))

		

func _life_lost() -> void:
	pass

func _input(event):
	if event is InputEventMouseMotion:
		movement = event.relative

func _fire_bullet() -> void:
	var _new_bullet = oBullet.instance()
	_new_bullet.position = position + offset
	_new_bullet.add_to_group("bullet")
	Globals.game_controller.add_child(_new_bullet)
	_play_sound()

func hit(_body):
	if state == states.IN_PLAY:
		state = states.LIFE_LOST

func _clean_up() -> void:
	var _bullets = get_tree().get_nodes_in_group("bullet")
	if _bullets != null and _bullets.size() != 0:
		for _bullet in _bullets:
			_bullet.queue_free()
		Globals.no_of_bullets = 0

func _check_collider(_collider):
	var _group = _collider.get_groups()
	if _group.has("enemy"):
			hit(_collider)
			
func _play_sound():
	Globals.SFX.play(_sound,-20.0)

