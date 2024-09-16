extends Sprite2D
class_name Block

# GameManager 负责游戏全局的逻辑
var game_manager: GameManager
var sfx_player: SfxPlayer

const BLOCK_SPRITE_OFFSET_Y: int = -20

# direction常量
const UP = GlobalVars.UP
const DOWN = GlobalVars.DOWN
const LEFT = GlobalVars.LEFT
const RIGHT = GlobalVars.RIGHT
const NONE = GlobalVars.NONE

# 定义 Block 基类的通用属性和方法
var current_row: int = 0
var current_col: int = 0
var walkable: bool = false
var eatable: bool = false
var dangerous: bool = false
var slippy: bool = false
var being_eaten: bool = false

# 滑行相关
const START_SLIDE_SPEED: float = 10;
const SLIDE_SPEED = 10;
const start_max_tiles_moved = 100
var sliding: bool = false
var tiles_moved: int = 0;
var slide_speed: float = 10;
var max_tiles_moved: int = 100;
var slide_dir: String
var moving_target_x: float
var moving_target_y: float

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

func _ready() -> void:
    game_manager = get_parent()
    sfx_player = game_manager.get_parent().get_node("SfxPlayer")

func get_block_type() -> int:
    return GlobalVars.ID_INVALID

func start_slide(direction: String) -> void:
    # 初始化滑动速度和最大滑动距离
    slide_speed = START_SLIDE_SPEED
    max_tiles_moved = start_max_tiles_moved
    slide_dir = direction

    # 检查是否可以滑动到目标位置
    if is_next_step_empty():
        sliding = true
    else:
        sliding = false
        slide_dir = NONE

# 这个代码和player是一样的，预判下一个位置是否为空
func is_next_step_empty() -> bool:
    # 如果滑动的距离没有超过最大移动距离
    if tiles_moved >= max_tiles_moved:
        return false
    var target_row: int = GlobalVars.step_row_by_direction(current_row, slide_dir)
    var target_col: int = GlobalVars.step_col_by_direction(current_col, slide_dir)
    moving_target_x = GameManager.get_tile_center_x(target_col)
    moving_target_y = GameManager.get_tile_center_y(target_row)

    # 检查目标位置是否为空
    return game_manager.is_empty(target_row, target_col)

func finish_slide():
    sliding = false
    sfx_player.play_sfx("block_stops")
    slide_dir = NONE

func do_move() -> void:
    if slide_dir == NONE:
        return
    position = GlobalVars.step_position_by_speed(position, slide_dir, slide_speed)
    # TODO 更新深度和其他信息
    update_block_grid_pos()

# 和Player的update_player_grid_pos基本一样
func update_block_grid_pos():
    var new_row = GameManager.get_row(position.y)
    var new_col = GameManager.get_col(position.x)
    game_manager.update_blocks(self, current_row, current_col, new_row, new_col)

    current_row = new_row
    current_col = new_col

# TODO 这个函数的逻辑写得些莫名其妙
func slide() -> void:
    do_move()
    # TODO 预留的接口，检查碰撞
    #check_hit()

    # 检查是否到达目标位置
    if ((slide_dir == LEFT and position.x <= moving_target_x) or
       (slide_dir == RIGHT and position.x >= moving_target_x) or
       (slide_dir == UP and position.y <= moving_target_y) or
       (slide_dir == DOWN and position.y >= moving_target_y)):

        tiles_moved += 1
        position.x = moving_target_x
        position.y = moving_target_x
        update_block_grid_pos()

        # TODO 预留接口
        #adjust_slide_speed()

        # 尝试获取下一个目标位置
        if not is_next_step_empty():
            tiles_moved = 0
            if not check_rubber_block():  # 预留的接口
                #check_hit()  # 再次检查撞击
                #check_explosive_block()  # 预留的接口
                #check_wooden_block()  # 预留的接口
                finish_slide()  # 完成滑动

# TODO 暂不支持rubber block
func check_rubber_block() -> bool:
    return false
