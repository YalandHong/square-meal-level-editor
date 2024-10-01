extends Enemy
class_name HelmetEnemy

const SPRITE_OFFSET_NORMAL: Vector2 = Vector2(
    -63 / 2 + GameManager.TILE_WIDTH / 2,
    -GameManager.TILE_HEIGHT / 2 - 87
)

const ANIMATION_FPS_SCALE_WALK: float = 0.5
const ANIMATION_FPS_SCALE_HIT: float = 0.8

var ducking: bool
var duck_timer: int

func set_enemy_sprite() -> void:
    anim_sprite = $HelmetEnemySprite

func _ready() -> void:
    super._ready()
    do_duck()

func _process(_delta: float) -> void:
    z_index = GameManager.calculate_depth(position)
    if being_eaten:
        return # 如果已经被吃掉，则不进行任何处理
    if stunned:
        handle_stunned()
        return
    if ducking:
        handle_duck()
        return
    handle_movement_or_jump()
    assert(check_aligned_with_moving_target())

# helmet在走到了与格子对齐的地方后要判断是否要趴下（duck）
func handle_movement_or_jump() -> void:
    assert(not ducking)
    do_move()
    check_hit_players()
    if duck_timer > 0:
        duck_timer -= 1
    if not reached_target():
        return
    position = Vector2(moving_target_x, moving_target_y)
    update_mover_grid_pos()
    if jumping:
        finish_jump()
        return
    if duck_timer == 0:
        do_duck()
        return
    if not try_step_forward_moving_target(dir):
        try_change_direction()

# 从walk状态切换到duck状态
# 有1/3的概率尝试改变方向
func do_duck():
    if randi() % 3 == 0:
        try_change_direction()
    ducking = true
    duck_timer = randi_range(30, 150)
    play_duck_animation()

# Flash原版里叫do_duck
func handle_duck():
    check_hit_players()
    duck_timer -= 1
    if duck_timer <= 0:
        do_stand_up()

# 从duck状态切换到walk状态
func do_stand_up():
    ducking = false
    duck_timer = randi_range(30, 150)
    play_walk_animation()
    pass

func play_duck_animation():
    anim_sprite.offset = SPRITE_OFFSET_NORMAL
    anim_sprite.play("duck_" + dir)

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
