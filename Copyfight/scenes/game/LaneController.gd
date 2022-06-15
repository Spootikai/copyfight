extends Node2D

onready var Game = get_parent()

onready var active_lanes : Array = []

export(Color, RGBA) var lane_color
export(Color, RGBA) var lane_active_color
export(Color, RGBA) var arc_color1
export(Color, RGBA) var arc_color2
export(Color, RGBA) var arc_color3
export(Color, RGBA) var arc_color4

func _process(_delta):
	update()

	# Determine which lane the player is hovering over
	for lane_index in Game.lane_count:
		var lane_width = (get_viewport().size.x / (Game.lane_count + 1))
		var lane_rect = Rect2(Vector2((lane_width * lane_index) + (lane_width / 2), 0), Vector2(lane_width, get_viewport().size.y))
			
		if lane_rect.has_point(get_global_mouse_position()):
			Game.lane_hovered = lane_index
	
func _input(event):
	var local_user = Gateway.username.to_lower()
	if !ServerData.game_state.empty():
		if ServerData.game_state.phase == "A":
			if ServerData.game_state.turn == local_user:
				if event is InputEventMouseButton:
					if event.is_pressed() and event.doubleclick:
						if active_lanes.has(Game.lane_hovered):
							var _err = active_lanes.erase(Game.lane_hovered)
						else:
							active_lanes.append(Game.lane_hovered)
						Server.requestLaneActivate(active_lanes)
		else:
			active_lanes.clear()

func _draw():
	var local_user = Gateway.username.to_lower()
	if !ServerData.game_state.empty():
		for lane_index in Game.lane_count:
			var lane_width = (get_viewport().size.x / (Game.lane_count + 1))
			var lane_rect = Rect2(Vector2((lane_width * lane_index) + (lane_width / 2), 0), Vector2(lane_width, get_viewport().size.y))
			
			if ServerData.game_state.lanes[lane_index] == true:
				drawLane(lane_index, lane_active_color)
			else:
				if lane_rect.has_point(get_global_mouse_position()):
					if ServerData.game_state.phase == "A":
						if ServerData.game_state.turn == local_user:
							drawLane(lane_index, lane_color)
	
	if !Game.entity_selected == null:
		var p0 : Vector2 = Game.entity_selected.global_position
		var p2 : Vector2 = get_global_mouse_position()
		var p1 : Vector2 = Vector2(p0.x+((p2.x - p0.x) / 2), 200)
		
		var thickness : float = 10

		var movements = ServerData.game_state.entities[int(Game.entity_selected.name)].A
		var predict_movements = movements - abs(Game.entity_selected.lane_position.x - Game.lane_hovered)
		
		var arc_color : Color
		if predict_movements > 2:
			arc_color = arc_color1
		elif predict_movements >= 1:
			arc_color = arc_color2
		elif predict_movements == 0:
			arc_color = arc_color3
		elif predict_movements < 0:
			arc_color = arc_color4

		for i in 50:
			var t1 = i * 0.02
			var t2 = (i+1) * 0.02
			draw_line(getBezier(p0, p1, p2, t1), getBezier(p0, p1, p2, t2), arc_color, (clamp(i*0.02, 0.15, 1.0)*thickness), true)

func drawLane(lane_index : int, color : Color):
	var lane_width = (get_viewport().size.x / (Game.lane_count + 1))
	var lane_rect = Rect2(Vector2((lane_width * lane_index) + (lane_width / 2), 0), Vector2(lane_width, get_viewport().size.y))

	draw_rect(lane_rect, color, true)

func getBezier(p0 : Vector2, p1 : Vector2, p2: Vector2, t : float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var r = q0.linear_interpolate(q1, t)
	return r
