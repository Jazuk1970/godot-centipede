extends Node2D
enum states{INITIALISE,TITLE_SCREEN,OPTIONS,PLAY_LEVEL,NEXT_LEVEL,HISCORE}
var _state:int

func _ready():
	Globals.main_controller = self
	_state = states.INITIALISE

func _process(_delta):
	match _state:
		states.INITIALISE:
			_state = states.PLAY_LEVEL
			
		states.TITLE_SCREEN:
			pass

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


#TODO: After centipede hits the bottom, add a new pod from the side depending on number of pods on screen?? periodically??.
#TODO: If the number of mushrooms is < set value send in the flea to create additional mushrooms.
#		fleas drop vertically and disappear at the bottom of the screen.  They leave random mushrooms in the path depending on
#		how many mushrooms are on screen.  Fleas are worth 200 points and take 2 shots to destroy.
#TODO: create a spider
#	spiders move in a zig-zag motion and eat some of the mushrooms. They are worth 300,600 or 900 points depending on distance from player.
#TODO: create scorpion
#	scorpions move horizontally across the screen turning all mushrooms they touch into poison mushrooms.
# 	they are worth 1000 points.
#TODO: kill player on contact with all emenies
#	when a player has been killed, all current mushrooms on the screen are regenerated back to full health, and 5 points are added
#	for each mushroom regenerated
#TODO: lives
#	extra lives awarded every 12000 points
#TODO: add sounds
#TODO: add title screen / attract mode?? - possibly options & instructions
#TODO: add high score table

