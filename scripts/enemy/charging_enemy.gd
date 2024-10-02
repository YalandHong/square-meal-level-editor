extends Enemy
class_name ChargingEnemy

const SPRITE_OFFSET_NORMAL: Vector2 = Vector2(
    -71 / 2 + GameManager.TILE_WIDTH / 2,
    -GameManager.TILE_HEIGHT / 2 - 78
)

const ANIMATION_FPS_SCALE_WALK: float = 0.5
const ANIMATION_FPS_SCALE_HIT: float = 0.8

# 冲刺相关
var charging: bool = false
const CHARGE_SPEED: float = 4

# 绕路相关
var detouring: bool = false
var expected_dir: String

func handle_movement_or_jump():
    if charging:
        do_charge()
    else:
        do_move()
    check_hit_players()
    if not reached_target():
        return
    handle_reached_moving_target()

func handle_reached_moving_target():
    position = Vector2(moving_target_x, moving_target_y)
    update_mover_grid_pos()
    if jumping:
        assert(not charging)
        finish_jump()
        return
    if can_see_player():
        # 这一帧只负责进入charge状态
        # 下一帧再选择moving target
        charging = true
        return

    # charging enemy在转方向的时候有跟踪玩家和绕路的行为
    # 但绕路状态只持续1格
    if detouring:
        detouring = false
        if try_change_back_to_expected_dir():
            return
    else:
        if try_step_forward_moving_target(dir):
            return
        if try_detour():
            return
    try_change_direction()

func do_charge():
    assert(not jumping)
    if dir == NONE:
        return
    position = GridHelper.step_position_by_speed(position, dir, CHARGE_SPEED)
    update_mover_grid_pos()

# 改变方向，有追踪玩家的趋势
func try_change_direction() -> bool:
    var player_grid_pos = get_closest_player_grid_pos()
    var dis_to_player = {}
    # 计算距离
    for possible_dir in [UP, DOWN, LEFT, RIGHT]:
        var row = GridHelper.get_next_row_in_direction(current_row, possible_dir)
        var col = GridHelper.get_next_col_in_direction(current_col, possible_dir)
        dis_to_player[possible_dir] = GridHelper.get_manhattan_dis(
            player_grid_pos, Vector2(row, col)
        )
    # 按距离排序方向
    var sorted_directions = [UP, DOWN, LEFT, RIGHT]
    sorted_directions.sort_custom(
        func(a, b): return dis_to_player[a] < dis_to_player[b]
    )
    # 尝试改变方向
    for possible_dir in sorted_directions:
        if try_step_forward_moving_target(possible_dir):
            play_walk_animation()
            return true
    return false

func get_closest_player_grid_pos() -> Vector2i:
    var player: Player = game_manager.get_node("Player")
    return Vector2i(player.current_row, player.current_col)

# 检测是否能看到玩家
func can_see_player() -> bool:
    assert(dir != NONE)
    var check_row = current_row
    var check_col = current_col
    for i in range(1, 31):
        check_row = GridHelper.get_next_row_in_direction(check_row, dir)
        check_col = GridHelper.get_next_col_in_direction(check_col, dir)
        if not game_manager.is_valid_row_col(check_row, check_col):
            break
        if not check_target_movable(check_row, check_col):
            break
        if game_manager.get_player_instance(check_row, check_col) != null:
            return true
    return false

# 在dir被挡住时，尝试进入绕道状态
func try_detour() -> bool:
    assert(dir != NONE)
    var possible_detour_dirs: Array
    match dir:
        UP, DOWN:
            possible_detour_dirs = [LEFT, RIGHT]
        LEFT, RIGHT:
            possible_detour_dirs = [UP, DOWN]
    for possible_dir in possible_detour_dirs:
        expected_dir = dir
        if try_step_forward_moving_target(possible_dir):
            detouring = true
            play_walk_animation()
            return true
    return false

# 尝试从绕路状态切回到正常方向
func try_change_back_to_expected_dir() -> bool:
    return try_step_forward_moving_target(expected_dir)

# 被方块击晕时会打断冲刺状态
func do_hit_by_block(block: Block) -> void:
    charging = false
    super.do_hit_by_block(block)

func set_enemy_sprite() -> void:
    anim_sprite = $ChargingEnemySprite

func play_walk_animation() -> void:
    anim_sprite.offset = SPRITE_OFFSET_NORMAL
    anim_sprite.speed_scale = ANIMATION_FPS_SCALE_WALK
    anim_sprite.play("walk_" + dir)

func play_jump_animation() -> void:
    anim_sprite.offset = SPRITE_OFFSET_NORMAL
    anim_sprite.speed_scale = ANIMATION_FPS_SCALE_HIT
    anim_sprite.play("hit_" + dir)

func play_stunned_animation() -> void:
    anim_sprite.offset = SPRITE_OFFSET_NORMAL
    anim_sprite.speed_scale = ANIMATION_FPS_SCALE_WALK
    anim_sprite.play("stunned_" + dir)

func play_charge_animation():
    anim_sprite.offset = SPRITE_OFFSET_NORMAL
    anim_sprite.play("charge_" + dir)
