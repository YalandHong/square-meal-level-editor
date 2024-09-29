extends Node
class_name GridHelper

const TILE_WIDTH: int = GlobalVars.TILE_WIDTH
const TILE_HEIGHT: int = GlobalVars.TILE_HEIGHT

# direction常量
const UP = GlobalVars.UP
const DOWN = GlobalVars.DOWN
const LEFT = GlobalVars.LEFT
const RIGHT = GlobalVars.RIGHT
const NONE = GlobalVars.NONE

# 返回给定列的tile的左上角X坐标
static func get_tile_top_left_x(col: int) -> float:
    return col * TILE_WIDTH

# 返回给定行的tile的左上角Y坐标
static func get_tile_top_left_y(row: int) -> float:
    return row * TILE_HEIGHT

# 返回给定列的tile的中心X坐标
static func get_tile_center_x(col: int) -> float:
    return get_tile_top_left_x(col) + TILE_WIDTH / 2.0

# 返回给定行的tile的中心Y坐标
static func get_tile_center_y(row: int) -> float:
    # TODO magic number 10
    #return get_tile_top_left_y(row) + TILE_HEIGHT / 2.0 + 10
    return get_tile_top_left_y(row) + TILE_HEIGHT / 2.0

# 用于获取行
static func y_to_row(y: float) -> int:
    return int(y / TILE_HEIGHT)

# 用于获取列
static func x_to_col(x: float) -> int:
    return int(x / TILE_WIDTH)

static func step_row_by_direction(row: int, dir: String) -> int:
    var new_row = row
    match dir:
        UP:
            new_row = row - 1
        DOWN:
            new_row = row + 1
    return new_row

static func step_col_by_direction(col: int, dir: String) -> int:
    var new_col = col
    match dir:
        LEFT:
            new_col = col - 1
        RIGHT:
            new_col = col + 1
    return new_col

static func step_position_by_speed(pos: Vector2, dir: String, speed: float) -> Vector2:
    match dir:
        LEFT:
            pos.x -= speed
        RIGHT:
            pos.x += speed
        UP:
            pos.y -= speed
        DOWN:
            pos.y += speed
    return pos

static func back_position_by_speed(pos: Vector2, dir: String, speed: float) -> Vector2:
    return step_position_by_speed(pos, dir, -speed)

static func is_opposite_direction(curr_dir: String, new_dir: String) -> bool:
    return ((curr_dir == LEFT and new_dir == RIGHT) or
           (curr_dir == RIGHT and new_dir == LEFT) or
           (curr_dir == UP and new_dir == DOWN) or
           (curr_dir == DOWN and new_dir == UP))
