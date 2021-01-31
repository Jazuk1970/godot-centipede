extends Area2D
var speed:int = 1000
var direction = Vector2.UP

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)


func _process(_delta):
	var _next_position = position + direction * speed * _delta
	var _space_state = get_world_2d().direct_space_state
	var _result = _space_state.intersect_ray(position,_next_position,[self],collision_mask)
	if _result.size() == 0:
		position += direction * speed * _delta
	else:
		var _collider = _result.collider
		position = _collider.position
		_check_collider(_collider)

	if position.y < 0 - Globals.grid_cell_size.y:
		queue_free()

func _check_collider(_collider):
	var _group = _collider.get_groups()
	if _group.has("mushroom"):
			_collider.hit()
			queue_free()
			
	if _group.has("centipod"):
			_collider.hit = true
			queue_free()
			
	if _group.has("flea"):
		_collider.hit = true
		queue_free()
	

#func _on_Bullet_area_entered(area):
#	var _node = area.get_parent()
#	_check_collider(_node)			
