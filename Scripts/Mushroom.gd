extends Node2D

#Constants
const points = [0,0,0,1,5]

#Variables
onready var sprite = $Area2D/Sprite
var mushroomtype:int
var curFrame: int = 0
var lastFrame: int = 3
var ID:int = 0
var grid_pos:Vector2

#A function to handle when the mushroom has been hit by the player laser to decrease its size or remove the mushroom
# and return a the number of points obtained
func hit(val = 1) -> int:
	Globals.Score += points[curFrame]
	curFrame += val
	if curFrame > lastFrame:
		var _grid_pos = Globals.world_to_grid(position)
		Globals.grid_set_cell(_grid_pos,Globals.grid_types.MUSHROOM,Globals.grid_types.EMPTY)
		Globals.remove_id(Globals.mushroom_controller.mushroom_ids,ID)
		queue_free()
		return points[lastFrame]
	else:
		setFrame(curFrame)
		return points[curFrame]

##Convert a mushroom type and update its animation frame
#func convertMushroom(totype) -> void:
#	mushroomtype = Globals.mushroomtypes(totype)
#	setFrame(curFrame)

#Set the animation frame for the current type of mushroom
func setFrame(val) -> void:
	sprite.set_frame( val + (mushroomtype * (lastFrame + 1)))
