extends Node2D
enum states{INITIALISE,TITLE_SCREEN,OPTIONS,PLAY_LEVEL,NEXT_LEVEL,HISCORE}
var _state:int 
var _previous_State:int
onready var _next_scene:Object
onready var _current_scene:Object = $CurrentScene
func _ready():
	Globals.main_controller = self
	_state = states.INITIALISE


func _process(_delta):
	_process_input()
	match _state:
		states.INITIALISE:
			_state = states.TITLE_SCREEN

		states.TITLE_SCREEN:
			if _previous_State != _state:
				_title()
				_previous_State = _state
				
		states.OPTIONS:
			pass

		states.HISCORE:
			pass

		states.PLAY_LEVEL:
			pass

		states.NEXT_LEVEL:
			pass


func _initialise() -> void:
	pass

func _title_screen() -> void:
	pass

func _options() -> void:
	pass

func _hiscore() -> void:
	pass

func _play_level() -> void:
	pass

func _next_level() -> void:
	pass

func _process_input() -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
			get_tree().quit()


func _switch_scene(_obj):
	#possibly add fade here
	var _children = _current_scene.get_children()
	for _child in _children:
		_child.queue_free()
	_current_scene.add_child(_obj)

func _get_scene(_res) -> Object:
	var _new_scene = _res.instance()
	return _new_scene
	
func _title():
	_next_scene = load("res://Main/Title.tscn")
	var _scene = _get_scene(_next_scene)
	_scene.connect("startgame", self, "_start_game")
	_switch_scene(_scene)
	
func _start_game():
	_next_scene = load("res://Game/Game.tscn")
	var _scene = _get_scene(_next_scene)
	_scene.connect("gameover",self,"_game_over")
	_scene.connect("highscore",self,"_high_score")
	_switch_scene(_scene)
	
func _game_over():
	_title()

func _high_score():
	print("hi-score",Globals.Score)
