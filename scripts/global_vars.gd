extends Node
class_name GlobalVars

const VIEW_WIDTH: int = 550
const VIEW_HEIGHT: int = 400

const TILE_WIDTH: int = 50
const TILE_HEIGHT: int = 30

# 为了保持和源Flash的兼容，我这里ID都是用的解包出来的值
# 正常来说不应该这么做，而是应该定义为枚举然后让Godot自动赋值
# 否则，无法检查两个ID是否冲突

# 一般用作debug或者初始化为非法值，正常逻辑里不使用
const ID_INVALID: int = -1

const ID_EMPTY_TILE: int = 0

const ID_PLAYER: int = 19

# block id
const ID_STONE_BLOCK: int = 1
const ID_FOOD_BLOCK: Array[int] = [26,27,28, 48,49,50,51,52,53]
# Flash原版里30~36都是wall block，这里我偷懒暂时先不处理
const ID_WALL_BLOCK: int = 30

const ID_SLIDING_BLOCK_PRESERVED: int = 200

# enemy id
const ID_DUMB_ENEMY: int = 21
const ID_CHARGING_ENEMY: int = 24
const ID_HELMET_ENEMY: int = 25
const ID_LEAPING_ENEMY: int = 44

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
