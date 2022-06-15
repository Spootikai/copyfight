extends Popup

func _ready():
	$TabContainer/Video/VBoxContainer/Fullscreen.pressed = GlobalSettings.data["fullscreen"]
	$TabContainer/Video/VBoxContainer/Vsync.pressed = GlobalSettings.data["vsync"]
	
	$TabContainer/Audio/VBoxContainer/Master.value = GlobalSettings.data["volume_master"]
	$TabContainer/Audio/VBoxContainer/Music.value = GlobalSettings.data["volume_music"]
	$TabContainer/Audio/VBoxContainer/SFX.value = GlobalSettings.data["volume_sfx"]
	$TabContainer/Audio/VBoxContainer/Voice.value = GlobalSettings.data["volume_voice"]
	
	$TabContainer/FilterSpoilers/VBoxContainer/Naruto.value = GlobalSettings.data["spoiler_naruto"]
	$TabContainer/FilterSpoilers/VBoxContainer/Avatar.value = GlobalSettings.data["spoiler_avatar"]
	popup()

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		GlobalSettings.save_data()
		self.queue_free()

# Video Settings
func _on_Fullscreen_toggled():
	GlobalSettings.set_fullscreen($TabContainer/Video/VBoxContainer/Fullscreen.pressed)

func _on_Vsync_toggled():
	GlobalSettings.set_vsync($TabContainer/Video/VBoxContainer/Vsync.pressed)

# Audio Settings
func _on_Master_value_changed(_value):
	GlobalSettings.set_master_volume($TabContainer/Audio/VBoxContainer/Master.value)
	$TabContainer/Audio/VBoxContainer/Master/Label.text = str($TabContainer/Audio/VBoxContainer/Master.value)

func _on_Music_value_changed(_value):
	GlobalSettings.set_music_volume($TabContainer/Audio/VBoxContainer/Music.value)
	$TabContainer/Audio/VBoxContainer/Music/Label.text = str($TabContainer/Audio/VBoxContainer/Music.value)

func _on_SFX_value_changed(_value):
	GlobalSettings.set_sfx_volume($TabContainer/Audio/VBoxContainer/SFX.value)
	$TabContainer/Audio/VBoxContainer/SFX/Label.text = str($TabContainer/Audio/VBoxContainer/SFX.value)

func _on_Voice_value_changed(_value):
	GlobalSettings.set_voice_volume($TabContainer/Audio/VBoxContainer/Voice.value)
	$TabContainer/Audio/VBoxContainer/Voice/Label.text = str($TabContainer/Audio/VBoxContainer/Voice.value)

# Gameplay Settings

# Spoiler Filtering Settings
func _on_Naruto_value_changed(_value):
	GlobalSettings.set_spoiler_naruto($TabContainer/FilterSpoilers/VBoxContainer/Naruto.value)

func _on_Avatar_value_changed(_value):
	GlobalSettings.set_spoiler_avatar($TabContainer/FilterSpoilers/VBoxContainer/Avatar.value)
