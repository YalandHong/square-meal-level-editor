extends Sprite2D
class_name Block

const BLOCK_SPRITE_OFFSET_Y: int = -20

# 定义 Block 基类的通用属性和方法
var current_row: int = 0
var current_col: int = 0
var walkable: bool = false
var eatable: bool = false
var dangerous: bool = false
var slippy: bool = false
var being_eaten: bool = false

func set_block_grid_pos(row: int, col: int) -> void:
    current_row = row
    current_col = col

    # 设置石头方块的在地图中的位置
    var spawn_x = GameManager.get_tile_top_left_x(col)
    var spawn_y = GameManager.get_tile_top_left_y(row)
    position = Vector2(spawn_x, spawn_y)

func is_walkable() -> bool:
    return walkable

func is_eatable() -> bool:
    return eatable

func is_dangerous() -> bool:
    return dangerous

func is_slippy() -> bool:
    return slippy

func is_being_eaten() -> bool:
    return being_eaten

func _init() -> void:
    offset.y = BLOCK_SPRITE_OFFSET_Y

func get_block_type() -> int:
    return GlobalVars.ID_INVALID
