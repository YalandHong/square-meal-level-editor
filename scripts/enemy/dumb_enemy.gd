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
