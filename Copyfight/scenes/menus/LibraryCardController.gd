extends Node2D

var page = 0
var page_layout = Vector2(4, 2) # columns, rows
var page_size = 0.2 # 0.0 to 1.0
var card_scale = 0.75

var page_scroll = 0

func _ready():
	refresh_cards()

func _process(_delta):
	for index in get_child_count():
		var card = get_child(index)
		card.global_position = get_card_position(index)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				page_scroll += 100
			if event.button_index == BUTTON_WHEEL_DOWN:
				page_scroll -= 100
	
	var viewport = get_viewport() 
	var vp = Vector2(viewport.size.x * (1 - page_size), viewport.size.y)
	var section_height = vp.y / (page_layout.y)
	
	var rows = ceil(get_child_count() / page_layout.x)
	
	page_scroll = clamp(page_scroll, -clamp((rows-page_layout.y) * section_height, 0, vp.y*page_layout.y) , 0)

# Search for specific things
# Needs UI elements
var criteria : Dictionary = {
	"set": [
		"nrt"
	],
	"title": ""
}

func get_card_list():
	var card_list : Array = []
	for set in GlobalCard.data.keys():
		for set_id in GlobalCard.data[set]["card"].keys():
			var card = GlobalCard.data[set]["card"][set_id]
			
			# Check if the set is the same
			if criteria.set.size() <= 0 or criteria.set.has(set):
				# Check if the title is the same
				if criteria.title == "" or criteria.title in card.title:
					card_list.append(set_id)
	
	return card_list

func refresh_cards():
	for i in get_child_count():
		var child = get_child(i)
		child.queue_free()
	
	var card_list = get_card_list()
	for i in card_list.size():
		var card = create_card()
		card.format_card(card_list[i])

const card_instance = preload("res://scenes/game/CardInstance.tscn")
func create_card():
	var new_card = card_instance.instance()
	self.add_child(new_card)
	new_card.scale = Vector2(card_scale, card_scale)
	new_card.global_position = get_card_position(self.get_child_count() - 1)
	
	return new_card

func get_card_position(card_index: int):
	var viewport = get_viewport() 
	var vp = Vector2(viewport.size.x * (1 - page_size), viewport.size.y)

	var card = get_child(card_index)
	var card_sprite = card.get_node("Template").texture
	var card_size = Vector2(card_sprite.get_width() * card.scale.x, card_sprite.get_height() * card.scale.y)
		
	var section_width = vp.x / (page_layout.x + 1)
	var section_height = vp.y / (page_layout.y)
		
	var offset = Vector2(0, page_scroll)
	var xx = ((card_index % int(page_layout.x)) + 0.5) * section_width
	var yy = (floor(card_index / page_layout.x) + 0.5) * section_height

	return Vector2(xx, yy + page_scroll)
