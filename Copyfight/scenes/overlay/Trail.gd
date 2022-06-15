extends Line2D

var max_length

func _ready():
	set_as_toplevel(true)

func _process(_delta):
	max_length = int(Engine.get_frames_per_second() / 10)
	add_point(get_global_mouse_position())

	if get_point_count() > max_length:
		remove_point(0)
