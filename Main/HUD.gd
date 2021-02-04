extends CanvasLayer

#Preload scenes
var sprPlayer = preload("res://Player/centipede_player.png")		#Preload the player sprite

#Variables
var players = ["HI","1UP", "2UP"]					#Player array (future multi-player)
var livesPos = Vector2(4,4)						#A pointer to the play lives image location on the hud

func _ready():
	Globals.HUD = self
	updateScore(0,Globals.HiScore)


#Update the score
func updateScore(player,val):
	var obj = get_node(players[player] + "/Score")	#Get a reference the score object in the hud
	obj.text = str(val).pad_zeros(6)				#update the score

#Update the lives
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func updateLives(player,val):
	var sprW = sprPlayer.get_width()				#Get the width of the player sprite
	var ll = $Lives/Lives						#Get a reference to the lives area on the bottom bar of the hud
	var lives = val						#Get the current lives left
	for l in range(ll.get_child_count()):			#Loop through all the player lives images
		var life = ll.get_child(l)					#Get a reference to the specific player image
		life.queue_free()							#remove the image
	for l in range(lives):											#loop through all the player lives
		var pos = Vector2(livesPos.x + ((sprW * 0.75) *l) ,livesPos.y)		#calculate the position for the player image
		var spr = Sprite.new()										#create a new sprite
		spr.texture = sprPlayer										#Set the sprite to the player image
		spr.vframes = 4
		spr.hframes = 1
		spr.frame = 0
		spr.scale = Vector2(0.75,0.75)								#Scale the image
		spr.position = pos											#Set the image position
		spr.name = "PlayerLife" + str(l+1)							#Name the image
#		spr.modulate = Globals.PlayerColour							#Set the image colour
		ll.add_child(spr)											#Add the sprite as a child of the lives bar

#This function will show a message to the user, and introduce a delay which also pauses movements
func showMessage(msg,dly):
	Globals.showing_message = true
	Globals.message_done = false
	$Message/Label.text = msg						#Set the message box text
	$Message.visible = true							#Show the message box
	$Message/Anim.play("showMessage")				#Play the show message animation
	yield($Message/Anim,"animation_finished")		#Wait until the animation has finished playing
	yield(get_tree().create_timer(dly), "timeout")	#Wait for the delay timer to have elapsed
	$Message/Anim.play("hideMessage")				#Play the hide message animation
	yield($Message/Anim,"animation_finished")		#Wait until the animation has finished playing
	$Message.visible = false						#Hide the message box
	Globals.showing_message = false
	Globals.message_done = true

#This function will show/hide a title page
func showTitle(val):
	$TitleBox.visible = val							#Set the visibility of the title box

#This function will update the level display
# warning-ignore:unused_argument
func updateLevel(player,val):
	$Level/Level.text = str(val)					#Set the level text to the required value
