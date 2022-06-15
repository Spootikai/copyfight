extends Node

# Mirror and cache server data here!
onready var game_state : Dictionary = {}
var combat_queue : Array = []

signal animate

var last_game_state = 0 
func updateGameState(s_game_state):
	if s_game_state["T"] > last_game_state:
		last_game_state = s_game_state["T"]
		s_game_state.erase("T")
		game_state = s_game_state
		
onready var timer = null
func updateCombatQueue(s_combat_queue):
	combat_queue = s_combat_queue

	timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(0.35)
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start()

func _on_timer_timeout():
	if combat_queue.size() > 0:
		emit_signal("animate")
		var _err = combat_queue.erase(combat_queue[0])
	else:
		timer.queue_free()
