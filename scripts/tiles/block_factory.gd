extends Node
class_name BlockFactory

const BLOCK_SCENE_MAP: Dictionary = {
    GlobalVars.ID_STONE_BLOCK: "res://scenes/tiles/stone_block.tscn",
}

static func create_block(row: int, col: int, type: int) -> Block:
    var block_scene: PackedScene = load(BLOCK_SCENE_MAP[type])
    var block_obj: Block = block_scene.instantiate()
    block_obj.set_block_grid_pos(row, col)
    return block_obj
