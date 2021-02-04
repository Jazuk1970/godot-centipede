extends CanvasLayer
signal startgame
signal hiscore
onready var _hiscore_table = $VBoxContainer/HiScore_table
var _allow_start:bool

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_hiscore_table.connect("score_entered",self, "_on_score_entered")
	self.connect("hiscore",_hiscore_table,"new_high_score")
	if Globals.Score > Globals.Min_HiScore:
		_allow_start = false
		emit_signal("hiscore",Globals.Score)
	else:
		_allow_start = true

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if _allow_start:
				emit_signal("startgame")

func _on_score_entered():
	_allow_start = true
	