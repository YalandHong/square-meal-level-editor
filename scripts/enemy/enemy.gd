extends Node2D
class_name Enemy

var game_manager: GameManager
var shadow_holder: ShadowManager
var sfx_player: SfxPlayer

var anim_sprite: AnimatedSprite2D

# direction常量
const UP = GlobalVars.UP
const DOWN = GlobalVars.DOWN
const LEFT = GlobalVars.LEFT
const RIGHT = GlobalVars.RIGHT
const NONE = GlobalVars.NONE

# 定义相关变量
var being_eaten: bool

var stunned: bool
var stunned_count: int
const MAX_STUNNED_COUNT: int = 150

# Flash里移过来的，意义不明的变量
#var tiles_moved: int = 0

var jumping: bool

var dir: String
var moving_target_x: float
var moving_target_y: float
var current_row: int
var current_col: int
const MOVE_SPEED: float = 2 # 每个enemy不太一样吧？

func _init() -> void:
    jumping = false
    stunned = false
    being_eaten = false

func _ready():
    game_manager = get_parent()
    sfx_player = game_manager.get_parent().get_node("SfxPlayer")

    set_enemy_sprite()
    anim_sprite.centered = false
    # anim_sprite.animation_finished.connect(on_animation_finished)

    # 设置初始方向
    dir = NONE
    try_change_direction()
    assert(check_aligned_with_moving_target())

func _process(_delta: float) -> void:
    z_index = GameManager.calculate_depth(position)

    if being_eaten:
        return # 如果已经被吃掉，则不进行任何处理

    if stunned:
        handle_stunned()
        return

    handle_movement_or_jump()
    assert(check_aligned_with_moving_target())

# func on_animation_finished():
#     assert(jumping)
#     finish_jump()

func set_enemy_init_pos(row: int, col: int) -> void:
    position.x = GridHelper.get_tile_top_left_x(col)
    position.y = GridHelper.get_tile_top_left_y(row)
    z_index = GameManager.calculate_depth(position)

    current_row = row
    current_col = col

func handle_stunned() -> void:
    stunned_count += 1
    if stunned_count < MAX_STUNNED_COUNT:
        return
    wake_up()

func wake_up():
    update_mover_grid_pos()
    if not try_step_forward_moving_target(dir):
        try_change_direction()
        #tiles_moved = 0

    play_walk_animation()
    stunned = false

func handle_movement_or_jump() -> void:
    do_move()
    check_hit_players()

    if not reached_target():
        return

    #tiles_moved += 1
    position = Vector2(moving_target_x, moving_target_y)
    update_mover_grid_pos()

    if jumping:
        finish_jump()
        return

    if not try_step_forward_moving_target(dir):
        try_change_direction()
        #tiles_moved = 0


func do_move() -> void:
    if dir == NONE:
        return
    position = GlobalVars.step_position_by_speed(position, dir, MOVE_SPEED)
    update_mover_grid_pos()

func update_mover_grid_pos():
    var new_row = GridHelper.y_to_row(position.y)
    var new_col = GridHelper.x_to_col(position.x)
    game_manager.update_movers(self, current_row, current_col, new_row, new_col)

    current_row = new_row
    current_col = new_col

# TODO 这个函数也在player和block里用到了
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

func finish_jump() -> void:
    assert(jumping and not stunned and not being_eaten)

    jumping = false
    stunned = true
    stunned_count = 0
    play_stunned_animation()

# Flash原版叫get next target
func try_step_forward_moving_target(target_dir: String) -> bool:
    assert(false, "calling try_step_forward_moving_target from abstract enemy")
    return false

func try_change_direction() -> bool:
    assert(false, "calling change_direction from abstract enemy")
    return false

func play_walk_animation() -> void:
    anim_sprite.play("walk_" + dir)

func play_jump_animation() -> void:
    anim_sprite.play("hit_" + dir)

func play_stunned_animation() -> void:
    anim_sprite.play("stunned_" + dir)


func check_hit_players() -> void:
    if jumping or stunned:
        return
    var player: Player = game_manager.get_player_instance(current_row, current_col)
    if player == null:
        return
    player.die()

func set_enemy_sprite() -> void:
    assert(false, "calling set_enemy_sprite from abstract enemy")
    pass

# var col: int = 0
# var row: int = 0

# 处理敌人被block击中的逻辑
# func do_hit_by_block(block_dir: String) -> void:
#     if jumping:
#         return
#     update_mover_grid_pos()
#     force_align_position_to_grid()
#     var target_dir = get_opposite_dir(block_dir)
#     var target_col = game_manager.step_col_by_direction(current_col, target_dir)
#     var target_row = game_manager.step_row_by_direction(current_row, target_dir)
#     if GameManager.is_tile_empty(target_col, target_row):
#         move_to_tile(target_col, target_row)
#     else:
#         bounce_back(block_dir)

# 将敌人对齐网格
func force_align_position_to_grid() -> void:
    var center_x = GridHelper.get_tile_top_left_x(current_col)
    var center_y = GridHelper.get_tile_top_left_y(current_row)
    position = Vector2(center_x, center_y)

# # 返回相反的方向
# func get_opposite_dir(block_dir: String) -> String:
#     match block_dir:
#         UP:
#             return DOWN
#         DOWN:
#             return UP
#         LEFT:
#             return RIGHT
#         RIGHT:
#             return LEFT
#         _:
#             return NONE

