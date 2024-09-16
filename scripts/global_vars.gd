extends Node

# 一般用作debug或者初始化为非法值，正常逻辑里不使用
const ID_INVALID: int = -1

const ID_EMPTY_TILE: int = 0

const ID_PLAYER: int = 19

# block id
const ID_STONE_BLOCK: int = 1
const ID_FOOD_BLOCK: Array[int] = [26,27,28, 48,49,50,51,52,53]

# directions
const UP = "up"
const DOWN = "down"
const LEFT = "left"
const RIGHT = "right"
const NONE = ""

static func step_row_by_direction(row:int, dir: String) -> int:
    var new_row = row
    match dir:
        UP:
            new_row = row - 1
        DOWN:
            new_row = row + 1
    return new_row

static func step_col_by_direction(col:int, dir: String) -> int:
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
