extends GridElement
class_name Block

# GameManager 负责游戏全局的逻辑
var game_manager: GameManager
var sfx_player: SfxPlayer

const BLOCK_SPRITE_OFFSET_Y: int = -20

# 定义 Block 基类的通用属性和方法
#var walkable: bool = false
#var eatable: bool = false
#var dangerous: bool = false
#var slippy: bool = false
var being_eaten: bool = false

# 滑行相关
const START_SLIDE_SPEED: float = 10;
const SLIDE_SPEED = 10;
#const START_MAX_TILES_MOVED = 100
var sliding: bool = false
#var tiles_moved: int = 0;
var slide_speed: float = 10;
#var max_tiles_moved: int = 100;

var block_sprite: Sprite2D

func is_walkable() -> bool:
    return sliding

func is_eatable() -> bool:
    return false

func is_dangerous() -> bool:
    return false

func is_slippy() -> bool:
    return false

func is_being_eaten() -> bool:
    return being_eaten

func _init() -> void:
    block_sprite = Sprite2D.new()
    block_sprite.centered = false
    block_sprite.offset.y = BLOCK_SPRITE_OFFSET_Y
    sliding = false
    add_child(block_sprite)

func _ready() -> void:
    game_manager = get_parent()
    sfx_player = game_manager.get_parent().get_node("SfxPlayer")

# Flash原版是写在GameManager的moveBlocks了
# 也就是由game manager每帧统一对所有的block进行slide滑动
# 我这里没这样写，因为game manager要做的事情太多太杂了
func _process(_delta: float) -> void:
    if sliding:
        slide()
        # print("sliding block pos: ", position)
    z_index = GameManager.calculate_depth(position)

func get_block_type() -> int:
    return GlobalVars.ID_INVALID

func start_slide(start_dir: String) -> void:
    # 初始化滑动速度和最大滑动距离
    slide_speed = START_SLIDE_SPEED
    #max_tiles_moved = START_MAX_TILES_MOVED
    dir = start_dir

    # 检查是否可以滑动到目标位置
    if try_step_forward_moving_target(start_dir):
        sliding = true
    else:
        # TODO 这个分支什么时候会发生？目前测试结果是，会立刻停止
        sliding = false
        dir = NONE

func finish_slide():
    sliding = false
    sfx_player.play_sfx("block_stops")
    dir = NONE

func do_move() -> void:
    if dir == NONE:
        return
    position = GridHelper.step_position_by_speed(position, dir, slide_speed)
    update_block_grid_pos()

# 和Player的update_player_grid_pos基本一样
func update_block_grid_pos():
    var new_row = GridHelper.y_to_row(position.y)
    var new_col = GridHelper.x_to_col(position.x)
    game_manager.update_blocks(self, current_row, current_col, new_row, new_col)

    current_row = new_row
    current_col = new_col

# TODO 这个函数的逻辑写得些莫名其妙
# TODO 不同种类的block的slide行为都不太一样，不应该全部怼到一个函数里
func slide() -> void:
    assert(dir != NONE)
    do_move()
    check_hit()
    # 检查是否到达目标位置
    # 本质上是，划过了的话，要回退回来。因为moving target x/y是对齐网格左上角的
    # 所以，如果tile width或tile height不是speed的倍数，会导致速度不均匀
    if not reached_target():
        return
    #tiles_moved += 1
    position.x = moving_target_x
    position.y = moving_target_y
    update_block_grid_pos()
    # TODO 预留接口
    #adjust_slide_speed()
    if try_step_forward_moving_target(dir):
        return
    #tiles_moved = 0
    if check_rubber_block(): # 预留的接口
        return
    #check_explosive_block()  # 预留的接口
    check_wooden_block()
    finish_slide() # 完成滑动

# 有东西挡住了的，不能作为目标移动位置
func check_target_movable(target_row: int, target_col: int) -> bool:
    var enemy = game_manager.get_enemy_instance(target_row, target_col)
    if enemy != null and enemy is HelmetEnemy and enemy.ducking:
        return false
    return game_manager.get_tile_instance(target_row, target_col) == null

# TODO 暂不支持rubber block
func check_rubber_block() -> bool:
    return false

# 方块滑动时的碰撞检测
func check_hit() -> void:
    # 检查当前格子的敌人
    var enemy: Enemy = game_manager.get_enemy_instance(current_row, current_col)
    if enemy != null:
        enemy.do_hit_by_block(dir, self)
        do_hit_object()
        return

    # 检查当前格子的玩家
    var player: Player = game_manager.get_player_instance(current_row, current_col)
    if player != null:
        player.do_hit_by_block()
        do_hit_object()
        return

    # 根据滑动方向检查相邻格子内的敌人，并判断方向是否相反
    # TODO 根据get_opposite_direction和step_by_direction重构这段代码
    # TODO 这一大段代码意义不明
    if dir == LEFT:
        enemy = game_manager.get_enemy_instance(current_row, current_col - 1)
        if enemy != null and enemy.dir == RIGHT:
            enemy.do_hit_by_block(dir, self)
            do_hit_object()
            return
    elif dir == RIGHT:
        enemy = game_manager.get_enemy_instance(current_row, current_col + 1)
        if enemy != null and enemy.dir == LEFT:
            enemy.do_hit_by_block(dir, self)
            do_hit_object()
            return
    elif dir == UP:
        enemy = game_manager.get_enemy_instance(current_row - 1, current_col)
        if enemy != null and enemy.dir == DOWN:
            enemy.do_hit_by_block(dir, self)
            do_hit_object()
            return
    elif dir == DOWN:
        enemy = game_manager.get_enemy_instance(current_row + 1, current_col)
        if enemy != null and enemy.dir == UP:
            enemy.do_hit_by_block(dir, self)
            do_hit_object()
            return

func do_hit_object():
    pass

# 撞到wood block上会把对方撞碎
func check_wooden_block():
    var row = GridHelper.get_next_row_in_direction(current_row, dir)
    var col = GridHelper.get_next_col_in_direction(current_col, dir)
    var block = game_manager.get_tile_instance(row, col)
    if block != null and block is WoodBlock:
        block.do_break()