# # 将敌人移动到指定的tile
# func move_to_tile(target_col: int, target_row: int) -> void:
#     col = target_col
#     row = target_row
#     var center_x = GameManager.get_center_x(col)
#     var center_y = GameManager.get_center_y(row)
#     position = Vector2(center_x, center_y)

# # 如果目标格子不为空，执行反弹逻辑
# func bounce_back(block_dir: String) -> void:
#     var bounce_dir = get_opposite_dir(block_dir)
#     # var target_col, target_row = get_target_tile(bounce_dir)
#     move_to_tile(target_col, target_row)

# 更新敌人的位置
# TODO 这个函数是干嘛的？意义不明
func update_position(new_dir: String) -> void:
    pass
    # if new_dir == LEFT or new_dir == RIGHT:
    #     position.y = GridHelper.get_tile_center_y(current_row)
    # else:
    #     position.x = GridHelper.get_tile_center_x(current_col)


func do_hit_by_block(block_dir: String, block: Block) -> void:
    if jumping:
        return

    update_mover_grid_pos()

    # enemy被击飞的时候，是从一个对齐网格的位置开始起飞，到另一个对齐网格的位置落地
    force_align_position_to_grid()

    var hit_successful: bool = false

    # 判断方向并尝试移动
    match block_dir:
        LEFT:
            hit_successful = handle_hit_left(block)
        RIGHT:
            hit_successful = handle_hit_right(block)
        UP:
            hit_successful = handle_hit_up(block)
        DOWN:
            hit_successful = handle_hit_down(block)

    if not hit_successful:
        fallback_movement(block)

    perform_jump()

# 处理向左被击中的逻辑
func handle_hit_left(block: Block) -> bool:
    if try_move(RIGHT, 0, 1, block):
        return true
    elif try_move(DOWN, 1, 0, block):
        return true
    elif try_move(UP, -1, 0, block):
        return true
    elif try_move(RIGHT, 0, 2, block):
        return true
    return false

# 处理向右被击中的逻辑
func handle_hit_right(block: Block) -> bool:
    if try_move(LEFT, 0, -1, block):
        return true
    elif try_move(DOWN, 1, 0, block):
        return true
    elif try_move(UP, -1, 0, block):
        return true
    elif try_move(LEFT, 0, -2, block):
        return true
    return false

# 处理向上被击中的逻辑
func handle_hit_up(block: Block) -> bool:
    if try_move(DOWN, 1, 0, block):
        return true
    elif try_move(RIGHT, 0, 1, block):
        return true
    elif try_move(LEFT, 0, -1, block):
        return true
    elif try_move(DOWN, 2, 0, block):
        return true
    return false

# 处理向下被击中的逻辑
func handle_hit_down(block: Block) -> bool:
    if try_move(UP, -1, 0, block):
        return true
    elif try_move(RIGHT, 0, 1, block):
        return true
    elif try_move(LEFT, 0, -1, block):
        return true
    elif try_move(UP, -2, 0, block):
        return true
    return false

# 尝试移动到指定的相对位置，并更新相关参数
# TODO 应该命名为try jump to
func try_move(new_dir: String, row_offset: int, col_offset: int, block: Block) -> bool:
    # var game_manager = get_node("/root/GameManager")

    if check_landable(current_row + row_offset, current_col + col_offset, block):
        var target_row = current_row + row_offset
        var target_col = current_col + col_offset
        do_change_moving_target(target_row, target_col, new_dir)
        update_position(new_dir)
        return true

    return false

# 移动失败时的回退逻辑
func fallback_movement(block: Block) -> void:
    if try_move(LEFT, 0, -1, block):
        return
    elif try_move(RIGHT, 0, 1, block):
        return
    elif try_move(UP, -1, 0, block):
        return
    elif try_move(DOWN, 1, 0, block):
        return
    assert(false, "no place for fallback")

# 执行跳跃动作
func perform_jump() -> void:
    stunned = false
    jumping = true
    sfx_player.play_sfx("stun")
    play_jump_animation()
    # TODO shadow暂不支持
    # get_node("/root/GameManager/shadow_holder/enemy_shadow_%s" % str(enemy_id)).goto_and_play("jump")

# 设置目标位置和方向
# TODO 移动到grid element中
func do_change_moving_target(target_row: int, target_col: int, target_dir: String):
    moving_target_x = GridHelper.get_tile_top_left_x(target_col)
    moving_target_y = GridHelper.get_tile_top_left_y(target_row)
    dir = target_dir

# 一般来说，敌人要选择一个空的位置作为击飞后落地的位置
# 这个“空的位置”不仅要求没东西，还不能有其它正在移动的敌人朝这里移动
func check_landable(row: int, col: int, hit_block: Block) -> bool:
    if game_manager.is_empty(row, col):
        for possible_dir in [UP, DOWN, LEFT, RIGHT]:
            var adj_row = GridHelper.step_row_by_direction(row, possible_dir)
            var adj_col = GridHelper.step_col_by_direction(col, possible_dir)
            var adjacent_enemy: Enemy = game_manager.get_enemy_instance(adj_row, adj_col)
            if (adjacent_enemy != null
                and GridHelper.y_to_row(adjacent_enemy.moving_target_y) == row
                and GridHelper.x_to_col(adjacent_enemy.moving_target_x) == col):
                return false
        return true
    elif hit_block != null and game_manager.get_tile_instance(row, col) == hit_block:
        return true

    return false
