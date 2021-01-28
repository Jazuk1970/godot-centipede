extends Node2D
export (Font) var font

func _ready():
	Globals.mushroom_controller = $MushroomController
	Globals.centipede_controller = $CentiController
	Globals.game_controller = self

func _process(delta):

	return delta

func _physics_process(delta):
	Globals.no_of_centipods = get_tree().get_nodes_in_group("centipod").size()
	Globals.no_of_mushrooms = get_tree().get_nodes_in_group("mushroom").size()
	Globals.no_of_bullets = get_tree().get_nodes_in_group("bullet").size()
	if Input.is_key_pressed(KEY_ESCAPE):
			get_tree().quit()

	if Globals.no_of_centipedes > 0 and Globals.no_of_centipods == 0:
		Globals.centipede_controller.reset_level()

	return delta

#TODO: Centipede creator.. this will create a full size centipede (either 10 or 12 segs).
#		after the centipede is destroyed, the next one will be 1 seg less + 1 single head.
#		this continues until all segs are single (ie 10/12)
# 		after the last of the segs is destoryed when all single, the centipede is set back to full length and the cycle starts again

#TODO: After centipede hits the bottom, add a new pod from the side depending on number of pods on screen?? periodically??.
#TODO: If the number of mushrooms is < set value send in the flea to create additional mushrooms.
#		fleas drop vertically and disappear at the bottom of the screen.  They leave random mushrooms in the path depending on
#		how many mushrooms are on screen.  Fleas are worth 200 points and take 2 shots to destroy.
#TODO: create a spider
#	spiders move in a zig-zag motion and eat some of the mushrooms. They are worth 300,600 or 900 points depending on distance from player.
#TODO: create scorpion
#	scorpions move horizontally across the screen turning all mushrooms they touch into poison mushrooms.
# 	they are worth 1000 points.
#TODO: create poison centipods
#	if a centipod touches a poison mushroom it will move straight downwards and become normal once again at the bottom
#TODO: kill player on contact with all emenies
#	when a player has been killed, all current mushrooms on the screen are regenerated back to full health, and 5 points are added
#	for each mushroom regenerated
#TODO: lives
#	extra lives awarded every 12000 points

