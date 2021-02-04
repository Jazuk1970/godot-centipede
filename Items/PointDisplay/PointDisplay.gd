extends Node2D
onready var tween = $Tween
onready var label = $Label
var points:int

func _ready():
	label.text = str(points)
	tween.interpolate_property(self, "scale", scale, Vector2.ONE, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, "scale", Vector2.ONE, Vector2.ONE * 0.2, 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT,0.3)
	tween.start()


func _on_Tween_tween_all_completed():
	queue_free()

