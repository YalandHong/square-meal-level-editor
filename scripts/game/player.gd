extends GridElement
class_name Player

@onready var anim_sprite: AnimatedSprite2D = $PlayerSprite

# Flash解包出来的sprite大小不一，而且player在stop和walk sprite中的位置不一样
# 有些我懒得resize了，所以设置不一样的offset
# 在下面这些公式里，75是stop/walk的精灵宽度，99是eat right/left的精灵宽度
# 15是为了补齐player在stop和walk sprite的位置差距
const SPRITE_OFFSET_NORMAL: Vector2 = Vector2(-75 / 2 + GameManager.TILE_WIDTH / 2, -GameManager.TILE_HEIGHT / 2 - 40)
const SPRITE_OFFSET_EAT: Vector2 = SPRITE_OFFSET_NORMAL
const SPRITE_OFFSET_EAT_RIGHT: Vector2 = Vector2(SPRITE_OFFSET_NORMAL.x + 15, SPRITE_OFFSET_NORMAL.y)
const SPRITE_OFFSET_EAT_LEFT: Vector2 = Vector2(-99 - 15 + 75 + SPRITE_OFFSET_NORMAL.x, SPRITE_OFFSET_NORMAL.y)

var game_manager: GameManager
var shadow: AnimatedSprite2D

enum PlayerState {
    MOVING, TURNING, IDLE, SLIPPING, STOPPING,
    EATING, SPITTING, DEAD, WINNING
}
var state: PlayerState

# 转向相关
var turn_count: int = 0
const MAX_TURN_COUNT: int = 1

# 移动相关
const SIDE_WALK_SPEED: float = 5
const WALK_SPEED: float = 5
const ANIMATION_FPS_SCALE_WALK: float = 0.3

#var player_id: int = 1

# 吃方块相关
var swallowed_block_type: int = GlobalVars.ID_EMPTY_TILE
var eating_block: GridElement
var eating_block_row: int = -1
var eating_block_col: int = -1
const EATING_BLOCK_SHIFT_SPEED: float = 8
const ANIMATION_FPS_SCALE_EAT: float = 1.0
const EATING_BLOCK_START_SHIFTING_FRAME: int = 7
const SPITTING_BLOCK_DO_SPIT_FRAME: int = 2

# 分数和通关相关
var score: int = 0
const ANIMATION_FPS_SCALE_WINNING: float = 0.8
const ANIMATION_FPS_SCALE_DEAD: float = 0.6

func _ready():
    game_manager = get_parent()
    shadow = preload("res://scenes/game/shadow.tscn").instantiate()
    add_child(shadow)

    anim_sprite.centered = false
    anim_sprite.animation_finished.connect(_on_animation_finished)

    state = PlayerState.IDLE
    dir = DOWN
    play_stop_animation()

func _process(_delta):
    match state:
        PlayerState.IDLE, PlayerState.STOPPING:
            handle_idle_or_stopping()
        PlayerState.MOVING, PlayerState.SLIPPING:
            handle_moving_or_slipping()
        PlayerState.TURNING:
            handle_turning()
        PlayerState.EATING:
            handle_eating()
    # 当player和其他block等元素深度相同时，挡在block前面
    z_index = GameManager.calculate_depth(position) + 1
    update_shadow_position()

func handle_moving_or_slipping():
    do_move()

    # 如果玩家到达目标格子，停止移动
    if reached_target():
        position.x = moving_target_x
        position.y = moving_target_y
        update_player_grid_pos()
        # player在结束moving或者slipping时给出这样1帧的stopping状态
        # 以便某些block进行判定
        state = PlayerState.STOPPING
        return

    if state == PlayerState.SLIPPING:
        return

    # 检查按键转向
    # 在移动的时候按下相反的方向键，则可以直接转向，而不需要等走到目标格子后再操作
    var new_direction = get_direction_pressed()
    if new_direction == NONE or new_direction == dir:
        return
    if (GridHelper.is_opposite_direction(dir, new_direction)
            and try_step_forward_moving_target(new_direction)):
        # moving = true
        do_move()
        play_walk_animation()

