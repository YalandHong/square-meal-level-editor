extends Node2D
class_name GridElement

const UP = GlobalVars.UP
const DOWN = GlobalVars.DOWN
const LEFT = GlobalVars.LEFT
const RIGHT = GlobalVars.RIGHT
const NONE = GlobalVars.NONE

'''
Flash原版里，单步移动结束后是对齐到tile的center。
但由于Godot里，场景、control和sprite等很多组件的原点都是左上角。
所以我为了方便，设置了2套坐标。
一套是position的xy坐标，方便debug和sprite绘制，grid element单步移动结束时xy对齐到网格左上角。
另一套是Grid的row/col坐标，用于本游戏2D网格里各种交互和碰撞。
这些坐标的计算和相互转换，我在GridHelper里定义好了一套工具函数
'''

var dir: String
var moving_target_x: float
var moving_target_y: float
var current_row: int
var current_col: int

# 选择下一个格子作为移动目标
# Flash源码里叫get_target或者get next target
func try_step_forward_moving_target(target_dir: String) -> bool:
    assert(target_dir != NONE)
    var target_row = GridHelper.get_next_row_in_direction(current_row, target_dir)
    var target_col = GridHelper.get_next_col_in_direction(current_col, target_dir)
    if check_target_movable(target_row, target_col):
        do_change_moving_target(target_row, target_col, target_dir)
        return true
    return false

func do_change_moving_target(target_row: int, target_col: int, target_dir: String):
    moving_target_x = GridHelper.get_tile_top_left_x(target_col)
    moving_target_y = GridHelper.get_tile_top_left_y(target_row)
    dir = target_dir

func check_target_movable(target_row: int, target_col: int) -> bool:
    assert(false, "calling check_target_movable from abstract GridElement")
    return false

func reached_target() -> bool:
    return ((dir == LEFT and position.x <= moving_target_x) or
            (dir == RIGHT and position.x >= moving_target_x) or
            (dir == UP and position.y <= moving_target_y) or
            (dir == DOWN and position.y >= moving_target_y))

# debug function
func check_aligned_with_moving_target() -> bool:
    return ((dir == UP and position.x == moving_target_x) or
            (dir == DOWN and position.x == moving_target_x) or
            (dir == LEFT and position.y == moving_target_y) or
            (dir == RIGHT and position.y == moving_target_y))

# 初始化位置
func set_init_pos(row: int, col: int) -> void:
    position.x = GridHelper.get_tile_top_left_x(col)
    position.y = GridHelper.get_tile_top_left_y(row)
    moving_target_x = position.x
    moving_target_y = position.y
    current_row = row
    current_col = col
