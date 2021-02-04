extends VBoxContainer
const FILE_NAME = "user://hiscores.json"
signal score_entered
onready var _hs_container = $HiScores
onready var _name_edit = $NewHiscore/enter_name/name
onready var _enter_name = $NewHiscore

var _hiscores:Array = []
var _hsnodes:Dictionary = {}
var _last_score:int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	_getHiscores()
	_showHiScores()
	Globals.Min_HiScore = _hiscores.back()[0]
	Globals.HiScore = _hiscores.front()[0]
	_name_edit.connect("text_entered",self,"_on_text_entered")
	_enter_name.visible = false
	_saveHiscores()


func _getHiscores():
	_hiscores = []
	var _data = File_Handling.LoadFile(FILE_NAME)
	if _data[0] == OK:
		_hiscores = str2var(_data[1])
	else:
		for _hs in range(10,0,-1):
			_hiscores.append([_hs * 10000,"ATARI INC."])

func _showHiScores():
	var _hiscore_tables = _hs_container.get_children()
	for _hs in range(_hiscore_tables.size()):
		var _hs_items = _hiscore_tables[_hs].get_children()
		_hs_items[0].text = str(_hiscores[_hs][0])
		_hs_items[2].text = _hiscores[_hs][1]

func _saveHiscores():
	var _result = File_Handling.SaveFile(FILE_NAME,_hiscores)

func _updateHiscore(_score,_name):
	if _score < Globals.Min_HiScore:
		return
	var _hs_pos = _hiscores.size() -1
	while (_hiscores[_hs_pos][0] < _score) and _hs_pos > 0 :
		_hs_pos -= 1
	if _score < Globals.HiScore:
		_hs_pos += 1
	var _new_hs = [_score,_name]
	_hiscores.insert(_hs_pos,_new_hs)
	_hiscores.remove(_hiscores.size() -1)
	_saveHiscores()	

func new_high_score(_score):
	_enter_name.visible = true
	_last_score = _score
	
	_name_edit.grab_focus()
	
func _on_text_entered(_text):
	_updateHiscore(_last_score,_text)
	_showHiScores()
	_enter_name.visible = false
	emit_signal("score_entered")
	