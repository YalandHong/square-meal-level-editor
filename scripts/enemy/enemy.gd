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
var eaten: bool = false

var stunned: bool = false
var stunned_count: int
const MAX_STUNNED_COUNT: int = 100

# Flash里移过来的，意义不明的变量
#var tiles_moved: int = 0

var jumping: bool = false

var dir: String
var moving_target_x: float
var moving_target_y: float
var current_row: int = 0
var current_col: int = 0
const MOVE_SPEED: float = 2  # 每个enemy不太一样吧？

func _init() -> void:
    dir = RIGHT  # 初始方向

func _ready():
    game_manager = get_parent()
    sfx_player = game_manager.get_parent().get_node("SfxPlayer")

func _process(delta: float) -> void:
    if eaten:
        return  # 如果已经被吃掉，则不进行任何处理

    if stunned:
        handle_stunned()
        return

    handle_movement()

func handle_stunned() -> void:
    stunned_count += 1
    if stunned_count < MAX_STUNNED_COUNT:
        return
    wake_up()

func wake_up():
    update_mover_grid_pos()
    if not get_next_target():
        change_direction()
        #tiles_moved = 0

    play_walk_animation()
    stunned = false

func handle_movement() -> void:
    do_move()

    if not reached_target():
        return

    #tiles_moved += 1
    position = Vector2(moving_target_x, moving_target_y)

    if jumping:
        finish_jump()
        return

    update_mover_grid_pos()
    if not get_next_target():
        change_direction()
        #tiles_moved = 0

    check_hit_players()

func do_move() -> void:
    if dir == NONE:
        return
    position = GlobalVars.step_position_by_speed(position, dir, MOVE_SPEED)
    update_mover_grid_pos()

func update_mover_grid_pos():
    var new_row = GameManager.get_row(position.y)
    var new_col = GameManager.get_col(position.x)
    game_manager.update_movers(self, current_row, current_col, new_row, new_col)

    current_row = new_row
    current_col = new_col

# TODO 这个函数也在player和block里用到了
func reached_target() -> bool:
    return (dir == LEFT and position.x <= moving_target_x or
            dir == RIGHT and position.x >= moving_target_x or
            dir == UP and position.y <= moving_target_y or
            dir == DOWN and position.y >= moving_target_y)

func finish_jump() -> void:
    # 处理完成跳跃的逻辑
    # TODO
    jumping = false

func get_next_target() -> bool:
    assert(false, "calling get_next_target from abstract enemy")
    return false

func change_direction() -> void:
    assert(false, "calling change_direction from abstract enemy")
    pass

func play_walk_animation() -> void:
    anim_sprite.play("walk_" + dir)

func check_hit_players() -> void:
    if jumping or stunned:
        return
    var player: Player = game_manager.get_player_instance(current_row, current_col)
    if player == null:
        return
    player.die()
