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
const ID_WOOD_BLOCK: int = 3
const ID_DEFAULT_FOOD_BLOCK: int = 26
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

var current_level_file: String = ""
