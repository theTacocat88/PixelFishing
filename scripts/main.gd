extends Node2D

@onready var catch_selector: Sprite2D = $Catch/CatchSelector
var selector_dir = 0
var move_selector = false

func _ready() -> void:
	move_selector = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("LeftClick"):
		move_selector = false
	if selector_dir == 0 and move_selector == true:
		catch_selector.position.x += 500 * delta
		if catch_selector.position.x >= 1350:
			selector_dir = 1
	elif selector_dir == 1 and move_selector == true:
		catch_selector.position.x -= 500 * delta
		if catch_selector.position.x <= 570:
			selector_dir = 0
