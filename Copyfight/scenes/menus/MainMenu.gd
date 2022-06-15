extends Control

const options_instance = preload("res://scenes/menus/OptionsMenu.tscn")

func _ready():
	if !Gateway.offline_mode:
		Gateway.fetchUserData(Gateway.username)
		$VideoPlayer.stream = Cache.video

	GlobalOverlay.update_activity()
	pass

func _physics_process(_delta):
	$OfflineMode.visible = Gateway.offline_mode
	
	$FriendButton.visible = !Gateway.offline_mode
	if !Gateway.user_data.empty():
		$FriendButton/Label.text = str(clamp(Gateway.user_data["F"].size()-1, 0, 999))
	
	$LabelUsername.visible = !Gateway.offline_mode
	$LabelUsername.text = Gateway.username+" "
	
	if GlobalSettings.data["volume_master"] == 69:
		if !$AudioStreamPlayer.playing:
			$AudioStreamPlayer.playing = true
	else:
		$AudioStreamPlayer.playing = false

func _on_Connect_pressed():
	if Gateway.offline_mode:
		$SceneTransition.transition_to("res://scenes/menus/LoginMenu.tscn")
	else:
		$SceneTransition.transition_to("res://scenes/menus/ConnectMenu.tscn")

func _on_Library_pressed():
	$SceneTransition.transition_to("res://scenes/menus/LibraryMenu.tscn")

func _on_Options_pressed():
	var options_menu = options_instance.instance()
	self.add_child(options_menu)

func _on_Exit_pressed():
	GlobalSettings.save_data()
	get_tree().quit()

func _process(_delta):
	if !$VideoPlayer.is_playing():
		$VideoPlayer.play()
func _on_FriendButton_pressed():
	Gateway.fetchUserData(Gateway.username)
	#Gateway.setUser("spooticus", 3)
