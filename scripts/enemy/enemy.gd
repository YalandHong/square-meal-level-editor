extends GridElement
class_name Enemy

var game_manager: GameManager

var anim_sprite: AnimatedSprite2D

# 定义相关变量
var being_eaten: bool

var stunned: bool
var stunned_count: int
const MAX_STUNNED_COUNT: int = 150

var jumping: bool

const MOVE_SPEED: float = 2

func _init() -> void:
    jumping = false
    stunned = false
    being_eaten = false

func _ready():
    game_manager = get_parent()

    set_enemy_sprite()
    anim_sprite.centered = false

    # 随机选择一个初始方向，默认是向下
    dir = NONE
    if not try_change_direction():
        dir = DOWN
    play_walk_animation()
    assert(check_aligned_with_moving_target())

func _process(_delta: float) -> void:
    # 当enemy和其他block等元素深度相同时，挡在block和player前面
    z_index = GameManager.calculate_depth(position) + 2

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

func handle_stunned() -> void:
    # 这里update mover原因是，如果有多个敌人叠在一起
    # 可能会导致短时间内game manager一个格子上的敌人相互覆盖
    # 但是等敌人散开以后，处于击晕状态要及时更新game manager中自己的位置
    # 不然player无法与这个敌人交互
    update_mover_grid_pos()
    stunned_count += 1
    if stunned_count < MAX_STUNNED_COUNT:
        return
    wake_up()

func wake_up():
    #update_mover_grid_pos()
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
    position = Vector2(moving_target_x, moving_target_y)
    update_mover_grid_pos()
    if jumping:
        finish_jump()
        return
    if not try_step_forward_moving_target(dir):
        try_change_direction()


func do_move() -> void:
    if dir == NONE:
        return
    position = GridHelper.step_position_by_speed(position, dir, MOVE_SPEED)
    update_mover_grid_pos()

func update_mover_grid_pos():
    var new_row = GridHelper.y_to_row(position.y)
    var new_col = GridHelper.x_to_col(position.x)
    game_manager.update_movers(self, current_row, current_col, new_row, new_col)

    current_row = new_row
    current_col = new_col

func finish_jump() -> void:
    assert(jumping and not stunned and not being_eaten)

    jumping = false
    stunned = true
    stunned_count = 0
    play_stunned_animation()

# 获取当前方向可能的其他方向
func get_possible_directions() -> Array:
    match dir:
        LEFT:
            return [RIGHT, UP, DOWN]
        RIGHT:
            return [LEFT, UP, DOWN]
        UP:
            return [LEFT, RIGHT, DOWN]
        DOWN:
            return [LEFT, RIGHT, UP]
        _:
            return [LEFT, RIGHT, UP, DOWN]

# 改变敌人方向的主逻辑
func try_change_direction() -> bool:
    var possible_directions = get_possible_directions()
    possible_directions.shuffle() # 打乱方向顺序

    for possible_dir in possible_directions:
        if try_step_forward_moving_target(possible_dir):
            play_walk_animation()
            return true
    #assert(false, "try change direction failed")
    # 如果所有方向都被堵住了，那就什么都不做
    return false

func play_walk_animation() -> void:
    assert(false)

func play_jump_animation() -> void:
    assert(false)

func play_stunned_animation() -> void:
    assert(false)

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

# 将敌人对齐网格
func force_align_position_to_grid() -> void:
    var center_x = GridHelper.get_tile_top_left_x(current_col)
    var center_y = GridHelper.get_tile_top_left_y(current_row)
    position = Vector2(center_x, center_y)

# 已经被击飞在空中的敌人不会被击中
func do_hit_by_block(block: Block) -> bool:
    if jumping:
        return false

    update_mover_grid_pos()

    # enemy被击飞的时候，是从一个对齐网格的位置开始起飞，到另一个对齐网格的位置落地
    force_align_position_to_grid()

    # 判断方向并尝试移动
    var hit_successful: bool = false
    match block.dir:
        LEFT:
            hit_successful = handle_hit_left(block)
        RIGHT:
            hit_successful = handle_hit_right(block)
        UP:
            hit_successful = handle_hit_up(block)
        DOWN:
            hit_successful = handle_hit_down(block)
    # 敌人很密集的时候，有可能会找不到落地的地方
    # 那就只能击飞到moving target所在的格子，不管那个格子是否空闲
    #assert(hit_successful)
    if not hit_successful:
        print("not landable, just jump")
    perform_jump()
    return true

# 处理向左被击中的逻辑
func handle_hit_left(block: Block) -> bool:
    if try_jump_to(RIGHT, 0, 1, block):
        return true
    elif try_jump_to(DOWN, 1, 0, block):
        return true
    elif try_jump_to(UP, -1, 0, block):
        return true
    elif try_jump_to(RIGHT, 0, 2, block):
        return true
    return false

