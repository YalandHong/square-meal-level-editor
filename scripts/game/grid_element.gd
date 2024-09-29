extends Node2D
class_name GridElement

const UP = GlobalVars.UP
const DOWN = GlobalVars.DOWN
const LEFT = GlobalVars.LEFT
const RIGHT = GlobalVars.RIGHT
const NONE = GlobalVars.NONE

var dir: String
var moving_target_x: float
var moving_target_y: float
var current_row: int
var current_col: int

func try_step_forward_moving_target(target_dir: String) -> bool:
    var target_row = GridHelper.step_row_by_direction(current_row, target_dir)
    var target_col = GridHelper.step_col_by_direction(current_col, target_dir)
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
