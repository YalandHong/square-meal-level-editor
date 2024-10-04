extends Node
class_name BlockFactory

static func is_valid_block_type(type: int) -> bool:
    return (
        (type in GlobalVars.ID_FOOD_BLOCK)
        or (type == GlobalVars.ID_STONE_BLOCK)
        or (type == GlobalVars.ID_WALL_BLOCK)
        or (type == GlobalVars.ID_WOOD_BLOCK)
        or (type == GlobalVars.ID_METAL_BLOCK)
        or (type == GlobalVars.ID_RUBBER_BLOCK)
        or (type == GlobalVars.ID_EXPLOSIVE_BLOCK)
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
        GlobalVars.ID_METAL_BLOCK:
            block_obj = MetalBlock.new()
        GlobalVars.ID_RUBBER_BLOCK:
            var block_scene: PackedScene = load("res://scenes/tile/rubber_block.tscn")
            block_obj = block_scene.instantiate()
        GlobalVars.ID_EXPLOSIVE_BLOCK:
            block_obj = ExplosiveBlock.new()
    return block_obj

static func create_triggered_explosive_block(row: int, col: int,
                                            explosion: Explosion) -> ExplosiveBlock:
    var block_obj = ExplosiveBlock.new()
    block_obj.triggered = true
    block_obj.explosion = explosion
    return block_obj
