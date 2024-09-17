extends Node
class_name BlockFactory

static func is_valid_block_type(type: int) -> bool:
    return ( (type in GlobalVars.ID_FOOD_BLOCK)
        or (type == GlobalVars.ID_STONE_BLOCK))

static func create_block(row: int, col: int, type: int) -> Block:
    var block_obj: Block
    if type in GlobalVars.ID_FOOD_BLOCK:
        block_obj = FoodBlock.new()
    else:
        block_obj = allocate_non_food_block(type)
    block_obj.set_block_grid_pos(row, col)
    return block_obj

static func allocate_non_food_block(type: int) -> Block:
    var block_obj: Block
    match type:
        GlobalVars.ID_STONE_BLOCK:
            block_obj = StoneBlock.new()
    return block_obj
