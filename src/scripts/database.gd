extends Node

var config = {}
var _config = ConfigFile.new()
const _file_path = "user://database.cfg"
const _config_section_name = "config"


func _ready():
	_loaddb()

func _loaddb():
	# Load data from a file.
	var err = _config.load(_file_path)

	# If the file didn't load, ignore it.
	if err != OK:
		return

	for key in _config.get_section_keys(_config_section_name):
		var val = config.get_value(_config_section_name, key)
		config[key] = val

func update_config(key,value):
	_config.set_value(_config_section_name, key, value)
	config[key] = value
	_save()
	

func _save():
	_config.save(_file_path)
	

func get_value(scope, field, default):
	return _config.get_value(scope, field, default)

func save_values(scope, field, value):
	_config.set_value(scope, field, value)
	_save()
