extends Enemy
class_name DumbEnemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    anim_sprite = $DumbEnemySprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

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
func change_direction() -> void:
    var possible_directions = get_possible_directions()
    possible_directions.shuffle()  # 打乱方向顺序

    for possible_dir in possible_directions:
        if try_move_in_direction(possible_dir):
            break

# 尝试根据方向移动
# TODO 这个比之前player和block里写得更好，提取并统一到grid element里
func try_move_in_direction(possible_dir: String) -> bool:
    var target_row = GlobalVars.step_row_by_direction(current_row, possible_dir)
    var target_col = GlobalVars.step_col_by_direction(current_col, possible_dir)
    if game_manager.is_empty(target_row, target_col):
        set_target(target_row, target_col, possible_dir)
        return true
    #match possible_dir:
        #LEFT:
            #if game_manager.is_tile_empty(current_row, current_col - 1):
                #set_target(current_col - 1, current_row, LEFT)
                #return true
        #RIGHT:
            #if game_manager.is_tile_empty(current_row, current_col + 1):
                #set_target(current_col + 1, current_row, RIGHT)
                #return true
        #UP:
            #if game_manager.is_tile_empty(current_row - 1, current_col):
                #set_target(current_col, current_row - 1, UP)
                #return true
        #DOWN:
            #if game_manager.is_tile_empty(current_row + 1, current_col):
                #set_target(current_col, current_row + 1, DOWN)
                #return true
    return false

# 设置目标位置和方向
func set_target(new_col: int, new_row: int, new_dir: String):
    moving_target_x = game_manager.get_tile_top_left_x(new_col)
    moving_target_y = game_manager.get_tile_top_left_y(new_row)
    #target_col = new_col
    #target_row = new_row
    dir = new_dir
    #play_animation("WALK_" + str(dir))
    play_walk_animation()

func is_next_step_empty() -> bool:
    var target_row = GlobalVars.step_row_by_direction(current_row, dir)
    var target_col = GlobalVars.step_col_by_direction(current_col, dir)
    # 获取目标位置的中心坐标
    moving_target_x = GameManager.get_tile_top_left_x(target_col)
    moving_target_y = GameManager.get_tile_top_left_y(target_row)

    # 检查目标位置是否为空
    var is_empty = game_manager.is_empty(target_row, target_col)
    return is_empty

func get_next_target() -> bool:
    assert(dir != NONE)
    return is_next_step_empty()
