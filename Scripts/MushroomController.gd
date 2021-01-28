extends Node2D
var points:int

#Preload scenes
var oMushroom = preload("res://Scenes/Mushroom.tscn")

#Variables
var mushroomGridSize:int = 8 	#The mushroom grid spacing in pixels

#temp
var aryPressed = {}			#this is not required here, and is for testing only
var totalMushrooms = 80		#this should come from the level data

# Called when the node enters the scene tree for the first time.
func _ready():
	var minVec = Vector2(0,Globals.Screen_Size.x)
	var maxVec = Vector2(8*5,Globals.Screen_Size.x - ( 8 * 10))
	for mr in range(totalMushrooms):
		createMushroom(Globals.mushroomtypes.normal,getUnusedPos(minVec,maxVec),mr)


func _process(delta):
	if Globals.is_action_just_pressed("ui_select",aryPressed) and $mushroom_test:
		var o = get_node("mushroom_test")
		points += o.mushroomHit()
	return delta



#Create a mushroom of the given type, at the given position and ID
func createMushroom(type = Globals.mushroomtypes.normal,pos = Vector2.ZERO,id = 0):
	var _grid_pos:Vector2
	var mushroom = oMushroom.instance()
	mushroom.position = pos
	mushroom.mushroomtype = type
	mushroom.name = "mushroom_" + str(id)
	mushroom.add_to_group("mushroom")
	self.add_child(mushroom)
	_grid_pos = Globals.world_to_grid(pos)
	Globals.grid_set_cell(_grid_pos,Globals.grid_types.MUSHROOM)

#Convert a pixel location to a grid fixed pixel location
func pixeltoGrid(val) -> int:
	return (int(val / mushroomGridSize))*mushroomGridSize

func checkShroom(pos):
	var retVal = true
	for mr in get_tree().get_nodes_in_group("mushrooms"):
		if mr.position == pos:
			retVal = false
			break
	return retVal

#Get an unused grid location from the screen (only used during set-up)
func getUnusedPos(minVec:Vector2, maxVec:Vector2) -> Vector2:
	var loop = true
	var v2
	while loop:
		v2 = getRandV2(minVec,maxVec)
		if checkShroom(v2):
			loop = false
	return v2

func getRandV2(minV,maxV) -> Vector2:
	return Vector2(pixeltoGrid(Globals.getRand_Range(minV.x,minV.y,0)),pixeltoGrid(Globals.getRand_Range(maxV.x,maxV.y,0)))
