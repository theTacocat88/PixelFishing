extends Node2D

# Signals
signal finish_catch

# Scripts
@onready var save_management = $Catch

# RNG
var rng = RandomNumberGenerator.new()

# Save data
var save_data: Dictionary = {}
# Chances rarities get picked
var WEIGHT_VALUES: Dictionary = {
	"COMMON": 125, 
	"UNCOMMON": 100, 
	"RARE": 50, 
	"LEGENDARY": 20, 
	"MYTHICAL": 10, 
	"EXOTIC": 5 
}

var GREEN_IN_FINISHING_BAR: Dictionary = {
	"terrible": [
		[146, 254],
		[254, 358],
		[362, 466],
		[470, 574],
		[826, 934],
		[722, 826],
		[614, 718]
	],
	"bad": [
		[350, 598],
		[482, 730],
		[702, 934],
		[146, 378]
	],
	"decent": [
		[146, 546],
		[534, 934],
		[350, 730]
	],
	"good": [
		[422, 934],
		[146, 658]
	]
}

# Selector for throwing the rod
@onready var catch_selector: Sprite2D = $Catch/CatchSelector
@onready var catch_bar_sprite: Sprite2D = $Catch/CatchBar
@onready var finishing_bar: Sprite2D = $Catch/FinishingBar
@onready var finishing_selector: Sprite2D = $Catch/FinishingSelector
var selector_dir = 0
var catch_selector_dir = 0
var move_selector = false
var move_finishing_selector = false
var selector_speed = 1000
var catch_val
var catch_val_string: String
var selecting = true
var finishing = false
var catch_successful
var current_finishing_texture

# Other variables
var weight_total
var finishing_multiplier = 1.2
var random_value_finishing: int

# Type of throw
enum CatchValue { TERRIBLE, BAD, DECENT, GOOD }

func _ready() -> void:
	# Init rng and other variables
	rng.randomize()
	move_selector = true
	move_finishing_selector = false
	finishing = false
	finishing_bar.z_index = -1
	finishing_bar.visible = false
	finishing_selector.visible = false

func _process(delta: float) -> void:
	# Check if rod is thrown
	if Input.is_action_just_pressed("LeftClick") and selecting:
		move_selector = false
		check_selector_pos()
	
	if Input.is_action_just_pressed("LeftClick") and finishing:
		move_finishing_selector = false
		check_finish_pos()
	
	# Check if you can move the selector
	if move_selector:
		move_select(delta)
	
	if move_finishing_selector:
		catch_bar(delta)

# Move the selector
func move_select(delta: float):
	if selector_dir == 0: # 0 = right
		catch_selector.position.x += selector_speed * delta
		if catch_selector.position.x >= 1350:
			selector_dir = 1
	elif selector_dir == 1: # 1 = left
		catch_selector.position.x -= selector_speed * delta
		if catch_selector.position.x <= 570:
			selector_dir = 0

# Get the type of catch
func check_selector_pos():
	var fish_rarity = []
	if catch_selector.position.x >= 1285 or catch_selector.position.x <= 633.8:
		catch_val = CatchValue.TERRIBLE
		catch_val_string = "terrible"
		fish_rarity = ["COMMON", "UNCOMMON"]
		weight_total = WEIGHT_VALUES["COMMON"] + WEIGHT_VALUES["UNCOMMON"]
	elif catch_selector.position.x >= 1174.2 or catch_selector.position.x <= 746.3:
		catch_val = CatchValue.BAD
		catch_val_string = "bad"
		fish_rarity = ["COMMON", "UNCOMMON", "RARE"]
		weight_total = WEIGHT_VALUES["COMMON"] + WEIGHT_VALUES["UNCOMMON"] + WEIGHT_VALUES["RARE"]
	elif catch_selector.position.x >= 1013.9 or catch_selector.position.x <= 905.8:
		catch_val = CatchValue.DECENT
		catch_val_string = "decent"
		fish_rarity = ["COMMON", "UNCOMMON", "RARE", "LEGENDARY", "MYTHICAL"]
		weight_total = WEIGHT_VALUES["COMMON"] + WEIGHT_VALUES["UNCOMMON"] + WEIGHT_VALUES["RARE"]\
			+ WEIGHT_VALUES["LEGENDARY"] + WEIGHT_VALUES["MYTHICAL"]
	elif catch_selector.position.x <= 1013.9 and catch_selector.position.x >= 905.8:
		catch_val = CatchValue.GOOD
		catch_val_string = "good"
		fish_rarity = ["COMMON", "UNCOMMON", "RARE", "LEGENDARY", "MYTHICAL", "EXOTIC"]
		weight_total = WEIGHT_VALUES["COMMON"] + WEIGHT_VALUES["UNCOMMON"] + WEIGHT_VALUES["RARE"]\
			+ WEIGHT_VALUES["LEGENDARY"] + WEIGHT_VALUES["MYTHICAL"] + WEIGHT_VALUES["EXOTIC"]
	else:
		catch_val = CatchValue.TERRIBLE
		catch_val_string = "terrible"
		fish_rarity = ["COMMON", "UNCOMMON"]
		weight_total = WEIGHT_VALUES["COMMON"] + WEIGHT_VALUES["UNCOMMON"]
	catch(fish_rarity)

