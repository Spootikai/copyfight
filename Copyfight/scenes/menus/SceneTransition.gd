extends ColorRect

export(String, FILE, "*.tscn") var next_scene_path
onready var _anim_player := $AnimationPlayer

func _ready() -> void:
	# Plays the animation backward to fade in
	_anim_player.play_backwards("Fade")
	_anim_player.playback_speed = 1.0

func _process(delta):
	_anim_player.advance(delta)

func transition_to(_next_scene := next_scene_path) -> void:
	# Plays the Fade animation and wait until it finishes
	_anim_player.playback_speed = -1.0
	yield(_anim_player, "animation_finished")
	# Changes the scene
	var _err = get_tree().change_scene(_next_scene)