func handle_idle_or_stopping():
    if game_manager.level_cleared:
        state = PlayerState.WINNING
        SfxPlayerSingleton.play_sfx("win")
        play_win_animation()
        return

    if Input.is_action_pressed("ui_select"):
        start_eat_or_spit()
        return

    var direction_pressed = get_direction_pressed()
    if direction_pressed == NONE:
        state = PlayerState.IDLE
        play_stop_animation()
        return

    # 转向
    if direction_pressed != dir:
        dir = direction_pressed
        play_stop_animation()
        state = PlayerState.TURNING
        turn_count = 0
        return

    # 执行移动动画和移动逻辑
    play_walk_animation()
    if try_step_forward_moving_target(direction_pressed):
        state = PlayerState.MOVING
        do_move()

# 处理吃东西或吐方块的逻辑
func start_eat_or_spit():
    if swallowed_block_type != GlobalVars.ID_EMPTY_TILE:
        start_spit_block()
        return
    assert(eating_block == null)
    start_eat_block()

# 停止动画
func play_stop_animation():
    anim_sprite.offset = SPRITE_OFFSET_NORMAL
    if swallowed_block_type == GlobalVars.ID_EMPTY_TILE:
        anim_sprite.play("stop_" + dir)
    else:
        anim_sprite.play("stop_" + dir + "_fat")

# 行走动画
func play_walk_animation():
    anim_sprite.speed_scale = ANIMATION_FPS_SCALE_WALK
    anim_sprite.offset = SPRITE_OFFSET_NORMAL
    if swallowed_block_type == GlobalVars.ID_EMPTY_TILE:
        anim_sprite.play("walk_" + dir)
    else:
        anim_sprite.play("walk_" + dir + "_fat")

func play_eat_animation() -> void:
    anim_sprite.speed_scale = ANIMATION_FPS_SCALE_EAT
    match dir:
        LEFT:
            anim_sprite.offset = SPRITE_OFFSET_EAT_LEFT
        RIGHT:
            anim_sprite.offset = SPRITE_OFFSET_EAT_RIGHT
        _:
            anim_sprite.offset = SPRITE_OFFSET_EAT
    anim_sprite.play("eat_" + dir)

func play_spit_animation() -> void:
    play_eat_animation()

# 模拟获取方向键的按键状态
func get_direction_pressed() -> String:
    if Input.is_action_pressed("ui_right"):
        return RIGHT
    if Input.is_action_pressed("ui_left"):
        return LEFT
    if Input.is_action_pressed("ui_down"):
        return DOWN
    if Input.is_action_pressed("ui_up"):
        return UP
    return NONE

func can_spit(target_row: int, target_col: int) -> bool:
    # 检查目标格子是否为空
    var target_block = game_manager.get_block_instance(target_row, target_col)
    if target_block != null:
        return false
    return true

# 吐出方块逻辑
# 原版Flash里在frame=2时才真正吐出方块
# 但这样会给Player增加大量临时变量，我就没这么做，直接在frame=0就开始spit block
# 而且，start spit block是确认了next step为空
# 把do_spit逻辑写在start_spit_block的最后
func start_spit_block():
    var target_row: int = GridHelper.get_next_row_in_direction(current_row, dir)
    var target_col: int = GridHelper.get_next_col_in_direction(current_col, dir)
    if not can_spit(target_row, target_col):
        return

    # 切换到吐方块的动画
    play_spit_animation()
    SfxPlayerSingleton.play_sfx("spit")
    state = PlayerState.SPITTING

    # TODO 暂无UI
    # 更新显示玩家当前持有的方块状态 (这里假设有个 BlockDisplay 类来显示持有的方块)
    #BlockDisplay.update_display(0)

    # 将玩家持有的方块放入目标格子，并清空玩家当前的持有方块
    if swallowed_block_type == GlobalVars.ID_EXPLOSIVE_BLOCK:
        var explosion = get_node("Explosion")
        remove_child(explosion)
        game_manager.place_and_slide_new_explosive_block(
            target_row, target_col, dir, explosion
        )
    else:
        game_manager.place_and_slide_new_block(
            swallowed_block_type, target_row, target_col, dir
        )
    swallowed_block_type = GlobalVars.ID_EMPTY_TILE

func finish_spit_block():
    play_stop_animation()
    state = PlayerState.IDLE

func check_target_movable(target_row: int, target_col: int) -> bool:
    var block: Block = game_manager.get_block_instance(target_row, target_col)
    if block != null and not block.is_walkable():
        return false
    var enemy: Enemy = game_manager.get_enemy_instance(target_row, target_col)
    if enemy != null and enemy.stunned:
        return false
    return true

