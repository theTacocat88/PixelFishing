extends Node2D

var rng = RandomNumberGenerator.new()

# NOTE: Save data
var save_data: Dictionary = {}

# NOTE: Selector for throwing rod
@onready var catch_selector: Sprite2D = $Catch/CatchSelector
var selector_dir = 0
var move_selector = false
var selector_speed = 1000
var catch_val

# NOTE: Type of throw
enum CatchValue { TERRIBLE, BAD, DECENT, GOOD }

func _ready() -> void:
	rng.randomize()
	move_selector = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("LeftClick"):
		move_selector = false
		check_selector_pos()
	if move_selector:
		move_select(delta)

# NOTE: Saving Functionality
func save():
	var filepath: String = "user://pfsave.json"
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	if file == null:
		print("Save failed -> user://")
	var json_str = JSON.stringify(save_data)
	file.store_string(json_str)
	file.close()

func load_fish() -> Dictionary:
	var filepath: String = "res://data/fish.json"
	var file = FileAccess.open(filepath, FileAccess.READ)
	var json_str: String = file.get_as_text()
	var fish_list = JSON.parse_string(json_str)
	return fish_list

# NOTE: Move selector
func move_select(delta: float):
	if selector_dir == 0:
		catch_selector.position.x += selector_speed * delta
		if catch_selector.position.x >= 1350:
			selector_dir = 1
	elif selector_dir == 1:
		catch_selector.position.x -= selector_speed * delta
		if catch_selector.position.x <= 570:
			selector_dir = 0

# NOTE: Get the type of catch
func check_selector_pos():
	var fish_rarity = []
	if catch_selector.position.x >= 1285 or catch_selector.position.x <= 633.8:
		catch_val = CatchValue.TERRIBLE
		fish_rarity = ["COMMON", "UNCOMMON"]
	elif catch_selector.position.x >= 1174.2 or catch_selector.position.x <= 746.3:
		catch_val = CatchValue.BAD
		fish_rarity = ["COMMON", "UNCOMMON", "RARE"]
	elif catch_selector.position.x >= 1013.9 or catch_selector.position.x <= 905.8:
		catch_val = CatchValue.DECENT
		fish_rarity = ["COMMON", "UNCOMMON", "RARE", "LEGENDARY", "MYTHICAL"]
	elif catch_selector.position.x <= 1013.9 and catch_selector.position.x >= 905.8:
		catch_val = CatchValue.GOOD
		fish_rarity = ["COMMON", "UNCOMMON", "RARE", "LEGENDARY", "MYTHICAL", "EXOTIC"]
	else:
		catch_val = CatchValue.TERRIBLE
		fish_rarity = ["COMMON", "UNCOMMON"]
	catch(fish_rarity)

func catch(possible_rarity: Array):
	var fish: Dictionary = load_fish()
	var selected_rarity = possible_rarity.pick_random().to_lower()
	var fish_obj: Dictionary = \
		fish[selected_rarity][rng.randi_range(0, fish[selected_rarity].size() - 1)]
	var fish_name = fish_obj["name"]
	var fish_weight = rng.randi_range(fish_obj["minWeight"], fish_obj["maxWeight"])
	var fish_value = fish_obj["cost"] #CRITICAL
