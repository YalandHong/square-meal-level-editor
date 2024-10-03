extends Block
class_name StoneBlock

func is_eatable():
    return not sliding

func _ready() -> void:
    super._ready()
    var loaded_texture = preload("res://sprites/block/stone.png")
    block_sprite.texture = loaded_texture

func get_block_type() -> int:
    return GlobalVars.ID_STONE_BLOCK