# 玩家移动
func do_move():
    assert(dir != NONE)

    if dir == LEFT:
        position.x -= SIDE_WALK_SPEED
    elif dir == RIGHT:
        position.x += SIDE_WALK_SPEED
    elif dir == UP:
        position.y -= WALK_SPEED
    elif dir == DOWN:
        position.y += WALK_SPEED

    update_player_grid_pos()

func update_player_grid_pos() -> void:
    var new_row = GridHelper.y_to_row(position.y)
    var new_col = GridHelper.x_to_col(position.x)

    # 调用 GameManager 的 update_players 方法，更新玩家的位置
    game_manager.update_players(self, current_row, current_col, new_row, new_col)

    # 更新 Player 类的 current_row 和 current_col
    current_row = new_row
    current_col = new_col

func handle_turning() -> void:
    turn_count += 1
    if turn_count >= MAX_TURN_COUNT:
        state = PlayerState.IDLE

func start_eat_block() -> void:
    eating_block_row = GridHelper.get_next_row_in_direction(current_row, dir)
    eating_block_col = GridHelper.get_next_col_in_direction(current_col, dir)

    # 吃方块
    if game_manager.is_eatable_tile(eating_block_row, eating_block_col):
        eating_block = game_manager.get_block_instance(eating_block_row, eating_block_col)
        eating_block.being_eaten = true
        SfxPlayerSingleton.play_sfx("eat")
    # 吃敌人
    elif game_manager.is_eatable_enemy(eating_block_row, eating_block_col):
        eating_block = game_manager.get_enemy_instance(eating_block_row, eating_block_col)
        eating_block.being_eaten = true
        SfxPlayerSingleton.play_sfx("eat")
    # 没吃到任何东西
    else:
        eating_block = null

    # 标记当前状态为正在吃东西
    state = PlayerState.EATING

    # 根据当前方向切换到相应的吃东西动画
    # 在吃东西动画播放结束时，会callback相应处理函数
    play_eat_animation()

func _on_animation_finished():
    #print("animation finished")
    if state == PlayerState.EATING:
        do_swallow_block()
        finish_eat_block()
    elif state == PlayerState.SPITTING:
        finish_spit_block()
    elif state == PlayerState.DEAD:
        game_manager._handle_failed()

# Flash源码里叫shift block
# 播放block吞入嘴里的动画
func handle_eating():
    if eating_block == null or not is_instance_valid(eating_block):
        return
    if anim_sprite.get_frame() < EATING_BLOCK_START_SHIFTING_FRAME:
        return
    eating_block.position = GridHelper.back_position_by_speed(eating_block.position, dir, EATING_BLOCK_SHIFT_SPEED)

func finish_eat_block():
    state = PlayerState.IDLE
    play_stop_animation()

func do_swallow_block():
    if eating_block == null or not is_instance_valid(eating_block):
        return
    if eating_block is Enemy:
        do_eat_enemy()
        return
    do_eat_block()

func do_eat_enemy():
    eating_block.be_eaten_by_player(self)
    eating_block = null

func do_eat_block():
    eating_block.be_eaten_by_player(self)
    eating_block = null

func do_hit_by_block():
    die()

func die():
    if state == PlayerState.DEAD:
        return
    if state == PlayerState.SPITTING or state == PlayerState.EATING:
        return
    SfxPlayerSingleton.play_sfx("die")
    state = PlayerState.DEAD
    play_dead_animation()

func play_dead_animation():
    anim_sprite.speed_scale = ANIMATION_FPS_SCALE_DEAD
    anim_sprite.offset = SPRITE_OFFSET_NORMAL
    anim_sprite.play("die")

func play_win_animation():
    anim_sprite.speed_scale = ANIMATION_FPS_SCALE_WINNING
    anim_sprite.play("cheer")

# 原版双人模式下，这个函数还会判断player 2的位置
# 目前只支持单人模式，所以不考虑
func try_start_slipping() -> bool:
    if state != PlayerState.MOVING and state != PlayerState.STOPPING:
        return false
    if not try_step_forward_moving_target(dir):
        return false
    state = PlayerState.SLIPPING
    play_stop_animation()
    return true

# 原游戏里玩家被炸是隐形，我这选择直接die了
func be_exploded():
    die()

func add_score(added_score: int):
    score += added_score
    var popup = FloatingScoreUp.new(str(added_score))
    add_child(popup)
    popup.position = Vector2(GridHelper.TILE_WIDTH / 2, -35)

# z_index默认是相对深度
func update_shadow_position():
    shadow.z_index = - 30
