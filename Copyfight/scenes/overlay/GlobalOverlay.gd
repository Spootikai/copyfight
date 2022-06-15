extends Node2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func _process(_delta):
	$Cursor.global_position = get_global_mouse_position()
	
	update()

func _draw():
	$Trail.visible = focused
	$Cursor.visible = focused

onready var focused : bool = true
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_IN:
			focused = true
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			focused = false

func update_activity() -> void:
	var activity = Discord.Activity.new()
	activity.set_type(Discord.ActivityType.Playing)
	

	var assets = activity.get_assets()
	assets.set_large_image("symbol")
	assets.set_large_text("Copyfight")

	if !Gateway.offline_mode:
		var text = "???"
		match get_tree().get_current_scene().name:
			"MainMenu":
				text = "Idling in Main Menu"
		
		activity.set_details(text)
		activity.set_state("Signed in as: "+Gateway.username)
		assets.set_small_image("friend_icon")
		assets.set_small_text("Waiting")
	else:
		activity.set_details("OFFLINE MODE")

	var result = yield(Discord.activity_manager.update_activity(activity), "result").result
	if result != Discord.Result.Ok:
		push_error(str(result))
