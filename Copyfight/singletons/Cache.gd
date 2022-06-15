extends Node

# Gonna need to thread this eventually :/

const video = preload("res://assets/video/naruto.ogv")

var textures : Dictionary

func _ready():
	loadImages(GlobalCard.file_path_img)

func loadImages(path):
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif !file.begins_with("."):
			var image = Image.new()
			var _err = image.load(path+file)
			
			var texture = ImageTexture.new()
			texture.create_from_image(image, 0)
			
			textures[file.get_basename()] = texture
	
	dir.list_dir_end()
	print("LOADING COMPLETE")
