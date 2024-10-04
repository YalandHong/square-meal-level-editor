extends Node
class_name GlobalVars

# 全局常量

const WINDOW_WIDTH: int = 825
const WINDOW_HEIGHT: int = 600

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

# 暂时不支持双人游戏
const ID_ANOTHER_PLAYER: int = 20

# block id
const ID_STONE_BLOCK: int = 1
const ID_METAL_BLOCK: int = 2
const ID_WOOD_BLOCK: int = 3
const ID_RUBBER_BLOCK: int = 22
const ID_EXPLOSIVE_BLOCK: int = 23
const ID_DEFAULT_FOOD_BLOCK: int = 26
const ID_FOOD_BLOCK: Array[int] = [26,27,28, 48,49,50,51,52,53]
# Flash原版里wall block有很多id，更精确地控制sprite
# 4~18是普通的wall block
# 30~36是带锁链的wall block
# 37~43是带火把的wall block
# 这里我偷懒暂时先不处理
const ID_WALL_BLOCK: int = 30

# 目前未用到
const ID_SLIDING_BLOCK_PRESERVED: int = 200

# enemy id
const ID_DUMB_ENEMY: int = 21
const ID_CHARGING_ENEMY: int = 24
const ID_HELMET_ENEMY: int = 25
const ID_LEAPING_ENEMY: int = 44

# floor tile id
const ID_SPIKE_FLOOR: int = 29
const ID_SPIKE_HOLE_FLOOR: int = 45
const ID_TRIGGER_FLOOR: int = 46
# Flash原版47、54、55、56都是slippy block，不同sprite而已
# 这里我偷懒暂时先不处理
const ID_SLIPPY_FLOOR: int = 47

# directions
const UP = "up"
const DOWN = "down"
const LEFT = "left"
const RIGHT = "right"
const NONE = ""

const FRAME_RATE = 30

const DEPTH_UI_ELEMENTS = 3000
const DEPTH_EPLOSION = 1000
