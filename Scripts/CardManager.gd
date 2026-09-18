extends Node

var cards_db: Dictionary = {}
var card_resources: Dictionary = {}
var card_logic_controller: CardLogicController

func _ready():
	card_logic_controller = CardLogicController.new()
	add_child(card_logic_controller)
	load_card_resources()

func load_card_resources():
	cards_db.clear()
	card_resources.clear()
	
	var categories = ["Opportunity", "Flash", "Oops", "Stock"]
	var total_loaded = 0
	
	for cat in categories:
		var dir_path = "res://Data/Cards/" + cat + "/"
		var dir = DirAccess.open(dir_path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir() and file_name.ends_with(".tres"):
					var res_path = dir_path + file_name
					var res = load(res_path)
					if res and res is CardResource:
						card_resources[str(res.id)] = res
						cards_db[str(res.id)] = res.to_dict()
						total_loaded += 1
				file_name = dir.get_next()
		else:
			print("Warning: Could not open directory ", dir_path)
			
	# Fallback to cards_db.json if any are missing
	if cards_db.is_empty():
		var file = FileAccess.open("res://Data/cards_db.json", FileAccess.READ)
		if file:
			var json_str = file.get_as_text()
			var json = JSON.new()
			if json.parse(json_str) == OK and json.data is Dictionary:
				cards_db = json.data
				
	print("Loaded ", total_loaded, " modular card resources into CardManager (Total in DB: ", cards_db.size(), ")")

func get_card_resource(card_id: Variant) -> CardResource:
	var key = str(card_id)
	if card_resources.has(key):
		return card_resources[key]
	return null

func get_card(card_id: Variant) -> Dictionary:
	var key = str(card_id)
	if cards_db.has(key):
		return cards_db[key]
	return {}

func get_random_card_by_type(type: String) -> Dictionary:
	if cards_db.is_empty(): return {}
	var matching_keys = []
	for key in cards_db.keys():
		var c_type = cards_db[key].get("type", "")
		# Match Stock or Stocks
		if c_type == type or (type == "Stock" and c_type == "Stocks") or (type == "Stocks" and c_type == "Stock"):
			# Check interdependency prerequisites
			var cid = int(cards_db[key].get("id", key))
			if card_logic_controller and card_logic_controller.can_draw_card(cid):
				matching_keys.append(key)
				
	if matching_keys.is_empty():
		# Fallback to any card of that type without condition
		for key in cards_db.keys():
			var c_type = cards_db[key].get("type", "")
			if c_type == type or (type == "Stock" and c_type == "Stocks"):
				matching_keys.append(key)
				
	if matching_keys.is_empty(): return {}
	var random_key = matching_keys[randi() % matching_keys.size()]
	return cards_db[random_key]