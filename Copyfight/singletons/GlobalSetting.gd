extends Node

const save_file = "user://options.save"

var data = {}

func _ready():
	load_data()

	set_save_login(data["save_login"])
	
	set_fullscreen(data["fullscreen"])
	set_vsync(data["vsync"])
	
	set_master_volume(data["volume_master"])
	set_music_volume(data["volume_music"])
	set_sfx_volume(data["volume_sfx"])
	set_voice_volume(data["volume_voice"])

func _process(_delta):
	if Input.is_action_just_pressed("debug_key"):
		set_debug_mode(!data["debug_mode"])
		print("DEBUG MODE: "+str(data["debug_mode"]))
		save_data()
	
func save_data():
	var file = File.new()
	file.open(save_file, File.WRITE)
	file.store_var(data)
	file.close()

func load_data():
	var file = File.new()
	if not file.file_exists(save_file):
		data = {
			"save_login": {},
			"debug_mode": false,
			"fullscreen": false,
			"vsync": false,
			#"max_fps": 0,
			"volume_master": 20,
			"volume_music": 5,
			"volume_sfx": 5,
			"volume_voice": 5,
			#"sensitivity": 0.1
			"spoiler_naruto": 1,
			"spoiler_avatar": 1
		}
		save_data()
	else:
		file.open(save_file, File.READ)
		data = file.get_var()
	
	file.close()

func set_save_login(value):
	data["save_login"] = value

func set_debug_mode(value):
	data["debug_mode"] = value

func set_fullscreen(value):
	OS.window_fullscreen = value
	data["fullscreen"] = value

func set_vsync(value):
	OS.vsync_enabled = value
	data["vsync"] = value

func set_master_volume(value):
	data["volume_master"] = value
	if value <= 1:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value * 0.01))

func set_music_volume(value):
	data["volume_music"] = value
	if value <= 1:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value * 0.1))

func set_sfx_volume(value):
	data["volume_sfx"] = value
	if value <= 1:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(value * 0.1))

func set_voice_volume(value):
	data["volume_voice"] = value
	if value <= 1:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Voice"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Voice"), false)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Voice"), linear2db(value *  0.1))

func set_spoiler_naruto(value):
	data["spoiler_naruto"] = value

func set_spoiler_avatar(value):
	data["spoiler_avatar"] = value