# Finish the catch
func catch(possible_rarity: Array):
	# Weighted selection of fish based on type of throw
	var weighted = rng.randi_range(0, weight_total)
	var selected_rarity = null
	for rarity in possible_rarity:
		weighted -= WEIGHT_VALUES[rarity]
		if weighted <= 0:
			selected_rarity = rarity
			break
	
	throw_bar()
	
	selecting = false
	
	await get_tree().create_timer(0.000001).timeout
	
	finishing = true
	
	move_finishing_selector = true
	
	await finish_catch
	
	if catch_successful:
		select_catch(selected_rarity)
	else:
		pass

func select_catch(rarity):
	var fish: Dictionary = save_management.load_fish()
	# The selected fish
	var fish_obj: Dictionary = \
		fish[rarity.to_lower()]\
			[rng.randi_range(0, fish[rarity.to_lower()].size() - 1)]
	var fish_name = fish_obj["name"]
	var fish_weight = rng.randf_range(fish_obj["minWeight"], fish_obj["maxWeight"])
	var fish_value = fish_obj["cost"]
	# Formatting
	fish_weight = snapped(fish_weight, 0.01)
	# Show the fish
	print(fish_name + "\nWeight (lb): " + str(fish_weight) \
		+ "\nValue: " + str(fish_value))

func throw_bar():
	# Change to the catching bar
	match catch_val:
		CatchValue.TERRIBLE:
			random_value_finishing = rng.randi_range(1, 7)
			var texture: Texture2D = load("res://assets/catching/reeling/terrible/" + \
				str(random_value_finishing) + ".png")
			finishing_bar.texture = texture
			current_finishing_texture = texture
			catch_bar_sprite.visible = false
			catch_selector.visible = false
			finishing_bar.visible = true
			finishing_selector.visible = true
		CatchValue.BAD:
			random_value_finishing = rng.randi_range(1, 4)
			var texture: Texture2D = load("res://assets/catching/reeling/bad/" + \
				str(random_value_finishing) + ".png")
			finishing_bar.texture = texture
			current_finishing_texture = texture
			catch_bar_sprite.visible = false
			catch_selector.visible = false
			finishing_bar.visible = true
			finishing_selector.visible = true
		CatchValue.DECENT:
			random_value_finishing = rng.randi_range(1, 3)
			var texture: Texture2D = load("res://assets/catching/reeling/decent/" + \
				str(random_value_finishing) + ".png")
			finishing_bar.texture = texture
			current_finishing_texture = texture
			catch_bar_sprite.visible = false
			catch_selector.visible = false
			finishing_bar.visible = true
			finishing_selector.visible = true
		CatchValue.GOOD:
			random_value_finishing = rng.randi_range(1, 2)
			var texture: Texture2D = load("res://assets/catching/reeling/good/" + \
				str(random_value_finishing) + ".png")
			finishing_bar.texture = texture
			current_finishing_texture = texture
			catch_bar_sprite.visible = false
			catch_selector.visible = false
			finishing_bar.visible = true
			finishing_selector.visible = true

func catch_bar(delta: float):
	if catch_selector_dir == 0: # 0 = up
		finishing_selector.position.y -= (selector_speed * finishing_multiplier) * delta
		if finishing_selector.position.y <= 146:
			catch_selector_dir = 1
	elif catch_selector_dir == 1: # 1 = down
		finishing_selector.position.y += (selector_speed * finishing_multiplier) * delta
		if finishing_selector.position.y >= 934:
			catch_selector_dir = 0

func check_finish_pos():
	var current_range: Array = \
		GREEN_IN_FINISHING_BAR[catch_val_string][random_value_finishing - 1]
	if finishing_selector.position.y <= current_range[1] and \
	finishing_selector.position.y >= current_range[0]:
		catch_successful = true
		finish_catch.emit()
	else:
		catch_successful = false
		finish_catch.emit()
