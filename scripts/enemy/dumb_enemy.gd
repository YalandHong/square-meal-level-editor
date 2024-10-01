extends Enemy
class_name DumbEnemy

const SPRITE_OFFSET_NORMAL: Vector2 = Vector2(-53 / 2 + GameManager.TILE_WIDTH / 2, -GameManager.TILE_HEIGHT / 2 - 80)
const SPRITE_OFFSET_HIT: Vector2 = Vector2(-46 / 2 + GameManager.TILE_WIDTH / 2, -GameManager.TILE_HEIGHT / 2 - 78)

const ANIMATION_FPS_SCALE_WALK: float = 0.5
const ANIMATION_FPS_SCALE_HIT: float = 0.8

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
    #assert(false, "try change direction failed")
    # 如果四个方向都被堵住了，那就什么都不做
    return false

# 有东西挡住了的，不能作为目标移动位置
# 目标位置已经是其它敌人的移动目标了，也不行
func check_target_movable(target_row: int, target_col: int) -> bool:
    if (game_manager.get_tile_instance(target_row, target_col) != null):
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
    return true

#func is_next_step_empty() -> bool:
    #var target_row = GridHelper.get_next_row_in_direction(current_row, dir)
    #var target_col = GridHelper.get_next_col_in_direction(current_col, dir)
    ## 获取目标位置的中心坐标
    #moving_target_x = GridHelper.get_tile_top_left_x(target_col)
    #moving_target_y = GridHelper.get_tile_top_left_y(target_row)
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

func play_jump_animation() -> void:
    anim_sprite.offset = SPRITE_OFFSET_HIT
    anim_sprite.speed_scale = ANIMATION_FPS_SCALE_HIT
    anim_sprite.play("hit_" + dir)

func play_stunned_animation() -> void:
    anim_sprite.offset = SPRITE_OFFSET_NORMAL
    anim_sprite.speed_scale = ANIMATION_FPS_SCALE_WALK
    anim_sprite.play("stunned_" + dir)
