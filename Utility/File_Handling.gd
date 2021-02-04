extends Node
func LoadFile(_fName) -> Array:
	var _return:Array = [null,null]
	var _file = File.new()
	var _json
	var _data
	var _result
	if _file.file_exists(_fName):
		_result = _file.open(_fName, File.READ)
		if _result == OK:
			_json = _file.get_as_text()
			_data = parse_json(_json)
			_return[1] = _data
	_return[0] = _result
	return _return
		
func SaveFile(_fName,_data) -> Array:
	var _return:Array = [null,null]
	var _file = File.new()
	var _result
	_result = _file.open(_fName, File.WRITE)
	if _result == OK:
		_file.store_line(to_json(var2str(_data)))
		_file.close()
	_return[0] = _result
	return _return