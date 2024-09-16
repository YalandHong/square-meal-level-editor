extends Block
class_name FoodBlock

const FOOD_SCORE: int = 50

# Called when the node enters the scene tree for the first time.
func _init() -> void:
    super()
    eatable = true
