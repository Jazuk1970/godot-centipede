extends KinematicBody2D
#Preload scenes
var oBullet = preload("res://Scenes/Bullet.tscn")

var speed:int = 50
var movement = Vector2.ZERO
var velocity
var half_grid_cell_size:Vector2
var offset = Vector2(0,-4)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	half_grid_cell_size = Globals.grid_cell_size / 2
	
func _physics_process(delta) -> void:
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and Globals.no_of_bullets == 0:
		_fire_bullet()
		
	velocity = speed * movement * delta
	movement = Vector2.ZERO
#	if !test_move(,position + velocity,false):
	velocity = move_and_collide(velocity)
	position.x = clamp(position.x, half_grid_cell_size.x, Globals.Screen_Size.x - half_grid_cell_size.x)
	position.y = clamp(position.y, Globals.Screen_Size.y - (Globals.grid_cell_size.y * 9) - half_grid_cell_size.y, Globals.Screen_Size.y - (Globals.grid_cell_size.y / 2))  
	
func _input(event):
	if event is InputEventMouseMotion:
		movement = event.relative

func _fire_bullet() -> void:
	var _new_bullet = oBullet.instance()
	_new_bullet.position = position + offset
	_new_bullet.add_to_group("bullet")
	Globals.game_controller.add_child(_new_bullet)
