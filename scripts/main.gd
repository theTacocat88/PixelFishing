extends Node2D

@onready var catch_selector: Sprite2D = $Catch/CatchSelector
var selector_dir = 0
var move_selector = false
var selector_speed = 1000
var catch_val

enum CatchValue { TERRIBLE, BAD, DECENT, GOOD }

func _ready() -> void:
	move_selector = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("LeftClick"):
		move_selector = false
		check_selector_pos()
	if move_selector:
		move_select(delta)
	
func move_select(delta: float):
	if selector_dir == 0:
		catch_selector.position.x += selector_speed * delta
		if catch_selector.position.x >= 1350:
			selector_dir = 1
	elif selector_dir == 1:
		catch_selector.position.x -= selector_speed * delta
		if catch_selector.position.x <= 570:
			selector_dir = 0

func check_selector_pos():
	if catch_selector.position.x >= 1285 or catch_selector.position.x <= 633.8:
		catch_val = CatchValue.TERRIBLE
	elif catch_selector.position.x >= 1174.2 or catch_selector.position.x <= 746.3:
		catch_val = CatchValue.BAD
	elif catch_selector.position.x >= 1013.9 or catch_selector.position.x <= 905.8:
		catch_val = CatchValue.DECENT
	elif catch_selector.position.x <= 1013.9 and catch_selector.position.x >= 905.8:
		catch_val = CatchValue.GOOD
	else:
		catch_val = CatchValue.TERRIBLE
