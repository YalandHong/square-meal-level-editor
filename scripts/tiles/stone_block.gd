extends Block
class_name StoneBlock

# Called when the node enters the scene tree for the first time.
func _init() -> void:
    super()
    eatable = true

func get_block_type() -> int:
    return GlobalVars.ID_STONE_BLOCK
