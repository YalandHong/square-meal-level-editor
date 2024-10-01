extends Node
class_name BlockFactory

static func is_valid_block_type(type: int) -> bool:
    return (
        (type in GlobalVars.ID_FOOD_BLOCK)
        or (type == GlobalVars.ID_STONE_BLOCK)
        or (type == GlobalVars.ID_WALL_BLOCK)
        or (type == GlobalVars.ID_WOOD_BLOCK)
    )

static func create_block(row: int, col: int, type: int) -> Block:
    var block_obj: Block
    if type in GlobalVars.ID_FOOD_BLOCK:
        block_obj = FoodBlock.new()
    else:
        block_obj = allocate_non_food_block(type)
    block_obj.set_init_pos(row, col)
    return block_obj

static func allocate_non_food_block(type: int) -> Block:
    var block_obj: Block
    match type:
        GlobalVars.ID_STONE_BLOCK:
            block_obj = StoneBlock.new()
        GlobalVars.ID_WALL_BLOCK:
            block_obj = WallBlock.new()
        GlobalVars.ID_WOOD_BLOCK:
            var block_scene: PackedScene = load("res://scenes/tile/wood_block.tscn")
            block_obj = block_scene.instantiate()
    return block_obj
