extends Node2D

onready var hand_position : Vector2
onready var is_hovered : bool = false

export(Color, RGBA) var combat_color
export(Color, RGBA) var trigger_color
export(Color, RGBA) var static_color

func _ready():
	add_to_group("card")
	
func _physics_process(_delta):
	var pos = self.global_position
	var size = Vector2($Template.texture.get_width(), $Template.texture.get_height()) * self.scale.x
	
	is_hovered = Rect2(pos - (size / 2), size).has_point(get_global_mouse_position())

func _process(_delta):
	match get_tree().get_current_scene().name:
		"Game":
			self.global_position = lerp(self.global_position, hand_position, 0.05)

const keyword_display_instance = preload("res://scenes/game/KeywordDisplay.tscn")
func format_card(set_id : String):
	var card_set = set_id.substr(0, 3)

	$Revealed/Sprite.texture = Cache.textures[set_id]

	var card_data = GlobalCard.data[card_set]["card"][set_id]
	if card_data.attributes.keys().has("cost"):
		$Revealed/Cost.text = str(int(card_data.attributes.cost))
	$Revealed/Title.text = card_data.title
	$Revealed/Description.bbcode_text = card_data.description
	
	$Revealed/Control/Power.text = str(card_data.attributes.attack)
	$Revealed/Control/Tough.text = str(card_data.attributes.health)

	for keyword in card_data.attributes.keywords:
		var new_keyword_display = keyword_display_instance.instance()
		
		$Revealed/KeywordContainer/HBoxContainer.add_child(new_keyword_display)
		new_keyword_display.get_node("Texture").texture = load("res://assets/textures/icons/"+keyword+".png")
		if keyword.substr(0, 7) == "trigger":
			new_keyword_display.modulate = trigger_color
		match keyword:
			"first_strike":
				new_keyword_display.modulate = combat_color
			"double_strike":
				new_keyword_display.modulate = combat_color
			"demolish":
				new_keyword_display.modulate = combat_color
			"gank":
				new_keyword_display.modulate = static_color
