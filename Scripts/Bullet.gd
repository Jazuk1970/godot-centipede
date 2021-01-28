extends Area2D
var speed:int = 600
var direction = Vector2.UP

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)


func _physics_process(delta):
	position += direction * speed * delta
	if position.y < 0 - Globals.grid_cell_size.y:
		queue_free()


func _on_Bullet_area_entered(area):
	var _node = area.get_parent()
	var _group = _node.get_groups()
	if _group.has("mushroom"):
			_node.hit()
			queue_free()
			
	if _group.has("centipod"):
			_node.hit = true
			queue_free()
			
