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

func set_block_grid_pos(row: int, col: int) -> void:
    current_row = row
    current_col = col

    # 设置石头方块的在地图中的位置
    var spawn_x = GameManager.get_tile_top_left_x(col)
    var spawn_y = GameManager.get_tile_top_left_y(row)
    position = Vector2(spawn_x, spawn_y)

# 获取方法
func get_walkable() -> bool:
    return walkable

func get_eatable() -> bool:
    return eatable

func get_dangerous() -> bool:
    return dangerous

func get_slippy() -> bool:
    return slippy

func _init() -> void:
    offset.y = BLOCK_SPRITE_OFFSET_Y
