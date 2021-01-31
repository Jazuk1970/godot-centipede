extends Node2D
enum states{INITIALISE,STATE_READY,IN_PLAY,LIFE_LOST,GAME_OVER}
export (Font) var font
var state:int
var _regenerating:bool = false
var _lift_lost_reinit_done:bool = false

func _ready():
	set_process(true)
	Globals.mushroom_controller = $MushroomController
	Globals.centipede_controller = $CentiController
	Globals.flea_controller = $flea_controller
	Globals.player_controller = $Player
	Globals.game_controller = self
	state = states.INITIALISE

func _process(_delta):
	_process_input()
	match state:
		states.INITIALISE:
			_initialise()
		states.STATE_READY:
			_state_ready()
		states.IN_PLAY:
			_in_play()
		states.LIFE_LOST:
			_life_lost()
		states.GAME_OVER:
			_game_over()

func _print_states():
	print("GC:",Globals.game_controller.state)
	print("PC:",Globals.player_controller.state)
	print("MC:",Globals.mushroom_controller.state)
	print("CC:",Globals.centipede_controller.state)
	print("FC:",Globals.flea_controller.state)


func _process_input() -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
			get_tree().quit()

func _initialise() -> void:
	Globals.Level = 1
	Globals.Lives = 3
	Globals.mushroom_controller.state = Globals.mushroom_controller.states.INITIALISE
	Globals.centipede_controller.state = Globals.centipede_controller.states.INITIALISE
	Globals.flea_controller.state = Globals.flea_controller.states.INITIALISE
	Globals.player_controller.state = Globals.player_controller.states.INITIALISE
	Globals.message_done = false
	state = states.STATE_READY
	
func _state_ready() -> void:
	if not Globals.showing_message and not Globals.message_done:
		Globals.HUD.showMessage("Get Ready!",0.5)
	if Globals.message_done:
		if Globals.centipede_controller.state == Globals.centipede_controller.states.STATE_READY \
		and Globals.mushroom_controller.state == Globals.mushroom_controller.states.STATE_READY \
		and Globals.flea_controller.state == Globals.flea_controller.states.STATE_READY \
		and Globals.player_controller.state == Globals.player_controller.states.STATE_READY:
			state = states.IN_PLAY
			Globals.message_done = false
			_regenerating = false


			
func _in_play() -> void:
	Globals.no_of_centipods = get_tree().get_nodes_in_group("centipod").size()
	Globals.no_of_mushrooms = get_tree().get_nodes_in_group("mushroom").size()
	Globals.no_of_bullets = get_tree().get_nodes_in_group("bullet").size()
	if Globals.no_of_centipedes > 0 and Globals.no_of_centipods == 0 \
	and Globals.player_controller.state == Globals.player_controller.states.IN_PLAY \
	and Globals.centipede_controller.state == Globals.centipede_controller.states.IN_PLAY:
		_level_complete()
	if Globals.player_controller.state == Globals.player_controller.states.LIFE_LOST:
		state = states.LIFE_LOST

func _level_complete() -> void:
	Globals.Level +=1
	Globals.centipede_controller.state = Globals.centipede_controller.states.LEVEL_UP

func _life_lost() -> void:
	if not _lift_lost_reinit_done:
		Globals.centipede_controller.state = Globals.centipede_controller.states.RESET_CENTIPEDE
		Globals.player_controller.state = Globals.player_controller.states.INITIALISE
		Globals.flea_controller.state = Globals.flea_controller.states.INITIALISE
		_lift_lost_reinit_done = true
		
	if Globals.centipede_controller.state == Globals.centipede_controller.states.STATE_READY \
	and Globals.flea_controller.state == Globals.flea_controller.states.STATE_READY \
	and Globals.player_controller.state == Globals.player_controller.states.STATE_READY:
		if not _regenerating:
			Globals.Lives -= 1
			if Globals.Lives > 0:
				if Globals.mushroom_controller.state == Globals.mushroom_controller.states.IN_PLAY:
					Globals.mushroom_controller.state = Globals.mushroom_controller.states.REGENERATION
					_regenerating = true
			else:
				_lift_lost_reinit_done = false
				state = states.GAME_OVER	
		else:
			if Globals.mushroom_controller.state == Globals.mushroom_controller.states.STATE_READY:
				_regenerating = false
				_lift_lost_reinit_done = false
				state = states.STATE_READY
		
func _game_over() -> void:
	if not Globals.showing_message and not Globals.message_done:
		Globals.HUD.showMessage("Game Over!",5.0)
	if Globals.message_done:
		Globals.message_done = false
		state = states.INITIALISE
