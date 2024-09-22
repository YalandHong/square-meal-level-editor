extends Enemy
class_name DumbEnemy

const SPRITE_OFFSET_NORMAL: Vector2 = Vector2(-53 / 2 + GameManager.TILE_WIDTH / 2, -GameManager.TILE_HEIGHT / 2 - 80)
const SPRITE_OFFSET_HIT: Vector2 = Vector2(-46 / 2 + GameManager.TILE_WIDTH / 2, -GameManager.TILE_HEIGHT / 2 - 78)

const ANIMATION_FPS_SCALE_WALK: float = 0.5

func set_enemy_sprite() -> void:
    anim_sprite = $DumbEnemySprite

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
    assert(false, "try change direction failed")
    return false

# 尝试根据方向移动
# TODO 这个比之前player和block里写得更好，提取并统一到grid element里
func try_step_forward_moving_target(target_dir: String) -> bool:
    var target_row = GlobalVars.step_row_by_direction(current_row, target_dir)
    var target_col = GlobalVars.step_col_by_direction(current_col, target_dir)
    if check_target_movable(target_row, target_col):
        do_change_moving_target(target_row, target_col, target_dir)
        return true
    return false

# 有东西挡住了的，不能作为目标移动位置
func check_target_movable(target_row: int, target_col: int) -> bool:
    return (game_manager.get_tile_instance(target_row, target_col) == null
        and game_manager.get_enemy_instance(target_row, target_col) == null)

#func is_next_step_empty() -> bool:
    #var target_row = GlobalVars.step_row_by_direction(current_row, dir)
    #var target_col = GlobalVars.step_col_by_direction(current_col, dir)
    ## 获取目标位置的中心坐标
    #moving_target_x = GameManager.get_tile_top_left_x(target_col)
    #moving_target_y = GameManager.get_tile_top_left_y(target_row)
#
    ## 检查目标位置是否为空
    ## TODO player、block和enemy检测逻辑是不一样的
    #var is_empty = game_manager.is_empty(target_row, target_col)
    #return is_empty
#
#func get_next_target() -> bool:
    #assert(dir != NONE)
    #return is_next_step_empty()

func play_walk_animation() -> void:
    anim_sprite.offset = SPRITE_OFFSET_NORMAL
    anim_sprite.speed_scale = ANIMATION_FPS_SCALE_WALK
    anim_sprite.play("walk_" + dir)
