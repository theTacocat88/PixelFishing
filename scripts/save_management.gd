extends Node

# NOTE: Saving Functionality
func save(save_data: Dictionary):
	var filepath: String = "user://pfsave.json"
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file == null:
		print("Save failed -> user://")
	var json_str = JSON.stringify(save_data)
	file.store_string(json_str)
	file.close()

# Load the fish JSON file
func load_fish() -> Dictionary:
	var filepath: String = "res://data/fish.json"
	var file = FileAccess.open(filepath, FileAccess.READ)
	var json_str: String = file.get_as_text()
	var fish_list = JSON.parse_string(json_str)
	return fish_list
