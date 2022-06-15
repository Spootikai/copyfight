extends Node

const file_path : String = "user://tmp"
const file_path_img : String = "user://tmp/img/"
const file_path_dat : String = "user://tmp/dat/"

var version_data = {}
var data : Dictionary = {}

func _ready():
	refresh()

func refresh():
	query_version()
	
	var dir = Directory.new()
	if !dir.dir_exists(file_path):
		dir.open("user://")
		dir.make_dir("tmp")
	
	if !dir.dir_exists(file_path+"dat"):
		dir.open(file_path)
		dir.make_dir("dat")
		
	if !dir.dir_exists(file_path+"img"):
		dir.open(file_path)
		dir.make_dir("img")

# Query game version from google sheet
var google_sheet_id = "1U9qvJHQv-bZYa2KTT9Gzyl3M96A0OD29y92VdAwodMQ"
var tab_name = "version"
var api_key = "AIzaSyAxbIdqK48-p84vc1FQbluOwVjJuw4-luE"
func query_version():
	var request = HTTPRequest.new()
	self.add_child(request)
	
	request.connect("request_completed", self, "_query_version_return")
	request.request("https://sheets.googleapis.com/v4/spreadsheets/"+google_sheet_id+"/values/"+tab_name+"?alt=json&key="+api_key)
func _query_version_return(_result, _response_code, _headers, body):
	var parse = JSON.parse(body.get_string_from_utf8()).result.values
	version_data = parse
	check_card_data()

func check_card_data():
	for index in version_data.size():
		var set_string = str(version_data[index][0])
		var ver_string = str(version_data[index][1])
		
		var file = File.new()
		
		if !file.file_exists(file_path_dat+str(set_string)+".json"):
			print("Set "+set_string+" has no card data")
			print("Querying github...")
			query_data(set_string)
		else:
			var loaded_data = load_data(set_string)
			# Check if local (loaded) data is older than the online data
			if float(loaded_data["version"]) < float(ver_string):
				print("Set "+set_string+" version is out of date, removing it...")
				# Forcefully update all images if the data was out of date
				check_card_image(set_string, true)
				
				var dir = Directory.new()
				dir.remove(file_path_dat+set_string+".json")
				query_data(set_string)
			else:
				print("Set "+set_string+" version is up to date!")
				data[set_string] = loaded_data
		file.close()

# Query card data JSON from github repo
func query_data(set):
	var request = HTTPRequest.new()
	self.add_child(request)
	request.connect("request_completed", self, "_query_data_return")
	request.request("https://raw.githubusercontent.com/Spootikai/copyfight/main/"+set+".json")
func _query_data_return(_result, response_code, _headers, body):
	if response_code == 200:
		var parse = JSON.parse(body.get_string_from_utf8()).result
		print("Queried github data: "+parse["set"])
		save_data(parse["set"], body)
	else:
		print("[QUERY ERROR]: "+str(response_code))

# Query image data from github repo
func query_image(set: String, set_id: String):
	var request = HTTPRequest.new()
	self.add_child(request)
	
	request.set_download_file(file_path_img+set_id+".png")
	request.request("https://raw.githubusercontent.com/Spootikai/copyfight/main/"+set+"/"+set_id+".png")
	print("Queried github image: "+set_id)

func check_card_image(set: String, force: bool):
	var file = File.new()
	for set_id in data[set]["card"].keys():
		if force or !file.file_exists(file_path_img+set_id+".png"):
			query_image(set, set_id)
	
	file.close()

# Save and load card data by set name
func save_data(set: String, byteArray):
	var dir = Directory.new()
	dir.remove(file_path_dat+set+".json")
	
	var file = File.new()
	file.open(file_path_dat+set+".json", File.WRITE)
	file.store_buffer(byteArray)
	file.close()
	
	data[set] = parse_json(byteArray.get_string_from_utf8())
	check_card_image(set, false)

func load_data(set: String):
	var file = File.new()

	print("Loading data...")
	if !file.file_exists(file_path_dat+str(set)+".json"):
		print("ERR: NO CARD DATA FOUND")
	else:
		file.open(file_path_dat+str(set)+".json", File.READ)
		var parse = parse_json(file.get_as_text())
		file.close()
		
		if GlobalSettings.data["debug_mode"]:
			print(JSON.print(parse, "\t"))
		return parse

# Clear up all used HTTP request nodes
func _physics_process(_delta):
	for child in get_children():
		match child.get_http_client_status():
			0:
				child.queue_free()
