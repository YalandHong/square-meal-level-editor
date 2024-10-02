extends Enemy
class_name LeapingEnemy

const SPRITE_OFFSET_NORMAL: Vector2 = Vector2(
    -58 / 2 + GameManager.TILE_WIDTH / 2,
    -GameManager.TILE_HEIGHT / 2 - 86
)

const ANIMATION_FPS_SCALE_WALK: float = 0.5
const ANIMATION_FPS_SCALE_CHARGE: float = 0.8
const ANIMATION_FPS_SCALE_HIT: float = 0.8

# 飞行（飞跃）相关
# 包括3个状态：起飞、飞行、落地
var leap_starting: bool = false
var leaping: bool = false
var leap_ending: bool = false

func _ready() -> void:
    super._ready()
    anim_sprite.animation_finished.connect(_on_animation_finished)

func handle_movement_or_jump():
    if not leap_starting and not leap_ending:
        do_move()
        return
    check_hit_players()
    if not reached_target():
        return
    handle_reached_moving_target()

func handle_reached_moving_target():
    position = Vector2(moving_target_x, moving_target_y)
    update_mover_grid_pos()
    if jumping:
        finish_jump()
        return
    if leaping:
        finish_leap()
    if try_chase_player():
        return
    try_change_direction()

# 如果敌人和玩家位于同一行，则只需要考虑左右移动
# 否则，会优先试图和玩家走到同一行
func get_direction_towards_player(player_row: int, player_col: int) -> String:
    if player_row == current_row:
        return LEFT if player_col < current_col else RIGHT
    return UP if player_row < current_row else DOWN

# leaping enemy会根据玩家的位置选择下一步要移动的目标位置
# 如果遇到障碍物，会试图越过去
func try_chase_player() -> bool:
    var player_pos = get_closest_player_grid_pos()
    var player_row = player_pos.y
    var player_col = player_pos.x
    var possible_dir = get_direction_towards_player(player_row, player_col)
    if try_step_forward_moving_target(possible_dir):
        return true
    return try_leap(possible_dir)

# 前方3格以内有空位置，则可以起飞
func try_leap(target_dir: String) -> bool:
    for i in range(1, 4):
        var target_row = GridHelper.get_farther_row_in_direction(current_row, target_dir, i)
        var target_col = GridHelper.get_farther_col_in_direction(current_col, target_dir, i)
        if not game_manager.is_valid_row_col(target_row, target_col):
            break
        if check_target_movable(target_row, target_col):
            do_change_moving_target(target_row, target_col, target_dir)
            start_leap()
            return true
    return false

func start_leap():
    assert(not leaping and not leap_ending)
    leap_starting = true
    play_leap_start_animation()

func finish_leap():
    pass

func _on_animation_finished():
    if leap_starting:
        leap_starting = false
        leaping = true
        play_leap_animation()
    if leap_ending:
        leap_ending = false
        play_walk_animation()

func get_closest_player_grid_pos() -> Vector2i:
    var player: Player = game_manager.get_node("Player")
    return Vector2i(player.current_row, player.current_col)

# 飞行状态的敌人是不会被击中的
func do_hit_by_block(block: Block) -> bool:
    if leaping:
        return false
    leap_starting = false
    leap_ending = false
    return super.do_hit_by_block(block)

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

func play_leap_start_animation():
    anim_sprite.offset = SPRITE_OFFSET_NORMAL
    anim_sprite.speed_scale = ANIMATION_FPS_SCALE_WALK
    anim_sprite.play("leap_start_" + dir)

func play_leap_animation():
    anim_sprite.offset = SPRITE_OFFSET_NORMAL
    anim_sprite.speed_scale = ANIMATION_FPS_SCALE_WALK
    anim_sprite.play("leap_" + dir)

func play_leap_end_animation():
    anim_sprite.offset = SPRITE_OFFSET_NORMAL
    anim_sprite.speed_scale = ANIMATION_FPS_SCALE_WALK
    anim_sprite.play_backwards("leap_start_" + dir)