# 处理向右被击中的逻辑
func handle_hit_right(block: Block) -> bool:
    if try_jump_to(LEFT, 0, -1, block):
        return true
    elif try_jump_to(DOWN, 1, 0, block):
        return true
    elif try_jump_to(UP, -1, 0, block):
        return true
    elif try_jump_to(LEFT, 0, -2, block):
        return true
    return false

# 处理向上被击中的逻辑
func handle_hit_up(block: Block) -> bool:
    if try_jump_to(DOWN, 1, 0, block):
        return true
    elif try_jump_to(RIGHT, 0, 1, block):
        return true
    elif try_jump_to(LEFT, 0, -1, block):
        return true
    elif try_jump_to(DOWN, 2, 0, block):
        return true
    return false

# 处理向下被击中的逻辑
func handle_hit_down(block: Block) -> bool:
    if try_jump_to(UP, -1, 0, block):
        return true
    elif try_jump_to(RIGHT, 0, 1, block):
        return true
    elif try_jump_to(LEFT, 0, -1, block):
        return true
    elif try_jump_to(UP, -2, 0, block):
        return true
    return false

# 尝试移动到指定的相对位置，并更新相关参数
func try_jump_to(new_dir: String, row_offset: int, col_offset: int, block: Block) -> bool:
    # var game_manager = get_node("/root/GameManager")

    if check_landable(current_row + row_offset, current_col + col_offset, block):
        var target_row = current_row + row_offset
        var target_col = current_col + col_offset
        do_change_moving_target(target_row, target_col, new_dir)
        return true

    return false

# 执行跳跃动作
func perform_jump() -> void:
    stunned = false
    jumping = true
    SfxPlayerSingleton.play_sfx("stun")
    play_jump_animation()
    # TODO shadow暂不支持
    # get_node("/root/GameManager/shadow_holder/enemy_shadow_%s" % str(enemy_id)).goto_and_play("jump")

# 有东西挡住了的，不能作为目标移动位置
# 目标位置已经是其它敌人或者方块的移动目标了，也不行
func check_target_movable(target_row: int, target_col: int) -> bool:
    if (game_manager.get_block_instance(target_row, target_col) != null):
        return false
    if (game_manager.get_enemy_instance(target_row, target_col) != null):
        return false
    for possible_dir in [UP, DOWN, LEFT, RIGHT]:
        var adj_row = GridHelper.get_next_row_in_direction(target_row, possible_dir)
        var adj_col = GridHelper.get_next_col_in_direction(target_col, possible_dir)
        var adjacent_enemy: Enemy = game_manager.get_enemy_instance(adj_row, adj_col)
        if (adjacent_enemy != null
            and GridHelper.y_to_row(adjacent_enemy.moving_target_y) == target_row
            and GridHelper.x_to_col(adjacent_enemy.moving_target_x) == target_col):
            return false
        var adjacent_sliding_block: Block = game_manager.get_block_instance(adj_row, adj_col)
        if (adjacent_sliding_block != null and adjacent_sliding_block.sliding
            and GridHelper.y_to_row(adjacent_sliding_block.moving_target_y) == target_row
            and GridHelper.x_to_col(adjacent_sliding_block.moving_target_x) == target_col):
            return false
    return true

# 一般来说，敌人要选择一个空的位置作为击飞后落地的位置
# 这个“空的位置”不仅要求没东西，还不能有其它正在移动的敌人朝这里移动
func check_landable(row: int, col: int, hit_block: Block) -> bool:
    if game_manager.is_empty(row, col):
        for possible_dir in [UP, DOWN, LEFT, RIGHT]:
            var adj_row = GridHelper.get_next_row_in_direction(row, possible_dir)
            var adj_col = GridHelper.get_next_col_in_direction(col, possible_dir)
            var adjacent_enemy: Enemy = game_manager.get_enemy_instance(adj_row, adj_col)
            if (adjacent_enemy != null
                and GridHelper.y_to_row(adjacent_enemy.moving_target_y) == row
                and GridHelper.x_to_col(adjacent_enemy.moving_target_x) == col):
                return false
        return true

    # [row][col] is not empty
    assert(hit_block != null)
    if game_manager.get_block_instance(row, col) == hit_block:
        return true

    return false

func be_exploded():
    game_manager.remove_enemy(current_row, current_col)
    queue_free()

func be_eaten_by_player(player: Player):
    player.add_score(100)
    game_manager.remove_enemy(current_row, current_col)
    queue_free()
