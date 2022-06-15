extends Node2D

onready var Game = get_node("/root/Game")

export(Color, RGBA) var exhaust_color

var id: String
var controller: String
var lane_position: Vector2
var state : int

var attribute_base : Dictionary
var attribute_modifier : Dictionary
var attribute_final : Dictionary

var is_hovered : bool = false

var anim : String = "idle"
var anim_attack_delay = 0.25
var anim_attack_timer = 0.0

func _setup(id : String, controller : String, lane_position : Vector2):
	self.scale = Vector2(0.25, 0.25)
	
	self.id = id
	self.controller = controller
	self.lane_position = lane_position
	
	var set_id = id.substr(0, 3)
	self.attribute_base = GlobalCard.data[set_id].card[id].attributes
	self.attribute_modifier = {
		"attack":0,
		"cost":0,
		"health":0,
		"keywords":[],
		"type":[]
	}
	$Sprite.texture = Cache.textures[id]
	
	self.global_position = get_lane_position()
	ServerData.connect("animate", self, "_on_animate")

func _on_animate():
	if ServerData.combat_queue.size() > 0:
		if controller == ServerData.game_state.attack_token[0]:
			if ServerData.combat_queue[0] == int(self.name):
				anim = "attack"
				Game.get_node("Camera").startShake(0.2, 8)

func _process(delta):
	match anim:
		"idle":
			self.global_position = lerp(self.global_position, get_lane_position(), 0.25)
			z_index = -10 - lane_position.y
		"attack":
			var pos = get_lane_position()
			var mirrored = ((get_viewport().size.y / 2) - pos.y)*2.0
			var atk_pos = Vector2(pos.x, pos.y + mirrored) 
			
			
			if self.global_position.distance_to(atk_pos) > 5:
				self.global_position = self.global_position.linear_interpolate(atk_pos, anim_attack_timer / anim_attack_delay)
				anim_attack_timer += delta
			else:
				anim = "idle"
				anim_attack_timer = 0

	match state:
		0:
			self.rotation_degrees = 15
			self.modulate = exhaust_color
		1:
			self.rotation_degrees = 0
			self.modulate = Color(1, 1, 1, 1)

func _physics_process(_delta):
	self.state = ServerData.game_state.entities[int(self.name)].S
	self.lane_position = ServerData.game_state.entities[int(self.name)].P
	attribute_modifier = ServerData.game_state.entities[int(self.name)].M
	attribute_final = {
		"attack": attribute_base.attack + attribute_modifier.attack,
		"health": attribute_base.health + attribute_modifier.health,
		"keywords": attribute_base.keywords, #Make this toggle (if the server says it has first strike and it already does, remove first strike)
		"type": attribute_base.type #Make this toggle
	}
	$Stats/StatAttack.bbcode_text = "[center]"+str(attribute_final.attack)+"[/center]"
	$Stats/StatHealth.bbcode_text = "[center]"+str(attribute_final.health)+"[/center]"

	var pos = self.global_position
	var size = Vector2($Sprite.texture.get_width(), $Sprite.texture.get_height()) * self.scale.x
	
	is_hovered = Rect2(pos - (size / 2), size).has_point(get_global_mouse_position())

func get_lane_position():
	var pos: Vector2 = Vector2.ZERO
	
	pos.x = (get_viewport().size.x / (Game.lane_count + 1)) * (lane_position.x + 1)
	
	match Toolbox.player_is_local(controller):
		true:
			pos.y = (get_viewport().size.y / 2) + (200 + (50 * lane_position.y))
		false:
			pos.y = (get_viewport().size.y / 2) - (200 + (50 * lane_position.y))

	return pos
